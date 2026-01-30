# OwO Tool Box

[English Documentation](README.md)

**OwO Tool Box** 是一个基于 Flutter 构建的多功能系统工具箱应用。它旨在为系统管理员和开发者提供一套实用的工具，目前核心功能为强大的 **主机监控 (Host Monitor)** 模块。

## ✨ 功能特性

### 🖥️ 主机监控 (Host Monitor)
一个用于监控远程服务器和主机的综合工具。
- **实时监控**：实时查看主机状态（在线、离线、认证失败）。
- **TCP 连接管理**：强大的 TCP 连接处理，支持自动重连策略。
- **安全认证**：基于令牌 (Token) 的认证系统，确保与主机的通信安全。
- **命令执行**：直接向已连接的主机发送命令。
- **批量操作**：同时监控和更新多个主机的状态。
- **警报历史**：记录警报和状态变更历史。
- **GeoIP 集成**：可视化主机地理位置信息。

### 🔧 系统工具 (System Tools)
一套现代化、直观的 Windows 系统实用工具集。
- **定时关机**：灵活的系统关机计划设置
  - 按时长设置关机（小时、分钟、秒）
  - 按具体日期时间设置关机
  - 快捷操作按钮（10分钟、30分钟、1小时、2小时）
  - 实时倒计时显示
  - 随时取消已设置的关机计划
- **电源管理**：轻松管理 Windows 电源计划
  - 查看当前活动的电源计划
  - 快速切换电源模式（高性能、平衡、节能）
  - 浏览并激活所有可用的电源计划
  - 系统睡眠和休眠功能
  - 精美的激活状态视觉指示器

### 🚀 核心特性
- **跨平台支持**：针对 Windows, macOS, Linux, Android 和 iOS 进行了优化。
- **响应式设计**：自适应布局，在桌面端和移动端都能提供流畅体验。
- **主题系统**：内置亮色和暗色模式支持，可跟随系统主题自动切换。
- **国际化**：完整的多语言支持（英文、简体中文、繁体中文、德语）。
- **定制 UI**：为桌面端提供定制的标题栏和窗口管理体验。

## 📸 应用截图

### 主机监控
| 主机监控 | 监控设置 |
|:---:|:---:|
| <img src="assets/images/host_monitor_page.png" width="400"/> | <img src="assets/images/host_monitor_settings_page.png" width="400"/> |

| 主机详情 (概览) | 主机详情 (图表) |
|:---:|:---:|
| <img src="assets/images/host_details_page-1.png" width="400"/> | <img src="assets/images/host_details_page-2.png" width="400"/> |

| 主机详情 (终端) | 主机详情 (信息) |
|:---:|:---:|
| <img src="assets/images/host_details_page-3.png" width="400"/> | <img src="assets/images/host_details_page-4.png" width="400"/> |

### 系统工具
| 定时关机 | 电源管理 |
|:---:|:---:|
| <img src="assets/images/shutdown-page.png" width="400"/> | <img src="assets/images/power-management-page.png" width="400"/> |

### 设置与偏好
| 设置 | 主题设置 |
|:---:|:---:|
| <img src="assets/images/settings_page.png" width="400"/> | <img src="assets/images/theme_settings_page.png" width="400"/> |

| 通知历史 | Windows 通知 |
|:---:|:---:|
| <img src="assets/images/notification_history_page.png" width="400"/> | <img src="assets/images/windows_notification.png" width="400"/> |

## 🛠️ 技术栈

- **框架**: [Flutter](https://flutter.dev/)
- **状态管理**: [Provider](https://pub.dev/packages/provider)
- **依赖注入**: [GetIt](https://pub.dev/packages/get_it)
- **网络**: TCP Sockets, HTTP
- **存储**: Shared Preferences, Flutter Secure Storage
- **UI 组件**: FlChart, FlexColorPicker, WindowManager

## 📂 项目结构

```
lib/
├── apps/               # 独立的功能模块
│   ├── host_monitor/   # 主机监控模块
│   └── system_tools/   # 系统工具模块 (仅限 Windows)
├── core/               # 核心工具和共享组件
│   ├── constants/      # 应用常量
│   ├── i18n/           # 国际化文件
│   ├── layouts/        # 响应式布局封装
│   ├── models/         # 共享数据模型
│   ├── providers/      # 全局状态提供者
│   ├── services/       # 核心服务
│   ├── theme/          # 主题配置
│   └── widgets/        # 可复用组件
├── pages/              # 通用应用页面 (设置, 关于)
├── app.dart            # 应用入口和配置
└── main.dart           # 应用程序主入口
```

## 🚀 快速开始

### 环境要求
- [Flutter SDK](https://flutter.cn/docs/get-started/install) (建议版本 3.9.2 或更高)
- Dart SDK

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/Tommy131/OwO-Tool-Box.git owo_tool_box
   cd owo_tool_box
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 在 Windows 上运行
   flutter run -d windows

   # 在 Android 上运行
   flutter run -d android
   ```

## 🤝 贡献指南

欢迎提交 Pull Request 来贡献代码！

1. Fork 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 📄 许可证

本项目基于 MIT 许可证开源 - 详情请参阅 LICENSE 文件。

---
*Built with ❤️ by the OwO Team*
