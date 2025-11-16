# 🛠️ OwO! Tool Box

Flutter 构建的现代化跨平台应用模板，支持响应式布局、多语言切换与桌面窗口管理。适用于 Windows、macOS、Linux、Android 和 iOS。

---

## 🚀 核心特性

### 💻 多平台支持

- ✅ 桌面平台（Windows、macOS、Linux）
- ✅ 移动平台（Android、iOS）
- ✅ 网页端支持（Web 可扩展）

### 📐 响应式布局引擎

基于 `ResponsiveBuilder` 和 `LayoutBuilder` 组件，自动适配：

- 📱 `MobileLayout`: 小屏幕
- 💻 `DesktopLayout`: 大屏幕
- 🧾 `TabletLayout`: 中等尺寸屏幕
- 使用 `responsive_break_points.dart` 定义布局切换临界点

```dart
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
);
```

---

### 🧭 桌面窗口控制（bitsdojo\_window）

通过 `bitsdojo_window` 实现：

- 固定初始窗口尺寸（如 1200x800）
- 设置窗口标题 `OwO! Tool Box`
- 控制最小尺寸
- 居中显示窗口

```dart
if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  doWhenWindowReady(() {
    appWindow
      ..minSize = Size(800, 600)
      ..size = Size(1200, 800)
      ..alignment = Alignment.center
      ..title = 'OwO! Tool Box'
      ..show();
  });
}
```

---

### 🌍 国际化（i18n）

项目自定义了一套轻量的国际化系统：

- `AppLocalization` 提供翻译接口
- 使用 `LanguageConfig` 管理语言映射
- `localization_keys.dart` 中定义全部翻译键
- 支持热切换语言（基于 Provider 的 `LocaleProvider`）

#### 支持语言

- 🇨🇳 简体中文（zh\_CN）
- 🇺🇸 英语（en\_US）
- 🇩🇪 德语（de\_DE）
- 🇪🇸 西班牙语（es\_ES）
- 🇫🇷 法语（fr\_FR）
- 🇯🇵 日语（ja\_JP）

示例用法：

```dart
AppLocalization.of(context).translate('welcome');
```

---

### 🎨 动态主题管理

通过 `ThemeProvider`：

- 支持亮/暗主题动态切换
- 可自定义 MaterialColor 配色
- 响应系统主题设置

---

### 📦 状态管理（Provider）

使用 `provider` 管理应用状态，如：

- `ThemeProvider`: 主题切换
- `LocaleProvider`: 语言切换
- `NavigationProvider`: 导航控制
- `MatrixRainProvider`: 自定义背景效果
- `HostMonitorProvider`: 设备监控数据管理

---

## 📁 项目结构

```bash
lib/
├── app.dart                    # App Widget 构建入口
├── main.dart                   # 程序主入口及窗口初始化
├── core/
│   ├── layouts/                # 多平台布局支持
│   ├── i18n/                   # 国际化支持（语言包、翻译逻辑）
│   ├── providers/              # 状态管理
│   ├── constants/              # 全局常量
├── host_monitor/               # 主机监控逻辑（网络/系统状态）
├── screens/                    # 页面与导航控制器
```

---

## 📲 快速启动

确保你已安装 Flutter SDK，并配置好开发环境。

```bash
flutter pub get
flutter run -d windows   # 也可以替换为 macos, linux, android, ios 等平台
```

---

## 📌 依赖列表（部分）

- `flutter`
- `provider`
- `bitsdojo_window` （桌面窗口管理）
- `flutter_localizations`

---

## 🧪 推荐改进（如为模板使用）

- ✅ 增加接口服务接入层（如 Dio）
- ✅ 添加单元测试 & 集成测试支持
- ✅ 拓展国际化格式支持为 `.arb` 或 `.json`
- ✅ 加入模块化导航路由系统（如 `go_router`）

---

## 📜 许可证

MIT License © OwO! Tool Box Team
