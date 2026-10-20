## 1.2.0
* **GATT Server (Peripheral Mode):**
  * Create, edit, and manage GATT server profiles with services and characteristics.
  * Run a peripheral server with advertising and add or remove services at runtime.
  * Import and export profiles as JSON files.

* **Device Fingerprint:**
  * One-tap capture: advertisements collected over a 60s window (identical ads consolidated with count, first/last seen and RSSI range), discovered services, all readable characteristic values, and a rolling-ID check performed after reconnecting.
  * Copy the full report to the clipboard; capture can be stopped at any point.

* **Logs & Advertisements:**
  * Add custom log entries, clear individual entries, and auto-scroll to newest entries with a persisted toggle.
  * Include the characteristic UUID in read, write, and error log entries.
  * Copy advertisements with an optional RSSI column.
  * Clearer, human-readable formatting for services and advertisement data.

* **Scanning & Filtering:**
  * Filter characteristics by UUID text (case- and hyphen-insensitive).
  * Select the new Auto queue type from the drawer.

* **UI:**
  * Renamed the app to UniversalBle Explorer across all platforms with a refreshed icon.
  * Fixed alignment of the search field, card headers, per-log clear buttons, and the Write button.
  * Show a clear placeholder for empty services and fix duplicate keys in the services list.

* **Platform & Dependencies:**
  * Migrated to universal_ble 3.0.
  * Upgraded file_picker to 12.0.0 and simplified file import/export.
  * Removed CocoaPods from the iOS and macOS projects and updated Flutter/platform requirements.
  * Handle BLE errors such as a device no longer being found instead of leaving them unhandled.

## 1.1.0
* **Services & Characteristics:**
  * Add property filtering for characteristics with visual filter chips
  * Add navigation buttons to navigate between characteristics (previous/next)
  * Improve service sorting (favorites first, system services last)
  * Enhance services list UI with better filtering and navigation
  * Improve format for discovered services to be more detailed and human-readable
  * Move "Copy Services" button to Services panel header

* **Company & Manufacturer Data:**
  * Display company name based on company identifier from manufacturer data
  * Show and filter by company name in device list
  * Enhanced search functionality - now supports searching by company name

* **Scanning & Device Discovery:**
  * Improved scan button visibility - converted to prominent filled button with text label
  * Enhanced "no devices found" state with explicit "Start Scan" call-to-action button
  * Display RSSI values in device details
  * Show last advertisement (name, RSSI, timestamp) on scan screen and list of received ads on detail screen; both flash on new advertisement. Scanning continues when opening a device.

* **UI & Navigation:**
  * Moved search field to app bar header for better accessibility
  * Moved queue type settings to drawer menu as expandable section
  * Added tooltip to Bluetooth availability icon (tap to view on mobile)
  * Improved overall UI layout and navigation flow

* **Functionality:**
  * Add support for `autoConnect` parameter
  * Persist filters across app sessions
  * Fix clear log button functionality

## 1.0.0
* Initial release
