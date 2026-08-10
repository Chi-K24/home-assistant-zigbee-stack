# Build Log

## 1. Host and service inventory

The deployment was added to an existing Raspberry Pi 5 that already hosted other services. Port and container checks were performed first to avoid collisions.

The final public-facing ports are:

| Service | Host port |
| --- | --- |
| Home Assistant | 8123 |
| Zigbee2MQTT frontend | 8099 |
| Mosquitto | 1883 on loopback only |

## 2. Compose deployment

Three independent containers were deployed:

- Home Assistant Container using host networking
- Mosquitto as the authenticated MQTT broker
- Zigbee2MQTT with exclusive access to the USB coordinator

Separating these roles makes each component independently replaceable and keeps Zigbee coordinator state outside Home Assistant.

## 3. Coordinator discovery

The ZBDongle-P appeared as a Silicon Labs CP210x UART bridge and was matched by Zigbee2MQTT as a `zstack` adapter. The Compose definition uses a persistent `/dev/serial/by-id/` host path rather than a boot-order-dependent `/dev/ttyUSB*` path.

Startup validation confirmed:

- Serial port opened at 115200 baud
- Adapter type `ZStack3x0`
- Coordinator backup written
- MQTT broker connection established
- Zigbee2MQTT bridge state online

## 4. Radio planning

A 2.4 GHz Wi-Fi scan showed the local access point on channel 5. Zigbee channel 25 was selected to reduce direct spectral overlap.

## 5. Firmware maintenance

The coordinator initially reported firmware revision `20230507`. Before flashing:

1. The Zigbee2MQTT data directory was archived privately.
2. The container was stopped cleanly.
3. The dongle was moved to a Windows machine.
4. Coordinator firmware revision `20250321` was flashed.
5. The dongle was returned to the same Raspberry Pi USB path.
6. Zigbee2MQTT was restarted and logs were inspected.

Post-upgrade logs confirmed `zigbee-herdsman started (restored)`, revision `20250321`, MQTT connectivity, and an online bridge.

## 6. Home Assistant integration

Mosquitto was added to Home Assistant with a dedicated account through the MQTT integration. Home Assistant discovery was enabled in Zigbee2MQTT.

After discovery was enabled, the paired LED strip appeared as a Home Assistant device with on/off, brightness, color temperature, and RGB controls.

## 7. Wi-Fi integration

A generic 2.4 GHz plug was paired through Smart Life and added through Home Assistant's Tuya integration. This illustrates the difference between:

- Zigbee devices controlled locally through the coordinator
- Wi-Fi devices represented through a vendor cloud integration

## Result

The finished system provides phone control through Home Assistant, local Zigbee operation, authenticated MQTT transport, persistent coordinator state, and a documented recovery path.
