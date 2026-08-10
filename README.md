# Home Assistant Zigbee Stack

A containerized, local-first home automation platform running on a Raspberry Pi 5. Home Assistant provides the control plane, Mosquitto carries MQTT messages, and Zigbee2MQTT connects Zigbee devices through a Sonoff ZBDongle-P coordinator.

> This is a sanitized reference implementation of a working home deployment. Runtime databases, credentials, network keys, coordinator backups, device identifiers, IP addresses, and personal configuration are intentionally excluded.

## What this project demonstrates

- Multi-container service design with Docker Compose
- Local Zigbee control without a vendor hub
- MQTT-based integration between Home Assistant and Zigbee2MQTT
- Stable USB device mapping with `/dev/serial/by-id/`
- 2.4 GHz coexistence planning between Wi-Fi and Zigbee
- Coordinator firmware backup, upgrade, and restore validation
- Home Assistant discovery for Zigbee devices
- A deliberate public-repository sanitization model

## Architecture

~~~mermaid
flowchart TD
    Client["Phone and browser"] --> HA["Home Assistant"]
    Cloud["Smart Life / Tuya"] <--> HA
    HA <-->|"MQTT via host loopback"| MQTT["Mosquitto"]
    MQTT <-->|"Private Docker network"| Z2M["Zigbee2MQTT"]
    Z2M -->|"USB serial"| Dongle["Sonoff ZBDongle-P"]
    Dongle <-->|"Zigbee channel 25"| Devices["Zigbee devices"]
~~~

Home Assistant uses host networking so LAN discovery protocols can reach it. Mosquitto is published only on the host loopback interface. Zigbee2MQTT reaches Mosquitto through the private Compose network, while Home Assistant reaches the same broker at `127.0.0.1:1883`.

## System profile

| Component | Implementation |
| --- | --- |
| Host | Raspberry Pi 5 Model B Rev 1.1 |
| Container runtime | Docker 29.6.2 with Docker Compose |
| Home automation | `ghcr.io/home-assistant/home-assistant:stable` |
| Zigbee bridge | `ghcr.io/koenkk/zigbee2mqtt:2`; verified with 2.13.0 |
| MQTT broker | `eclipse-mosquitto:2`; verified with 2.1.2 |
| Coordinator | Sonoff ZBDongle-P, TI CC2652P / Z-Stack |
| Coordinator firmware | Revision `20250321` |
| Zigbee radio plan | Channel 25, separated from nearby 2.4 GHz Wi-Fi on channel 5 |
| Zigbee2MQTT frontend | Host port 8099 |
| Home Assistant frontend | Host port 8123 |

## Network and trust boundaries

| Path | Exposure |
| --- | --- |
| Home Assistant | LAN through host networking |
| Zigbee2MQTT frontend | LAN on TCP 8099 |
| MQTT from Home Assistant | Host loopback only on TCP 1883 |
| MQTT from Zigbee2MQTT | Private Docker network |
| Coordinator | Assigned only to the Zigbee2MQTT container |
| Runtime secrets | Local files and environment values excluded from Git |

This public example does not grant Home Assistant privileged access because Zigbee hardware is owned by Zigbee2MQTT.

## Repository map

~~~text
.
├── .env.example
├── .github/workflows/validate.yml
├── compose.yaml
├── homeassistant/config/
│   ├── automations.yaml
│   ├── configuration.yaml
│   ├── scenes.yaml
│   └── scripts.yaml
├── mosquitto/config/mosquitto.conf
├── zigbee2mqtt/data/configuration.example.yaml
├── docs/
│   ├── ARCHITECTURE.md
│   ├── BUILD_LOG.md
│   ├── FIRMWARE.md
│   ├── OPERATIONS.md
│   ├── PORTFOLIO_SUMMARY.md
│   ├── SCREENSHOTS.md
│   └── SECURITY.md
└── scripts/sanitize-check.sh
~~~

## Quick start

