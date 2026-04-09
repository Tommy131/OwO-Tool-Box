import '../core/module_registry/module_registry.dart';
import '../core/settings_pages/about_page.dart';

// 导入所有业务模块
import 'log_viewer/log_viewer_module.dart';
import 'cloudflare_dns/cloudflare_dns.dart';
import 'common_pages/common_pages.dart';
import 'host_monitor/host_monitor.dart';
import 'dev_tools/dev_tools.dart';
import 'network_tools/network_tools.dart';
import 'system_tools/system_tools.dart';
import 'ssl_certificate_manager/ssl_certificate_manager.dart';

/// 模块集中注册入口
/// 负责在应用启动时注册所有业务模块，以及处理全局清理逻辑
class ModulesRegisterEntry {
  /// 执行所有模块的注册操作
  static void registerAll() {
    final registry = ModuleRegistry();

    // 0. 注册基础核心组件的默认内容
    AboutPage.registerDefaults();

    // 1. 注册核心业务模块
    registry.registerModule(LogViewerModule());
    registry.registerModule(CommonPages());
    registry.registerModule(HostMonitor());
    registry.registerModule(CloudflareDns());
    registry.registerModule(DevTools());
    registry.registerModule(SystemTools());
    registry.registerModule(NetworkTools());
    registry.registerModule(SslCertificateManager());

    // 2. 初始化所有已注册模块
    registry.initializeAll();

    // 4. 注册全局清理回调
    _registerGlobalCleanup(registry);
  }

  /// 注册应用退出时的全局清理逻辑
  static void _registerGlobalCleanup(ModuleRegistry registry) {
    // 示例代码
    /* registry.registerCleanup(() async {
      debugPrint('[Cleanup] 正在清理资源...');
    }); */
  }
}
