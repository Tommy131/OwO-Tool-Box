part of '../ssl_certificate_manager_page.dart';

/// 通用组件区：复用导航项、卡片、输入框与文件选择逻辑。
extension _SslPageSharedWidgetsSection on _SslCertificateManagerPageState {
  Widget _buildCard({required String title, required Widget child}) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    Widget? suffix,
    String? pinFieldKey,
    bool requiredField = false,
  }) {
    final provider = context.read<SslCertificateManagerProvider>();
    final config = _resolveInputConfig(controller);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListenableBuilder(
        listenable: pinFieldKey == null
            ? controller
            : Listenable.merge([controller, provider]),
        builder: (context, _) {
          final isPinned =
              pinFieldKey != null && provider.isIssueFieldPinned(pinFieldKey);
          return TextField(
            controller: controller,
            keyboardType: config.keyboardType,
            inputFormatters: config.inputFormatters,
            obscureText: config.obscureText,
            readOnly: isPinned,
            textCapitalization: config.textCapitalization,
            decoration: InputDecoration(
              labelText: _buildFieldLabel(label, requiredField),
              border: const OutlineInputBorder(),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: _buildInputSuffix(
                controller: controller,
                suffix: suffix ?? config.suffix,
                pinFieldKey: pinFieldKey,
              ),
              errorText: _validationErrorForController(controller),
            ),
          );
        },
      ),
    );
  }

  Widget _sizedField(
    TextEditingController controller,
    String label,
    double width, {
    Widget? suffix,
    String? pinFieldKey,
    bool requiredField = false,
  }) {
    final provider = context.read<SslCertificateManagerProvider>();
    final config = _resolveInputConfig(controller);
    return SizedBox(
      width: width,
      child: ListenableBuilder(
        listenable: pinFieldKey == null
            ? controller
            : Listenable.merge([controller, provider]),
        builder: (context, _) {
          final isPinned =
              pinFieldKey != null && provider.isIssueFieldPinned(pinFieldKey);
          return TextField(
            controller: controller,
            keyboardType: config.keyboardType,
            inputFormatters: config.inputFormatters,
            obscureText: config.obscureText,
            readOnly: isPinned,
            textCapitalization: config.textCapitalization,
            decoration: InputDecoration(
              labelText: _buildFieldLabel(label, requiredField),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: _buildInputSuffix(
                controller: controller,
                suffix: suffix ?? config.suffix,
                pinFieldKey: pinFieldKey,
              ),
              errorText: _validationErrorForController(controller),
            ),
          );
        },
      ),
    );
  }

  Widget? _buildInputSuffix({
    required TextEditingController controller,
    Widget? suffix,
    String? pinFieldKey,
  }) {
    if (suffix == null && pinFieldKey == null) {
      return null;
    }

    final provider = context.read<SslCertificateManagerProvider>();
    final theme = Theme.of(context);
    final actions = <Widget>[];

    if (suffix != null) {
      actions.add(suffix);
    }

    if (pinFieldKey != null) {
      final isPinned = provider.isIssueFieldPinned(pinFieldKey);
      final canToggle = isPinned || provider.canPinIssueField(pinFieldKey);
      actions.add(
        IconButton(
          tooltip: isPinned
              ? LocalizationKeys.unpinField.tr(context)
              : LocalizationKeys.pinField.tr(context),
          onPressed: canToggle
              ? () => provider.toggleIssueFieldPinned(pinFieldKey)
              : null,
          icon: Icon(
            isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: isPinned
                ? theme.colorScheme.primary
                : theme.iconTheme.color?.withValues(
                    alpha: canToggle ? 0.78 : 0.35,
                  ),
          ),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: actions);
  }

  String _buildFieldLabel(String label, bool requiredField) {
    return requiredField ? '$label *' : label;
  }

  String? _validationErrorForController(TextEditingController controller) {
    final provider = context.read<SslCertificateManagerProvider>();
    final value = controller.text.trim();
    if (value.isEmpty) {
      return null;
    }

    if (identical(controller, provider.domainController)) {
      return _isValidDomainOrIp(value, allowWildcard: true)
          ? null
          : LocalizationKeys.validationInvalidDomainOrIp.tr(context);
    }

    if (identical(controller, provider.ocspDomainController)) {
      return _isValidDomainOrIp(value)
          ? null
          : LocalizationKeys.validationInvalidDomainOrIp.tr(context);
    }

    if (identical(controller, provider.emailAddressController)) {
      return _isValidEmail(value)
          ? null
          : LocalizationKeys.validationInvalidEmail.tr(context);
    }

    if (identical(controller, provider.countryNameController)) {
      return RegExp(r'^[A-Z]{2}$').hasMatch(value)
          ? null
          : LocalizationKeys.validationInvalidCountryCode.tr(context);
    }

    if (identical(controller, provider.validDaysController)) {
      final days = int.tryParse(value);
      return days != null && days > 0
          ? null
          : LocalizationKeys.validationValidDays.tr(context);
    }

    if (identical(controller, provider.ocspCaIssuersUrlController) ||
        identical(controller, provider.ocspResponderUrlController) ||
        identical(controller, provider.crlDistributionUrlController)) {
      return _isValidHttpUrl(value)
          ? null
          : LocalizationKeys.validationInvalidUrl.tr(context);
    }

    return null;
  }

  String? _validationErrorForAltName(AltNameType type, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (type == AltNameType.ip) {
      return _isValidIp(trimmed)
          ? null
          : LocalizationKeys.validationInvalidIp.tr(context);
    }
    return _isValidDnsName(trimmed, allowWildcard: true)
        ? null
        : LocalizationKeys.validationInvalidDomain.tr(context);
  }

  bool _isValidEmail(String value) {
    return RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$",
    ).hasMatch(value);
  }

  bool _isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    if (uri.host.isEmpty || value.contains(' ')) {
      return false;
    }
    if (!_isValidDomainOrIp(uri.host)) {
      return false;
    }
    final port = uri.hasPort ? uri.port : null;
    if (port != null && (port < 1 || port > 65535)) {
      return false;
    }
    return true;
  }

  bool _isValidIp(String value) {
    return InternetAddress.tryParse(value) != null;
  }

  bool _isValidDomainOrIp(String value, {bool allowWildcard = false}) {
    return _isValidIp(value) ||
        _isValidDnsName(value, allowWildcard: allowWildcard);
  }

  bool _isValidDnsName(String value, {bool allowWildcard = false}) {
    var candidate = value.trim();
    if (candidate.isEmpty || candidate.length > 253) {
      return false;
    }
    if (candidate.endsWith('.')) {
      candidate = candidate.substring(0, candidate.length - 1);
    }
    if (allowWildcard && candidate.startsWith('*.')) {
      candidate = candidate.substring(2);
    }
    final labels = candidate.split('.');
    if (labels.length < 2) {
      return false;
    }
    for (final label in labels) {
      if (label.isEmpty ||
          label.length > 63 ||
          label.startsWith('-') ||
          label.endsWith('-') ||
          !RegExp(r'^[A-Za-z0-9-]+$').hasMatch(label)) {
        return false;
      }
    }
    return true;
  }

  _SslInputConfig _resolveInputConfig(TextEditingController controller) {
    final provider = context.read<SslCertificateManagerProvider>();
    if (identical(controller, provider.domainController) ||
        identical(controller, provider.ocspDomainController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.url,
        inputFormatters: [
          LengthLimitingTextInputFormatter(255),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.*-]')),
        ],
      );
    }
    if (identical(controller, provider.commonNameController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(255),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff .,_\-()/#@:&]+"),
          ),
        ],
      );
    }
    if (identical(controller, provider.countryNameController)) {
      return const _SslInputConfig(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [_UpperCaseAlphaTextFormatter(maxLength: 2)],
      );
    }
    if (identical(controller, provider.emailAddressController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          LengthLimitingTextInputFormatter(254),
          FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z0-9@._%+\-]")),
        ],
      );
    }
    if (identical(controller, provider.validDaysController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(5),
          FilteringTextInputFormatter.digitsOnly,
        ],
      );
    }
    if (identical(controller, provider.storagePathController) ||
        identical(controller, provider.rootCACertPathController) ||
        identical(controller, provider.rootCAKeyPathController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(512),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff _.:/\\()[\]-]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.ocspCaIssuersUrlController) ||
        identical(controller, provider.ocspResponderUrlController) ||
        identical(controller, provider.crlDistributionUrlController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.url,
        inputFormatters: [
          LengthLimitingTextInputFormatter(512),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.rootCAPasswordController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.visiblePassword,
        obscureText: !_showRootCaPassword,
        suffix: IconButton(
          onPressed: _toggleRootCaPasswordVisibility,
          icon: Icon(
            _showRootCaPassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(128),
          FilteringTextInputFormatter.allow(
            RegExp(
              "[A-Za-z0-9!@#\\\$%\\^&*()_+\\-=\\[\\]{};':\",./<>?\\\\|`~]",
            ),
          ),
        ],
      );
    }
    if (identical(controller, provider.challengePasswordController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.visiblePassword,
        obscureText: !_showChallengePassword,
        suffix: IconButton(
          onPressed: _toggleChallengePasswordVisibility,
          icon: Icon(
            _showChallengePassword ? Icons.visibility_off : Icons.visibility,
          ),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(128),
          FilteringTextInputFormatter.allow(
            RegExp(
              "[A-Za-z0-9!@#\\\$%\\^&*()_+\\-=\\[\\]{};':\",./<>?\\\\|`~]",
            ),
          ),
        ],
      );
    }
    if (identical(controller, provider.rootCANameController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(80),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff ._-]"),
          ),
        ],
      );
    }
    if (identical(controller, provider.revokeReasonController)) {
      return _SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(120),
          FilteringTextInputFormatter.allow(
            RegExp(r"[A-Za-z0-9\u4e00-\u9fff .,_()\-:/]"),
          ),
        ],
      );
    }
    return _SslInputConfig(
      keyboardType: TextInputType.text,
      inputFormatters: [LengthLimitingTextInputFormatter(120)],
    );
  }

  _SslInputConfig _altNameInputConfig(AltNameType type) {
    if (type == AltNameType.ip) {
      return _SslInputConfig(
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(64),
          FilteringTextInputFormatter.allow(RegExp(r'[A-Fa-f0-9:.]')),
        ],
      );
    }
    return _SslInputConfig(
      keyboardType: TextInputType.url,
      inputFormatters: [
        LengthLimitingTextInputFormatter(255),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.*-]')),
      ],
    );
  }

  Future<String?> _pickDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return null;
    }
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: LocalizationKeys.setupStoragePath.tr(context),
    );
  }

  Future<String?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pem', 'crt', 'key'],
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }

  Future<String?> _pickCertFile() async {
    final path = await _pickFile();
    if (path == null) return null;
    final lower = p.basename(path).toLowerCase();
    if (lower.endsWith('.crt') || lower.endsWith('.pem')) {
      return path;
    }
    if (!mounted) return null;
    await _showSimpleDialog(
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.rootCertFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<String?> _pickKeyFile() async {
    final path = await _pickFile();
    if (path == null) return null;
    final lower = p.basename(path).toLowerCase();
    if (lower.endsWith('.key') || lower.endsWith('.pem')) {
      return path;
    }
    if (!mounted) return null;
    await _showSimpleDialog(
      LocalizationKeys.fileTypeNotAllowed.tr(context),
      LocalizationKeys.rootKeyFileAllowedOnly.tr(context),
    );
    return null;
  }

  Future<void> _handleCompleteInitialization(
    SslCertificateManagerProvider provider,
  ) async {
    if (provider.importRootCA) {
      final validation = await provider.inspectImportedRootCA();
      if (!mounted) return;
      if (!validation.isValid) {
        await _showSimpleDialog(
          LocalizationKeys.importRootCaFailed.tr(context),
          validation.message,
        );
        return;
      }

      final confirmed = await _showRootCaConfirmDialog(validation);
      if (!mounted || !confirmed) return;
      await provider.completeInitialization();
      if (!mounted) return;
      if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
        await _showSimpleDialog(
          LocalizationKeys.initFailed.tr(context),
          provider.infoMessage,
        );
      }
      return;
    }

    if (provider.isRootPasswordEmpty) {
      final acceptedRisk = await _showEmptyPasswordRiskDialog();
      if (!mounted || !acceptedRisk) return;
    }
    await provider.completeInitialization();
    if (!mounted) return;
    if (!provider.isInitialized && provider.infoMessage.trim().isNotEmpty) {
      await _showSimpleDialog(
        LocalizationKeys.initFailed.tr(context),
        provider.infoMessage,
      );
    }
  }

  Future<void> _showSimpleDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(LocalizationKeys.confirm.tr(context)),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showRootCaConfirmDialog(
    RootCaValidationResult validation,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.importRootCaConfirmTitle.tr(context)),
          content: SizedBox(
            width: 640,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: validation.details.entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SelectableText('${entry.key}: ${entry.value}'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(LocalizationKeys.cancel.tr(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(LocalizationKeys.confirmAndContinue.tr(context)),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<bool> _showEmptyPasswordRiskDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(LocalizationKeys.emptyPasswordRiskTitle.tr(context)),
          content: Text(LocalizationKeys.emptyPasswordRiskContent.tr(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(LocalizationKeys.backToFillPassword.tr(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(LocalizationKeys.continueWithRisk.tr(context)),
            ),
          ],
        );
      },
    );
    return result == true;
  }
}

class _SslInputConfig {
  const _SslInputConfig({
    required this.keyboardType,
    this.inputFormatters = const <TextInputFormatter>[],
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.suffix,
  });

  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final Widget? suffix;
}

class _UpperCaseAlphaTextFormatter extends TextInputFormatter {
  const _UpperCaseAlphaTextFormatter({required this.maxLength});

  final int maxLength;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = newValue.text
        .replaceAll(RegExp(r'[^A-Za-z]'), '')
        .toUpperCase();
    final truncated = normalized.characters.take(maxLength).toString();
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