These files are examples. Do not replace a working deployment without reviewing paths, credentials, backups, and device mappings.

### 1. Clone and prepare local files

~~~bash
git clone https://github.com/Chi-K24/home-assistant-zigbee-stack.git
cd home-assistant-zigbee-stack

cp .env.example .env
cp zigbee2mqtt/data/configuration.example.yaml    zigbee2mqtt/data/configuration.yaml

mkdir -p mosquitto/data mosquitto/log
~~~

Edit `.env` and replace the example adapter path and MQTT password. Find the persistent adapter path with:

~~~bash
ls -l /dev/serial/by-id/
~~~

Zigbee2MQTT recommends using the persistent `/dev/serial/by-id/` host path instead of `/dev/ttyUSB0`.

### 2. Create broker credentials

Create a password file for Zigbee2MQTT:

~~~bash
docker run --rm -it   -v "$PWD/mosquitto/config:/mosquitto/config"   eclipse-mosquitto:2   mosquitto_passwd -c /mosquitto/config/password_file zigbee2mqtt
~~~

Use the same Zigbee2MQTT password in `.env`. Add a separate Home Assistant broker account:

~~~bash
docker run --rm -it   -v "$PWD/mosquitto/config:/mosquitto/config"   eclipse-mosquitto:2   mosquitto_passwd /mosquitto/config/password_file homeassistant
~~~

The password file is deliberately ignored by Git.

### 3. Validate and start

~~~bash
docker compose config --quiet
./scripts/sanitize-check.sh
docker compose up -d
docker compose ps
~~~

Open:

- Home Assistant: `http://<pi-address>:8123`
- Zigbee2MQTT: `http://<pi-address>:8099`

In Home Assistant, add the MQTT integration using server `127.0.0.1`, port `1883`, and the dedicated `homeassistant` broker account. Home Assistant discovery is enabled in the Zigbee2MQTT example.

## Operational highlights

- The coordinator was detected as a TI Z-Stack adapter through a Silicon Labs CP210x serial bridge.
- Zigbee2MQTT state was backed up before the coordinator firmware change.
- Firmware was upgraded from revision `20230507` to `20250321`.
- Zigbee2MQTT reported `zigbee-herdsman started (restored)` after reconnection.
- MQTT reconnected and the bridge returned online without rebuilding the Zigbee network.
- Home Assistant discovery was enabled before pairing and controlling the Zigbee LED strip.
- A separate Smart Life / Tuya integration demonstrates cloud-connected Wi-Fi device support.

See the [build log](docs/BUILD_LOG.md) and [firmware runbook](docs/FIRMWARE.md) for the complete sequence.

## Validation before publishing

~~~bash
./scripts/sanitize-check.sh
git status --short
git diff --cached
~~~

The validation workflow also checks the Compose model and sanitization rules on every push and pull request.

## Documentation

- [Architecture and data flow](docs/ARCHITECTURE.md)
- [Implementation build log](docs/BUILD_LOG.md)
- [Coordinator firmware runbook](docs/FIRMWARE.md)
- [Operations runbook](docs/OPERATIONS.md)
- [Security and secret handling](docs/SECURITY.md)
- [Safe screenshot checklist](docs/SCREENSHOTS.md)
- [Portfolio-ready summary](docs/PORTFOLIO_SUMMARY.md)

## Upstream documentation

- [Home Assistant Container installation](https://www.home-assistant.io/installation/alternative/)
- [Zigbee2MQTT Docker installation](https://www.zigbee2mqtt.io/guide/installation/02_docker.html)
- [Zigbee2MQTT configuration](https://www.zigbee2mqtt.io/guide/configuration/)
- [Mosquitto documentation](https://mosquitto.org/documentation/)
- [Sonoff Dongle Flasher](https://dongle.sonoff.tech/sonoff-dongle-flasher/)
- [Koenkk Z-Stack firmware](https://github.com/Koenkk/Z-Stack-firmware)

## License

MIT. See [LICENSE](LICENSE).
