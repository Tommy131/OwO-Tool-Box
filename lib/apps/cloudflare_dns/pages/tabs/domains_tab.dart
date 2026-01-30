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
 * @Author       : Antigravity
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cloudflare_provider.dart';
import '../../models/cloudflare_zone.dart';
import '../../models/cloudflare_dns_record.dart';
import '../../models/cloudflare_config.dart';
import '../../../../core/i18n/app_localization.dart';
import '../../../../core/i18n/localization_keys.dart';
import '../../widgets/animated_background.dart';

class CloudflareDomainsTab extends StatefulWidget {
  const CloudflareDomainsTab({super.key});

  @override
  State<CloudflareDomainsTab> createState() => _CloudflareDomainsTabState();
}

class _CloudflareDomainsTabState extends State<CloudflareDomainsTab> {
  CloudflareZone? _selectedZone;
  Future<List<CloudflareDNSRecord>>? _dnsRecordsFuture;

  String _tr(String key) => AppLocalization.of(context).translate(key);

  void _onZoneSelected(CloudflareZone zone) {
    if (_selectedZone?.id == zone.id) return;
    setState(() {
      _selectedZone = zone;
      _dnsRecordsFuture = context.read<CloudflareProvider>().getDNSRecords(
        zone.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CloudflareProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!provider.isConfigured) {
      return Center(child: Text(_tr(L18nKeys.tokenInvalid)));
    }

    return Stack(
      children: [
        const AnimatedBackground(),
        Row(
          children: [
            // Left Side: Zones List
            SizedBox(width: 250, child: _buildZonesList(provider, colorScheme)),
            VerticalDivider(
              width: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            // Right Side: DNS Records
            Expanded(
              child: _selectedZone == null
                  ? Center(child: Text(_tr(L18nKeys.selectDomainToManage)))
                  : _buildDNSRecordsList(provider, colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZonesList(CloudflareProvider provider, ColorScheme colorScheme) {
    if (provider.isLoading && provider.zones.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.zones.isEmpty) {
      return Center(child: Text(_tr(L18nKeys.noDomainsFound)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: provider.zones.length,
      itemBuilder: (context, index) {
        final zone = provider.zones[index];
        final isSelected = _selectedZone?.id == zone.id;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              zone.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : null,
              ),
            ),
            subtitle: Text(
              zone.status,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.7)
                    : null,
              ),
            ),
            leading: Icon(
              Icons.language,
              size: 20,
              color: isSelected ? colorScheme.primary : null,
            ),
            onTap: () => _onZoneSelected(zone),
          ),
        );
      },
    );
  }

  Widget _buildDNSRecordsList(
    CloudflareProvider provider,
    ColorScheme colorScheme,
  ) {
    return FutureBuilder<List<CloudflareDNSRecord>>(
      future: _dnsRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(child: Text('No DNS records found'));
        }

        return Column(
          children: [
            _buildRecordsHeader(records.length, colorScheme),
            Expanded(
              child: ListView.builder(
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildRecordTile(provider, record, colorScheme);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecordsHeader(int count, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.dns, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${_tr(L18nKeys.dnsRecords)} ($count)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _dnsRecordsFuture = context
                    .read<CloudflareProvider>()
                    .getDNSRecords(_selectedZone!.id, forceRefresh: true);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(
    CloudflareProvider provider,
    CloudflareDNSRecord record,
    ColorScheme colorScheme,
  ) {
    final isDdnsEnabled = provider.ddnsConfigs.any(
      (c) => c.recordId == record.id && c.enabled,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.type,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                record.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(record.content, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (isDdnsEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.sync, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      'DDNS Active',
                      style: TextStyle(fontSize: 12, color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text(isDdnsEnabled ? 'Disable DDNS' : 'Enable DDNS'),
              onTap: () {
                if (isDdnsEnabled) {
                  provider.removeDdnsConfig(record.id);
                } else {
                  provider.addDdnsConfig(
                    DdnsConfig(
                      zoneId: record.zoneId,
                      recordId: record.id,
                      domainName: record.name,
                      enabled: true,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
