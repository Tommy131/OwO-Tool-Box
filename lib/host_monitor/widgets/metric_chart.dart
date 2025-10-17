/*
 *        _____   _          __  _____   _____   _       _____   _____
 *      /  _  \ | |        / / /  _  \ |  _  \ | |     /  _  \ /  ___|
 *      | | | | | |  __   / /  | | | | | |_| | | |     | | | | | |
 *      | | | | | | /  | / /   | | | | |  _  { | |     | | | | | |   _
 *      | |_| | | |/   |/ /    | |_| | | |_| | | |___  | |_| | | |_| |
 *      \_____/ |___/|___/     \_____/ |_____/ |_____| \_____/ \_____/
 *
 *  Copyright (c) 2023 by OwOTeam-DGMT (OwOBlog).
 * @Date         : 2025-10-10 21:48:49
 * @Author       : HanskiJay
 * @LastEditors  : HanskiJay
 * @LastEditTime : 2025-10-12 21:19:21
 * @E-Mail       : support@owoblog.com
 * @Telegram     : https://t.me/HanskiJay
 * @GitHub       : https://github.com/Tommy131
 */
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../my_models/metrics_history_model.dart';
import '../screen_theme.dart';

class MetricsChart extends StatelessWidget {
  final List<MetricPoint> dataPoints;
  final String title;
  final Color lineColor;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final String unit;
  final bool isNetworkSpeed; // 标识是否为网络速率图表

  const MetricsChart({
    super.key,
    required this.dataPoints,
    required this.title,
    required this.lineColor,
    required this.gradientStartColor,
    required this.gradientEndColor,
    this.unit = '%',
    this.isNetworkSpeed = false, // 默认不是网络速率
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _buildEmptyChart();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 900;

    final chartHeight = isWideScreen ? 200.0 : 150.0;

    // 如果是网络速率，计算合适的单位和转换后的数据
    final convertedData = isNetworkSpeed
        ? _convertNetworkData(dataPoints)
        : NetworkSpeedData(dataPoints, unit);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ScreenTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ScreenTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (convertedData.points.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: lineColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lineColor, width: 1),
                  ),
                  child: Text(
                    '${convertedData.points.last.value.toStringAsFixed(1)}${convertedData.displayUnit}',
                    style: TextStyle(
                      color: lineColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              _buildChartData(convertedData),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ScreenTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ScreenTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '等待数据...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 转换网络数据到合适的单位
  NetworkSpeedData _convertNetworkData(List<MetricPoint> points) {
    if (points.isEmpty) {
      return NetworkSpeedData(points, ' KB/s');
    }

    // 找到最大值来决定使用什么单位
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    String displayUnit;
    double divisor;

    if (maxValue < 1) {
      // 小于 1 KB/s，使用 B/s
      displayUnit = ' B/s';
      divisor = 1 / 1024; // 因为原始数据是KB/s，转换回B/s
    } else if (maxValue < 1024) {
      // 1 KB/s - 1024 KB/s
      displayUnit = ' KB/s';
      divisor = 1;
    } else if (maxValue < 1024 * 1024) {
      // 1 MB/s - 1024 MB/s
      displayUnit = ' MB/s';
      divisor = 1024;
    } else {
      // >= 1 GB/s
      displayUnit = ' GB/s';
      divisor = 1024 * 1024;
    }

    // 转换所有数据点
    final convertedPoints = points.map((point) {
      return MetricPoint(
        timestamp: point.timestamp,
        value: point.value / divisor,
      );
    }).toList();

    return NetworkSpeedData(convertedPoints, displayUnit);
  }

  LineChartData _buildChartData(NetworkSpeedData data) {
    final spots = data.points.asMap().entries.map((entry) {
      final index = entry.key;
      final metricPoint = entry.value;
      return FlSpot(index.toDouble(), metricPoint.value);
    }).toList();

    // 计算Y轴范围
    double minY = 0;
    double maxY;

    if (isNetworkSpeed) {
      // 网络速率：动态计算最大值
      if (data.points.isEmpty) {
        maxY = 100;
      } else {
        final values = data.points.map((p) => p.value).toList();
        final dataMax = values.reduce((a, b) => a > b ? a : b);
        // 设置为最大值的1.2倍，但至少为10
        maxY = (dataMax * 1.2).clamp(10, double.infinity);
      }
    } else {
      // 百分比：固定为0-100
      maxY = 100;
      if (data.points.isNotEmpty) {
        final values = data.points.map((p) => p.value).toList();
        final dataMax = values.reduce((a, b) => a > b ? a : b);
        maxY = (dataMax * 1.2).clamp(10, 100);
      }
    }

    // 计算合适的Y轴间隔
    double interval;
    if (maxY <= 10) {
      interval = 2;
    } else if (maxY <= 50) {
      interval = 10;
    } else if (maxY <= 100) {
      interval = 25;
    } else if (maxY <= 500) {
      interval = 100;
    } else if (maxY <= 1000) {
      interval = 200;
    } else {
      interval = 500;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              // 格式化Y轴标签
              String label;
              if (value >= 1000) {
                label = '${(value / 1000).toStringAsFixed(1)}K';
              } else if (value >= 1) {
                label = value.toInt().toString();
              } else {
                label = value.toStringAsFixed(1);
              }

              return Text(
                '$label${data.displayUnit}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.points.length - 1).toDouble().clamp(10, double.infinity),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: lineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientStartColor.withOpacity(0.3),
                gradientEndColor.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)}${data.displayUnit}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

// 网络速率数据包装类
class NetworkSpeedData {
  final List<MetricPoint> points;
  final String displayUnit;

  NetworkSpeedData(this.points, this.displayUnit);
}
