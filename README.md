# OwO Tool Box

[中文文档](README_ZH.md)

**OwO Tool Box** is a multifunctional system tools application built with Flutter. It is designed to provide a suite of utilities for system administrators and developers, starting with a powerful **Host Monitor** module.

## ✨ Features

### 🖥️ Host Monitor
A comprehensive tool for monitoring remote servers and hosts.
- **Real-time Monitoring**: Check the status of your hosts (Online, Offline, Authentication Failed) in real-time.
- **TCP Connection Management**: Robust TCP connection handling with automatic reconnection strategies.
- **Secure Authentication**: Token-based authentication system for secure communication with your hosts.
- **Command Execution**: Send commands directly to your connected hosts.
- **Batch Operations**: Monitor and update the status of multiple hosts simultaneously.
- **Alert History**: Keep track of alerts and status changes.
- **GeoIP Integration**: Visualize host locations.

### 🔧 System Tools
A suite of essential Windows system utilities with a modern, intuitive interface.
- **Shutdown Timer**: Schedule system shutdown with flexible timing options
  - Set shutdown by duration (hours, minutes, seconds)
  - Set shutdown at a specific date and time
  - Quick action buttons (10 min, 30 min, 1 hour, 2 hours)
  - Real-time countdown display
  - Cancel scheduled shutdown anytime
- **Power Management**: Manage Windows power plans with ease
  - View current active power plan
  - Quick switch between power modes (High Performance, Balanced, Power Saver)
  - Browse and activate all available power plans
  - System sleep and hibernate functions
  - Beautiful visual indicators for active modes

### 🚀 Core Features
- **Cross-Platform**: Optimized for Windows, macOS, Linux, Android, and iOS.
- **Responsive Design**: Adaptive layouts that work seamlessly on both desktop and mobile screens.
- **Theme System**: Built-in support for Light and Dark modes, with system theme synchronization.
- **Internationalization**: Full multi-language support (English, Chinese Simplified, Chinese Traditional, German).
- **Custom UI**: Polished desktop experience with custom title bars and window management.

## 📸 Screenshots

### Host Monitor
| Host Monitor | Host Monitor Settings |
|:---:|:---:|
| <img src="assets/images/host_monitor_page.png" width="400"/> | <img src="assets/images/host_monitor_settings_page.png" width="400"/> |

| Host Details (Overview) | Host Details (Graphs) |
|:---:|:---:|
| <img src="assets/images/host_details_page-1.png" width="400"/> | <img src="assets/images/host_details_page-2.png" width="400"/> |

| Host Details (Terminal) | Host Details (Info) |
|:---:|:---:|
| <img src="assets/images/host_details_page-3.png" width="400"/> | <img src="assets/images/host_details_page-4.png" width="400"/> |

### System Tools
| Shutdown Timer | Power Management |
|:---:|:---:|
| <img src="assets/images/shutdown-page.png" width="400"/> | <img src="assets/images/power-management-page.png" width="400"/> |

### Settings & Preferences
| Settings | Theme Settings |
|:---:|:---:|
| <img src="assets/images/settings_page.png" width="400"/> | <img src="assets/images/theme_settings_page.png" width="400"/> |

| Notification History | Windows Notification |
|:---:|:---:|
| <img src="assets/images/notification_history_page.png" width="400"/> | <img src="assets/images/windows_notification.png" width="400"/> |

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Dependency Injection**: [GetIt](https://pub.dev/packages/get_it)
- **Networking**: TCP Sockets, HTTP
- **Storage**: Shared Preferences, Flutter Secure Storage
- **UI Components**: FlChart, FlexColorPicker, WindowManager

## 📂 Project Structure

```
lib/
├── apps/               # Independent functional modules
│   ├── host_monitor/   # Host Monitor module
│   └── system_tools/   # System Tools module (Windows only)
├── core/               # Core utilities and shared components
│   ├── constants/      # App constants
│   ├── i18n/           # Internationalization files
│   ├── layouts/        # Responsive layout wrappers
│   ├── models/         # Shared data models
│   ├── providers/      # Global state providers
│   ├── services/       # Core services
│   ├── theme/          # Theme configuration
│   └── widgets/        # Reusable widgets
├── pages/              # General application pages (Settings, About)
├── app.dart            # App entry point and configuration
└── main.dart           # Application main entry
```

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.9.2 or higher recommended)
- Dart SDK

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tommy131/OwO-Tool-Box.git owo_tool_box
   cd owo_tool_box
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # Run on Windows
   flutter run -d windows

   # Run on Android
   flutter run -d android
   ```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---
*Built with ❤️ by the OwO Team*
