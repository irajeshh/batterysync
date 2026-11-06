# BatterySync

<p align="center">
  <img src="docs/screenshots/iPhone.png" alt="BatterySync on iPhone" width="260" />
  <img src="docs/screenshots/iWatch.png" alt="BatterySync on Apple Watch" width="260" />
</p>

<p align="center"><strong>A focused Apple Watch battery companion for iPhone.</strong><br />Local, private, and built for fast WatchConnectivity experiments.</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20watchOS-111827" alt="Platforms" />
  <img src="https://img.shields.io/badge/data-local--only-16a34a" alt="Local only" />
  <img src="https://img.shields.io/badge/license-private%20prototype-f59e0b" alt="Prototype" />
</p>

## ✨ Features

- 🔋 Watch battery percentage on the Watch and iPhone.
- 📱 iPhone battery percentage on the Watch.
- 📶 Reachability status with a compact colored proximity dot.
- 🔐 Two-character synchronization token on both devices.
- 🔊 Watch token tap → repeated iPhone sound for approximately five seconds.
- 📳 iPhone token tap → repeated Watch haptics for approximately five seconds.
- 🔔 One iPhone sound when the Watch percentage changes.
- ⭕ Watch battery ring tap for an immediate local refresh request.
- 🌑 Dark companion-style interfaces.
- 🧩 WidgetKit target for battery values and the synchronization token.

## 🖼️ Screenshots

### Apple Watch

![BatterySync Apple Watch interface](docs/screenshots/iWatch.png)

### iPhone

![BatterySync iPhone interface](docs/screenshots/iPhone.png)

## 🛠️ Requirements

- Xcode 27.2 or newer.
- iOS and watchOS SDKs installed in Xcode.
- A paired physical iPhone and Apple Watch for WatchConnectivity testing.
- Developer Mode enabled on both devices when installing directly from Xcode.
- The iPhone, Mac, and Watch should be reachable through the same network during wireless development.

## ⚠️ Constraints and limitations

- **Battery precision:** Watch battery values are supplied by watchOS and may be rounded or cached. The app cannot force a more precise reading than the system exposes.
- **Background execution:** A one-second polling timer works while the Watch app is active, but watchOS suspends ordinary apps in the background. Continuous one-second background monitoring is not available to a regular Watch app.
- **Background delivery:** Delivery is controlled by watchOS and may be delayed. Extended runtime sessions, background refresh, or a workout session would be needed for longer execution, each with platform restrictions.
- **Distance:** Exact iPhone-to-Watch distance in meters is not available on the tested Apple Watch SE hardware. The app shows reachability/proximity status instead.
- **Connectivity:** WatchConnectivity messages require paired, reachable devices. Messages can be delayed when either app is suspended or the devices are out of range.
- **Widget installation:** The WidgetKit target requires valid Apple Developer signing, an App Group entitlement, and a successfully installed Widget Extension before it appears in the widget gallery.
- **Privacy:** This prototype is local-only. It does not use Firebase, a server, or cloud storage.

> **Important:** This is a development prototype, not a guaranteed background monitoring service. Do not rely on it for safety-critical alerts.

## 📁 Project structure

- `Phone/` — iPhone SwiftUI app and WatchConnectivity receiver.
- `BatterySync Watch Watch App/` — modern watchOS app target and sender.
- `Watch/` — legacy Watch target sources retained for migration compatibility.
- `Widget/` — WidgetKit source and extension Info.plist.
- `BatterySync.xcodeproj/` — Xcode project.
