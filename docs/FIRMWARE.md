# ZBDongle-P Firmware Runbook

This runbook records the maintenance process used for the Sonoff ZBDongle-P. It is a TI CC2652P / Z-Stack coordinator. It is not the Silicon Labs-based ZBDongle-E.

> Flashing the wrong hardware family or router firmware can make the coordinator unavailable. Verify the model, chipset, role, and image before writing anything.

## Verified project state

| Item | Value |
| --- | --- |
| Adapter | Sonoff ZBDongle-P |
| Zigbee2MQTT adapter type | `zstack` |
| Coordinator type | `ZStack3x0` |
| Previous revision | `20230507` |
| Verified revision | `20250321` |
| Role | Coordinator |

The revision above is the version validated in this project, not a standing recommendation to flash every working coordinator.

## Before flashing

1. Confirm that Zigbee2MQTT starts and can communicate with the adapter.
2. Keep a private copy of the entire Zigbee2MQTT data directory.
3. Confirm that `coordinator_backup.json` exists in the private backup.
4. Record the current firmware revision from the startup log.
5. Stop Zigbee2MQTT cleanly:

~~~bash
docker stop zigbee2mqtt
docker inspect -f '{{.State.Status}}' zigbee2mqtt
~~~

6. Confirm the container reports `exited` before unplugging the coordinator.

Never commit the backup archive or coordinator backup to a public repository. They contain Zigbee network identity material.

## Flashing on Windows

1. Connect the ZBDongle-P directly to the Windows computer.
2. Open the [Sonoff Dongle Flasher](https://dongle.sonoff.tech/sonoff-dongle-flasher/) in a supported browser.
3. Select the detected ZBDongle-P.
4. Select coordinator firmware for the P model and TI CC2652P family.
5. Complete the flash and wait for verification before unplugging.

Do not choose ZBDongle-E, EZSP, Ember, router, or OpenThread firmware for this coordinator.

## Restore and verify

Reconnect the dongle to the Raspberry Pi and confirm the persistent path exists:

~~~bash
ls -l /dev/serial/by-id/
~~~

Start the bridge and inspect the fresh log:

~~~bash
docker start zigbee2mqtt
docker logs zigbee2mqtt --since 2m
~~~

The successful maintenance window produced these validation signals:

~~~text
Serialport opened
zigbee-herdsman started (restored)
Coordinator firmware revision: 20250321
Connected to MQTT server
bridge/state: online
Zigbee2MQTT started
~~~

Also verify:

- The frontend loads
- Existing devices remain present
- A known device responds
- MQTT discovery still exposes devices in Home Assistant

## Rollback principle

If the adapter does not start after flashing, stop repeated writes and re-check the exact adapter family and image. Preserve the private pre-flash archive. Firmware rollback and state restoration should be treated as separate operations.
