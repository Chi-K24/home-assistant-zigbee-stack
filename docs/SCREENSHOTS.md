# Safe Screenshot Checklist

Screenshots make the project easier to understand, but home automation and router interfaces expose more identifying data than typical application screenshots.

## Good showcase images

- Home Assistant dashboard with one demo light card
- Zigbee2MQTT device controls after identifiers are removed
- A sanitized Docker Compose status table
- A cropped coordinator firmware revision
- A simple physical photo of the Raspberry Pi and dongle with labels obscured where needed

## Redact before uploading

- Public and private IP addresses
- Wi-Fi names and passwords
- Router and device MAC addresses
- Zigbee IEEE addresses
- USB serial numbers
- Home Assistant user names
- Physical room names if personally identifying
- GPS/location data and notification contents
- Cloud account emails, IDs, tokens, or QR codes
- Browser bookmarks, tabs, and profile avatars

## Process

1. Duplicate the original image.
2. Crop to the exact feature being demonstrated.
3. Cover sensitive values with opaque blocks; blur can remain partially readable.
4. Remove image metadata when practical.
5. Inspect the final exported pixels at full resolution.
6. Give the file a neutral descriptive name.
7. Run the repository sanitization check.
8. Review the staged Git diff before pushing.

Do not reuse router screenshots that displayed credentials, WAN addressing, or full device tables. Capture new purpose-built images instead.
