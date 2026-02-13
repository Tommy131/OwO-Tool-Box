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

import '../../../core/services/localization_service.dart';

import '../localization/localization_keys.dart';
import '../providers/cloudflare_provider.dart';
import 'tabs/config_tab.dart';
import 'tabs/domains_tab.dart';
import 'tabs/ddns_tab.dart';

class CloudflareDnsPage extends StatefulWidget {
  const CloudflareDnsPage({super.key});

  @override
  State<CloudflareDnsPage> createState() => _CloudflareDnsPageState();
}

class _CloudflareDnsPageState extends State<CloudflareDnsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<CloudflareProvider>();
      await provider.initialize();
      if (!provider.isConfigured && mounted) {
        _tabController.animateTo(2); // Jump to last tab (Settings)
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: const Icon(Icons.dns),
              text: LocalizationKeys.domains.tr(context),
            ),
            Tab(
              icon: const Icon(Icons.sync_alt),
              text: LocalizationKeys.ddnsSettings.tr(context),
            ),
            Tab(
              icon: const Icon(Icons.settings),
              text: LocalizationKeys.cloudflareApiSettings.tr(context),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CloudflareDomainsTab(),
          CloudflareDdnsTab(),
          CloudflareConfigTab(),
        ],
      ),
    );
  }
}
