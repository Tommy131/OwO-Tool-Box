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
import '../../providers/cloudflare_provider.dart';
import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../../widgets/animated_background.dart';

class CloudflareDdnsTab extends StatelessWidget {
  const CloudflareDdnsTab({super.key});

  String _tr(BuildContext context, String key) =>
      AppLocalization.of(context).translate(key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CloudflareProvider>();
    final theme = Theme.of(context);

    return Stack(
      children: [
        const AnimatedBackground(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIPCard(provider, theme, context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _tr(context, L18nKeys.ddnsSettings),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () => provider.runDdnsSync(),
                    icon: const Icon(Icons.sync),
                    label: Text(_tr(context, L18nKeys.syncNow)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: provider.ddnsConfigs.isEmpty
                    ? Center(child: Text(_tr(context, L18nKeys.ddnsInactive)))
                    : ListView.builder(
                        itemCount: provider.ddnsConfigs.length,
                        itemBuilder: (context, index) {
                          final config = provider.ddnsConfigs[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: config.enabled
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.sync,
                                  color: config.enabled
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              title: Text(config.domainName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_tr(context, L18nKeys.lastUpdated)}: ${config.lastSync?.toString().split('.')[0] ?? 'Never'}',
                                  ),
                                  if (config.lastIp != null)
                                    Text('Last IP: ${config.lastIp}'),
                                ],
                              ),
                              trailing: Switch(
                                value: config.enabled,
                                onChanged: (val) =>
                                    provider.toggleDdns(config.recordId, val),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIPCard(
    CloudflareProvider provider,
    ThemeData theme,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tr(context, L18nKeys.publicIP),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.publicIp ?? 'Checking...',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (provider.isLoading)
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
