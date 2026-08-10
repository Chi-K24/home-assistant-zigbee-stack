# Operations Runbook

Run commands from the repository root. Prepend `sudo` to Docker commands when the local account is not a member of the Docker group.

## Service status

~~~bash
docker compose ps
docker logs homeassistant --tail 50
docker logs mosquitto --tail 50
docker logs zigbee2mqtt --tail 100
~~~

A normal Zigbee2MQTT startup should show the serial port opening, coordinator restoration, MQTT connection, an online bridge state, and frontend startup.

## Start, stop, and restart

~~~bash
docker compose up -d
docker compose stop
docker compose restart homeassistant
docker compose restart mosquitto
docker compose restart zigbee2mqtt
~~~

Stop Zigbee2MQTT before disconnecting or flashing the coordinator.

## Validate the public configuration

~~~bash
cp .env.example .env
docker compose config --quiet
./scripts/sanitize-check.sh
~~~

The example `.env` is suitable only for validation. Use unique local credentials for an actual deployment.

## Update containers

Review release notes and keep a private backup before updating:

~~~bash
docker compose pull
docker compose up -d
docker compose ps
~~~

Then inspect fresh logs and test at least one known device.

## MQTT integration paths

- Zigbee2MQTT broker address: `mqtt://mosquitto:1883`
- Home Assistant broker address: `127.0.0.1:1883`
- Anonymous access: disabled

Home Assistant and Zigbee2MQTT should use separate broker accounts.

## Joining devices

Keep joining disabled during normal operation. Enable permit-join from the Zigbee2MQTT frontend only for the pairing window, place one device into factory-reset pairing mode, verify the interview, assign a non-sensitive friendly name, and disable joining again.

## Backup scope

Private operational backups should include:

- Home Assistant configuration and storage
- Mosquitto password file and persistence database
- Zigbee2MQTT configuration, database, state, and coordinator backup
- Compose file and local environment values

Backups are operational data and must not be pushed to this public repository.

## Common checks

### Coordinator missing

~~~bash
lsusb
ls -l /dev/serial/by-id/
docker inspect zigbee2mqtt --format '{{json .HostConfig.Devices}}'
~~~

### MQTT unavailable

~~~bash
docker compose ps mosquitto
docker logs mosquitto --tail 100
ss -lntup | grep ':1883'
~~~

### Device absent from Home Assistant

Confirm that:

1. Zigbee2MQTT is online.
2. Home Assistant is connected to MQTT.
3. `homeassistant.enabled` is true in Zigbee2MQTT.
4. The device completed its interview.
5. Home Assistant has processed the MQTT discovery messages.

## Home Assistant Container limitation

Home Assistant Container does not include the Supervisor or add-on store. Mosquitto and Zigbee2MQTT are therefore managed as independent Compose services.
