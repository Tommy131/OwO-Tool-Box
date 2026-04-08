import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../../../core/widgets/common/dialog.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../localization/localization_keys.dart';
import '../models/ssl_models.dart';
import '../providers/ssl_certificate_manager_provider.dart';

part 'sections/ssl_page_init_section.dart';
part 'sections/ssl_page_certificate_section.dart';
part 'sections/ssl_page_openssl_template_section.dart';
part 'sections/ssl_page_storage_section.dart';
part 'sections/ssl_page_shared_widgets_section.dart';
part 'sections/ssl_page_diff.dart';

class SslCertificateManagerPage extends StatefulWidget {
  const SslCertificateManagerPage({super.key});

  @override
  State<SslCertificateManagerPage> createState() =>
      _SslCertificateManagerPageState();
}

class _SslCertificateManagerPageState extends State<SslCertificateManagerPage> {
  final ScrollController _cnfEditorScrollController = ScrollController();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SslCertificateManagerProvider>();

    if (provider.isLoading && !provider.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!provider.isInitialized) {
      return _buildInitGuide(provider);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.5),
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                _buildNavItem(
                  0,
                  Icons.badge_outlined,
                  LocalizationKeys.certList.tr(context),
                  provider.selectedNavIndex,
                ),
                _buildNavItem(
                  1,
                  Icons.note_add_outlined,
                  LocalizationKeys.certIssue.tr(context),
                  provider.selectedNavIndex,
                ),
                _buildNavItem(
                  2,
                  Icons.code_outlined,
                  LocalizationKeys.opensslTemplate.tr(context),
                  provider.selectedNavIndex,
                ),
                _buildNavItem(
                  3,
                  Icons.folder_open_outlined,
                  LocalizationKeys.storageConfig.tr(context),
                  provider.selectedNavIndex,
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: provider.selectedNavIndex,
              children: [
                _buildCertificateList(provider),
                _buildIssueTab(provider),
                _buildOpenSslTemplateTab(provider),
                _buildStorageTab(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
