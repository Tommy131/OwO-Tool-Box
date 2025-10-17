import 'package:flutter/material.dart';

import '../common/card_header.dart';

class TechStackCard extends StatelessWidget {
  const TechStackCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CardHeader(
              icon: Icons.build,
              title: '技术栈',
              iconSize: 28,
            ),
            const SizedBox(height: 20),
            _buildTechItem(
              'Flutter',
              '前端跨平台框架',
              Icons.phone_android,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              'Go',
              '高性能后端服务',
              Icons.memory,
              Colors.cyan,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              'TCP/IP',
              '网络通信协议',
              Icons.wifi,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildTechItem(
              'Material Design',
              '现代化 UI 设计',
              Icons.palette,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechItem(
    String tech,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tech,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
