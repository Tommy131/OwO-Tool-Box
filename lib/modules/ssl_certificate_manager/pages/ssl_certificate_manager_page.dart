import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/widgets/common/dialog.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/widgets/navigation/module_side_nav.dart';
import '../localization/localization_keys.dart';
import '../models/ssl_models.dart';
import '../providers/ssl_certificate_manager_provider.dart';

part 'sections/ssl_page_init_section.dart';
part 'sections/ssl_page_certificate_section.dart';
part 'sections/ssl_page_openssl_template_section.dart';
part 'sections/ssl_page_storage_section.dart';
part 'sections/ssl_page_shared_widgets_section.dart';
part 'sections/ssl_page_diff.dart';
part 'sections/ssl_page_csr_import_section.dart';
part 'sections/ssl_page_audit_log_section.dart';

class SslCertificateManagerPage extends StatefulWidget {
  const SslCertificateManagerPage({super.key});

  @override
  State<SslCertificateManagerPage> createState() =>
      _SslCertificateManagerPageState();
}

class _SslCertificateManagerPageState extends State<SslCertificateManagerPage> {
  final ScrollController _cnfEditorScrollController = ScrollController();
  final TextEditingController _pfxPasswordController = TextEditingController();
  bool _isNavExpanded = false;
  static const double _compactNavWidth = 68;
  static const double _expandedNavWidth = 200;
  static const double _navHeaderHeight = 60;
  int _issueStep = 0;
  bool _showRootCaPassword = false;
  bool _showChallengePassword = false;

  void _refreshPage([VoidCallback? updater]) {
    if (!mounted) return;
    setState(() {
      updater?.call();
    });
  }

  void _changeIssueStep(int delta) {
    _refreshPage(() {
      _issueStep += delta;
    });
  }

  void _resetIssueStep() {
    _refreshPage(() {
      _issueStep = 0;
    });
  }

  void _toggleRootCaPasswordVisibility() {
    _refreshPage(() {
      _showRootCaPassword = !_showRootCaPassword;
    });
  }

  void _toggleChallengePasswordVisibility() {
    _refreshPage(() {
      _showChallengePassword = !_showChallengePassword;
    });
  }

  @override
  void dispose() {
    _cnfEditorScrollController.dispose();
    _pfxPasswordController.dispose();
    super.dispose();
  }

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
      return _buildInitGuide(provider);
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
          children: [
            _buildCertificateList(provider),
            _buildIssueTab(provider),
            _buildOpenSslTemplateTab(provider),
            _buildStorageTab(provider),
            _buildCsrImportTab(provider),
            _buildAuditLogTab(provider),
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
