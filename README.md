Universal BLE

Universal BLE is an open-source developer tool for exploring and testing Bluetooth Low Energy (BLE) devices. It empowers developers, engineers, and hobbyists to discover, connect, and debug BLE devices with a consistent cross-platform experience.

Built on the universal_ble Flutter plugin (https://pub.dev/packages/universal_ble) — one of the most comprehensive cross-platform BLE solutions available.

Scanner app screenshot: assets/scanner-screenshot.png


Download

Universal BLE — [App Store](https://apps.apple.com/app/id6756538573) · [Play Store](https://play.google.com/store/apps/details?id=com.navideck.universalble) · [Web](https://navideck.github.io/UniversalBle-Explorer/)

<a href="https://apps.apple.com/app/id6756538573"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store"></a>
<a href="https://play.google.com/store/apps/details?id=com.navideck.universalble"><img src="assets/play-badge.svg" alt="Get it on Google Play" height="40"></a>


Key Features

Device Discovery

  Real-time scanning — Discover nearby BLE devices with live results; scanning continues when you open a device's detail screen
  Flexible filters — Filter by service UUIDs, name prefix, or manufacturer data (comma- or newline-separated)
  Saved filter presets — Save, rename, and reuse filter combinations; filters persist across app sessions
  Search — Search devices by name or by company name (resolved from manufacturer data via Bluetooth company identifiers)
  Sort options — Sort the device list by RSSI, last seen, or name
  Company identification — Show company name from manufacturer data using the Bluetooth SIG company identifier list
  RSSI and advertisements — View signal strength (RSSI), last advertisement (name, RSSI, timestamp), and a list of received ads that flashes on new advertisements
  System devices — On supported platforms, view and connect to devices already connected at the system level (with optional service filter)

Connection Management

  Connect and disconnect — Connect to and disconnect from BLE peripherals with one tap
  Auto-reconnect — Optional auto-connect for reconnection when a device becomes available again
  Connection state — Real-time connection state updates
  Multiple connections — Support for multiple simultaneous device connections

Service & Characteristic Exploration

  GATT discovery — Discover all services and characteristics on connected devices with detailed, human-readable formatting
  Favorite services — Mark services as favorites; they appear first in the list (system services last)
  Property filters — Filter characteristics by property (read, write, notify, indicate, etc.) with visual filter chips
  Text search — Filter characteristics by UUID text (e.g. "2a19"), matching regardless of case or hyphens
  Navigation — Previous/next buttons to move between characteristics without collapsing the list
  Copy services — Copy the full discovered GATT layout (e.g. for documentation or debugging) from the Services panel header

Data Operations

  Read — Read characteristic values on demand
  Write — Write data to characteristics (with or without response)
  Subscribe — Subscribe to notifications/indications per characteristic or "subscribe to all" for notifiable characteristics
  Live updates — Incoming values are shown in the logs with timestamps; clear or copy the full log

Pairing & Security

  Pair and unpair — Initiate pairing and unpair devices when supported
  Pairing state — Monitor pairing state changes in real time

Advanced & Developer Options

  MTU — Request a larger MTU (e.g. 247) for better throughput where supported
  Device fingerprint — One tap captures a consolidated device fingerprint: advertisements collected over a 60s window (identical ads collapsed with count, first/last seen and RSSI range), discovered GATT services, all readable characteristic values, and a rolling-ID check that reconnects to detect random/private address changes; copy the full report to the clipboard
  Command queue — Choose queue type in the drawer: Global (single queue), Per Device, or None (parallel)
  Configurable timeout — Set operation timeout (e.g. 10 seconds) for all BLE operations
  Logs — Operation log with copy-all and per-entry clear; comprehensive error handling with detailed codes
  UUID formats — Accepts common UUID string formats (e.g. with or without hyphens)

UI & Cross-Platform

  Responsive layout — Adapts to mobile, tablet, and desktop (e.g. breakpoints at 600px and 1000px)
  Bluetooth status — Bluetooth availability icon with tooltip (tap on mobile to see state)
  Permissions — Guided permission flow where required (e.g. location for BLE on Android); re-checks on app resume
  Cross-platform — Built with the universal_ble plugin for consistent behavior across supported platforms


Perfect For

  Developers building BLE-enabled applications
  Engineers testing and debugging BLE devices
  Hobbyists exploring IoT and smart device capabilities
  Students learning about Bluetooth Low Energy technology
  QA teams validating BLE device functionality


Why Universal BLE?

Universal BLE is built on the open-source universal_ble Flutter plugin (https://github.com/Navideck/universal_ble), one of the most comprehensive cross-platform BLE solutions available. With support for all major platforms and a unified API, you can develop and test BLE applications with confidence.

Whether you're developing a new BLE product, debugging an existing device, or simply exploring Bluetooth Low Energy, Universal BLE provides the tools you need.

Open Source & Free

This app is built on open-source technology and is free to use. The underlying plugin is available under the BSD 3-Clause License, making it suitable for both commercial and personal projects.
