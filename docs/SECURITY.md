# Security Model

## Public repository boundary

This repository contains reproducible definitions and sanitized documentation. It is not a backup of the running system.

| Never publish | Reason |
| --- | --- |
| `.env` | Contains local credentials and device paths |
| Home Assistant `.storage` | Contains authentication and integration state |
| `secrets.yaml` | Contains user-managed Home Assistant secrets |
| Mosquitto `password_file` | Contains broker password hashes |
| Zigbee2MQTT `configuration.yaml` | Can contain MQTT credentials and Zigbee network identity |
| `coordinator_backup.json` | Contains coordinator and network identity material |
| Zigbee2MQTT database and state | Contains device identifiers and topology |
| Home Assistant databases and logs | Can expose names, behavior, addresses, and tokens |
| Router or dashboard screenshots | Can expose IPs, SSIDs, MACs, passwords, and device IDs |

## Runtime controls

- Mosquitto rejects anonymous clients.
- MQTT is published only to host loopback.
- Zigbee2MQTT reaches MQTT over a private Compose bridge.
- Home Assistant and Zigbee2MQTT use separate broker accounts.
- The Zigbee coordinator is mapped only to Zigbee2MQTT.
- Zigbee joining remains disabled outside intentional pairing windows.
- Container restart policies restore services after reboot.

## Secret handling

1. Copy `.env.example` to `.env` locally.
2. Generate unique passwords instead of reusing router, Wi-Fi, or GitHub credentials.
3. Create Mosquitto credentials with `mosquitto_passwd`.
4. Keep Home Assistant integration credentials in its local runtime storage.
5. Store Zigbee network keys only in the ignored runtime configuration and private backups.
6. Run `scripts/sanitize-check.sh` before every public push.

If a real secret enters Git history, removing it in a later commit is not sufficient. Rotate the credential immediately, then rewrite the affected history if the repository must be cleaned.

## External access

This example does not publish Home Assistant, Zigbee2MQTT, or MQTT directly to the internet. Remote access requires a separately reviewed HTTPS, VPN, or managed-cloud design.

## Cloud-connected devices

The Smart Life / Tuya integration introduces a vendor-cloud trust dependency that is separate from the local Zigbee path. Devices should be evaluated for electrical safety, account security, and acceptable cloud dependence before regular use.

## Screenshot review

Use [SCREENSHOTS.md](SCREENSHOTS.md) before publishing any UI image. Crop first and redact at the pixel level; do not rely on filenames or surrounding text to hide sensitive fields.
