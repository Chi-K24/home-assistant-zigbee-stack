# Portfolio Summary

## Short description

Built a containerized home automation platform on a Raspberry Pi 5 using Home Assistant, Mosquitto, Zigbee2MQTT, and a Sonoff ZBDongle-P coordinator. The system combines local Zigbee control, authenticated MQTT messaging, Home Assistant discovery, persistent USB mapping, radio-channel planning, and documented firmware recovery.

## Resume bullets

- Designed and deployed a three-service Docker Compose home automation stack using Home Assistant, Mosquitto, and Zigbee2MQTT on ARM64 Linux.
- Integrated a TI CC2652P-based Sonoff Zigbee coordinator through a persistent USB device path and validated coordinator backup and restoration.
- Planned Zigbee channel 25 around the observed 2.4 GHz Wi-Fi environment to reduce radio interference.
- Upgraded coordinator firmware with a private pre-flash backup and verified restored Zigbee state, MQTT reconnection, and Home Assistant discovery.
- Created a public-safe configuration model that excludes credentials, device identities, network keys, databases, logs, and coordinator backups.

## Suggested portfolio card

**Local Home Automation**

A Raspberry Pi 5 automation stack that bridges Home Assistant to Zigbee devices through authenticated MQTT and a Sonoff coordinator. Built for local control, reliable recovery, and maintainable container operations.

**Technologies:** Raspberry Pi · Linux · Docker Compose · Home Assistant · MQTT · Zigbee2MQTT · Sonoff ZBDongle-P

**Repository:** https://github.com/Chi-K24/home-assistant-zigbee-stack

## Interview talking points

- Why Home Assistant uses host networking while Zigbee2MQTT uses a private bridge
- Why the MQTT port is bound to loopback rather than the LAN
- Why a persistent USB path matters after reboots
- How Zigbee and 2.4 GHz Wi-Fi channel selection interact
- How coordinator firmware and Zigbee network state are separated
- How public documentation can remain reproducible without leaking operational secrets
