// ============================================================================
// 捐赠服务 - API 调用
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/donation_model.dart';
import '../utils/logger.dart';

class DonationService {
  DonationService._();

  // 缓存模拟数据，避免每次都重新创建
  static final List<DonationUser> _mockDonors = [
    DonationUser(
      name: '张三',
      amount: 520.00,
      avatar: '👨‍💼',
      message: '感谢你的开源贡献！',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    DonationUser(
      name: 'Alice',
      amount: 300.00,
      avatar: '👩‍💻',
      message: 'Great work! Keep going!',
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DonationUser(
      name: '李四',
      amount: 200.00,
      avatar: '🎨',
      message: '界面设计太赞了',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DonationUser(
      name: 'Bob',
      amount: 100.00,
      avatar: '🚀',
      message: 'Amazing project!',
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
    DonationUser(
      name: '王五',
      amount: 88.88,
      avatar: '💎',
      message: '支持开源精神',
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  /// 获取捐赠排行榜（前5名）
  ///
  /// 返回 [DonationResult] 包含数据和数据源信息
  static Future<DonationResult> getTopDonors() async {
    try {
      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.donationApiEndpoint}';

      AppLogger.info('正在请求捐赠数据: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'FlutterApp/${AppConstants.appVersion}',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 验证数据格式
        if (data is! Map<String, dynamic>) {
          throw FormatException('响应数据格式错误：预期 Map，实际 ${data.runtimeType}');
        }

        // 检查是否有 donors 字段
        if (!data.containsKey('donors')) {
          throw FormatException('响应数据缺少 donors 字段');
        }

        final donorsList = data['donors'];
        if (donorsList is! List) {
          throw FormatException(
              'donors 字段格式错误：预期 List，实际 ${donorsList.runtimeType}');
        }

        // 解析捐赠者列表
        final donors = donorsList
            .map((json) {
              try {
                return DonationUser.fromJson(json);
              } catch (e) {
                AppLogger.warning('解析捐赠者数据失败: $e, 数据: $json');
                return null;
              }
            })
            .whereType<DonationUser>() // 过滤掉 null
            .take(5)
            .toList();

        if (donors.isEmpty) {
          AppLogger.warning('API 返回的捐赠者列表为空');
          return DonationResult(
            donors: _mockDonors,
            isFromApi: false,
            message: '暂无捐赠数据',
          );
        }

        AppLogger.info('成功获取 ${donors.length} 条捐赠数据（来源：API）');
        return DonationResult(
          donors: donors,
          isFromApi: true,
        );
      } else if (response.statusCode == 404) {
        AppLogger.warning('API 接口不存在 (404)');
        return DonationResult(
          donors: _mockDonors,
          isFromApi: false,
          message: 'API 接口未配置',
        );
      } else if (response.statusCode >= 500) {
        AppLogger.error('服务器错误: ${response.statusCode}');
        return DonationResult(
          donors: _mockDonors,
          isFromApi: false,
          message: '服务器暂时不可用',
        );
      } else {
        AppLogger.error(
            'HTTP 请求失败: ${response.statusCode} ${response.reasonPhrase}');
        return DonationResult(
          donors: _mockDonors,
          isFromApi: false,
          message: 'HTTP ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      AppLogger.error('网络连接失败', e);
      return DonationResult(
        donors: _mockDonors,
        isFromApi: false,
        message: '网络连接失败',
      );
    } on TimeoutException catch (e) {
      AppLogger.error('请求超时', e);
      return DonationResult(
        donors: _mockDonors,
        isFromApi: false,
        message: '请求超时',
      );
    } on FormatException catch (e) {
      AppLogger.error('数据格式错误', e);
      return DonationResult(
        donors: _mockDonors,
        isFromApi: false,
        message: '数据格式错误',
      );
    } catch (e, stackTrace) {
      AppLogger.error('获取捐赠数据失败', e, stackTrace);
      return DonationResult(
        donors: _mockDonors,
        isFromApi: false,
        message: '加载失败',
      );
    }
  }

  /// 获取模拟数据（公开方法，用于测试）
  static List<DonationUser> getMockDonors() => List.unmodifiable(_mockDonors);
}

/// 捐赠结果模型
class DonationResult {
  final List<DonationUser> donors;
  final bool isFromApi;
  final String? message;

  const DonationResult({
    required this.donors,
    required this.isFromApi,
    this.message,
  });
}
