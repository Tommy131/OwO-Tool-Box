/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2026-01-30
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-22
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/localization_service.dart';

import '../../localization/localization_keys.dart';
import '../../providers/cloudflare_provider.dart';
import '../../models/cloudflare_config.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/custom_snack_bar.dart';

class CloudflareConfigTab extends StatefulWidget {
  const CloudflareConfigTab({super.key});

  @override
  State<CloudflareConfigTab> createState() => _CloudflareConfigTabState();
}

class _CloudflareConfigTabState extends State<CloudflareConfigTab> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CloudflareProvider>();
    if (provider.config != null) {
      _tokenController.text = provider.config!.apiToken;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final provider = context.read<CloudflareProvider>();
    final config = CloudflareConfig(apiToken: _tokenController.text.trim());

    final isValid = await provider.verifyToken(config);
    if (mounted) {
      if (isValid) {
        await provider.setConfig(config);
        if (!mounted) return;
        CustomSnackBar(
          context,
          message: LocalizationKeys.tokenVerified.tr(context),
          backgroundColor: Colors.green,
          icon: Icons.check_circle_outline,
        ).showModern();
      } else {
        if (!mounted) return;
        CustomSnackBar(
          context,
          message: LocalizationKeys.tokenInvalid.tr(context),
          backgroundColor: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline,
        ).showModern();
      }
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CloudflareProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        const AnimatedBackground(),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationKeys.cloudflareApiSettings.tr(context),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatusCard(provider, theme, colorScheme),
                  const SizedBox(height: 32),
                  Text(
                    LocalizationKeys.apiToken.tr(context),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTokenField(colorScheme),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _verifyAndSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user),
                      label: Text(LocalizationKeys.verifyToken.tr(context)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    CloudflareProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (provider.config == null) return const SizedBox.shrink();

    final isValid = provider.isTokenValid;
    final expiresAt = provider.tokenExpiresAt;

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;
    String statusText = 'Unknown';
    String subText = '';

    if (isValid == true) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = LocalizationKeys.tokenValid.tr(context);
      subText = expiresAt != null
          ? '${LocalizationKeys.tokenExpiry.tr(context)}: ${expiresAt.toString().split(' ')[0]}'
          : LocalizationKeys.tokenPermanent.tr(context);
    } else if (isValid == false) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error;
      statusText = LocalizationKeys.tokenInvalid.tr(context);
      subText = LocalizationKeys.apiTokenHint.tr(context);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (subText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      subText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenField(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: TextFormField(
        controller: _tokenController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: LocalizationKeys.apiTokenHint.tr(context),
          prefixIcon: Icon(Icons.vpn_key, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (v) => v == null || v.isEmpty
            ? LocalizationKeys.apiTokenHint.tr(context)
            : null,
      ),
    );
  }
}
