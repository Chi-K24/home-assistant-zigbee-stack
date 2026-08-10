# Architecture

## Design goals

The stack was designed around four goals:

1. Keep normal device control local.
2. Give Home Assistant reliable LAN discovery.
3. Keep the MQTT broker off the general LAN.
4. Give one container exclusive ownership of the Zigbee coordinator.

## Service topology

~~~mermaid
flowchart TD
    LAN["LAN clients and devices"] --> HA["Home Assistant host network"]
    HA -->|"127.0.0.1:1883"| Broker["Mosquitto"]
    Broker <-->|"automation network"| Bridge["Zigbee2MQTT"]
    Bridge -->|"/dev/ttyUSB0"| Radio["ZBDongle-P coordinator"]
    Radio -->|"Zigbee channel 25"| Endpoints["Zigbee endpoints"]
~~~

## Container networking

### Home Assistant

Home Assistant uses `network_mode: host`. This avoids translating multicast and broadcast discovery traffic through a Docker bridge and exposes the Home Assistant frontend on the host's normal TCP 8123 listener.

Because host-networked Home Assistant is not attached to the Compose bridge, it connects to MQTT through the broker's loopback publication at `127.0.0.1:1883`.

### Mosquitto

Mosquitto joins the private `automation` bridge for Zigbee2MQTT and publishes TCP 1883 only to host loopback:

~~~yaml
ports:
  - "127.0.0.1:1883:1883"
~~~

This lets Home Assistant connect without making MQTT directly reachable by other LAN clients.

### Zigbee2MQTT

Zigbee2MQTT joins the `automation` bridge and resolves the broker by Compose service name:

~~~yaml
mqtt:
  server: mqtt://mosquitto:1883
~~~

Its frontend is published on host TCP 8099. The host's persistent serial identifier is mapped to the stable in-container path `/dev/ttyUSB0`.

## Radio plan

The closest 2.4 GHz Wi-Fi network was operating on channel 5. Zigbee channel 25 was selected to place the Zigbee network toward the upper end of the 2.4 GHz band and reduce overlap.

The coordinator should be kept away from USB 3 storage, hubs, and radio antennas where practical. A short USB extension cable can help reduce local interference.

## Data ownership

| Data | Owner | Public repository treatment |
| --- | --- | --- |
| Home Assistant entities, tokens and UI state | Home Assistant | Ignored |
| MQTT credential hashes | Mosquitto | Ignored |
| Zigbee network key and PAN identifiers | Zigbee2MQTT | Ignored |
| Coordinator backup and joined-device database | Zigbee2MQTT | Ignored |
| Reproducible service definitions | Git | Included |
| Sanitized operating notes | Git | Included |

## Failure behavior

- Home Assistant can restart without resetting the Zigbee network.
- Mosquitto clients reconnect after a broker restart.
- Zigbee2MQTT persists joined-device state under its private data directory.
- The restart policy returns containers after host reboot.
- A coordinator firmware change is preceded by a private data backup and a clean Zigbee2MQTT shutdown.
