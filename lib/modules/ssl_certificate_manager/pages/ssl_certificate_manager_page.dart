import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/localization_service.dart';
import '../../../core/widgets/navigation/module_side_nav.dart';
import '../localization/localization_keys.dart';
import '../providers/ssl_certificate_manager_provider.dart';

import 'tabs/audit_log_tab.dart';
import 'tabs/certificate_issue_tab.dart';
import 'tabs/certificate_list_tab.dart';
import 'tabs/csr_import_tab.dart';
import 'tabs/init_guide_tab.dart';
import 'tabs/openssl_template_tab.dart';
import 'tabs/storage_config_tab.dart';

class SslCertificateManagerPage extends StatefulWidget {
  const SslCertificateManagerPage({super.key});

  @override
  State<SslCertificateManagerPage> createState() =>
      _SslCertificateManagerPageState();
}

class _SslCertificateManagerPageState extends State<SslCertificateManagerPage> {
  bool _isNavExpanded = false;
  static const double _compactNavWidth = 68;
  static const double _expandedNavWidth = 200;
  static const double _navHeaderHeight = 60;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final useCompactNav = screenWidth < 1100;
    final provider = context.watch<SslCertificateManagerProvider>();
    final primaryColor = theme.colorScheme.primary;

    if (provider.isLoading && !provider.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!provider.isInitialized) {
      return const InitGuideTab();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveSidebarShell(
        isCompact: useCompactNav,
        isExpanded: _isNavExpanded,
        compactWidth: _compactNavWidth,
        expandedWidth: _expandedNavWidth,
        onCollapse: () => setState(() => _isNavExpanded = false),
        content: IndexedStack(
          index: provider.selectedNavIndex,
          children: const [
            CertificateListTab(),
            CertificateIssueTab(),
            OpenSslTemplateTab(),
            StorageConfigTab(),
            CsrImportTab(),
            AuditLogTab(),
          ],
        ),
        buildPanel:
            ({
              required bool useCompactNav,
              required bool showLabel,
              required bool isFloating,
            }) => _buildNavPanel(
              provider: provider,
              primaryColor: primaryColor,
              useCompactNav: useCompactNav,
              showLabel: showLabel,
              isFloating: isFloating,
            ),
      ),
    );
  }

  Widget _buildNavPanel({
    required SslCertificateManagerProvider provider,
    required Color primaryColor,
    required bool useCompactNav,
    required bool showLabel,
    bool isFloating = false,
  }) {
    final width = showLabel ? _expandedNavWidth : _compactNavWidth;
    return SidebarPanelContainer(
      width: width,
      isFloating: isFloating,
      onBlankTap: isFloating
          ? () => setState(() => _isNavExpanded = false)
          : null,
      topSlot: !showLabel
          ? _buildNavToggle(showLabel: showLabel, useCompactNav: useCompactNav)
          : (isFloating
                ? const SizedBox(height: _navHeaderHeight)
                : const SizedBox(height: 8)),
      children: [
        SidebarNavItemTile(
          icon: Icons.badge_outlined,
          label: LocalizationKeys.certList.tr(context),
          isSelected: provider.selectedNavIndex == 0,
          onTap: () => _onNavSelect(provider, 0, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
        SidebarNavItemTile(
          icon: Icons.note_add_outlined,
          label: LocalizationKeys.certIssue.tr(context),
          isSelected: provider.selectedNavIndex == 1,
          onTap: () => _onNavSelect(provider, 1, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
        SidebarNavItemTile(
          icon: Icons.code_outlined,
          label: LocalizationKeys.opensslTemplate.tr(context),
          isSelected: provider.selectedNavIndex == 2,
          onTap: () => _onNavSelect(provider, 2, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
        SidebarNavItemTile(
          icon: Icons.folder_open_outlined,
          label: LocalizationKeys.storageConfig.tr(context),
          isSelected: provider.selectedNavIndex == 3,
          onTap: () => _onNavSelect(provider, 3, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
        SidebarNavItemTile(
          icon: Icons.upload_file_outlined,
          label: LocalizationKeys.importCsr.tr(context),
          isSelected: provider.selectedNavIndex == 4,
          onTap: () => _onNavSelect(provider, 4, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
        SidebarNavItemTile(
          icon: Icons.history_outlined,
          label: LocalizationKeys.auditLog.tr(context),
          isSelected: provider.selectedNavIndex == 5,
          onTap: () => _onNavSelect(provider, 5, useCompactNav, showLabel),
          primaryColor: primaryColor,
          showLabel: showLabel,
        ),
      ],
    );
  }

  Widget _buildNavToggle({
    required bool showLabel,
    required bool useCompactNav,
  }) {
    return SidebarToggleButton(
      showLabel: showLabel,
      enabled: useCompactNav,
      isExpanded: _isNavExpanded,
      onPressed: () => setState(() => _isNavExpanded = !_isNavExpanded),
    );
  }

  void _onNavSelect(
    SslCertificateManagerProvider provider,
    int index,
    bool useCompactNav,
    bool showLabel,
  ) {
    provider.selectNav(index);
    if (useCompactNav && showLabel) {
      setState(() => _isNavExpanded = false);
    }
  }
}
