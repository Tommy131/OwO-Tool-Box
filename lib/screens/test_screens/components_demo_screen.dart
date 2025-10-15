// ============================================================================
// 组件展示页面 - Components Demo Page
// 文件路径: lib/pages/components_demo_page.dart
// 版本: 1.0.0
// 说明: 展示所有自定义组件的使用示例
// ============================================================================

import 'package:flutter/material.dart' hide FormField;

import '../../widgets/bars/custom_snack_bar.dart';
import '../../widgets/bars/status_bar.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/cards/custom_card.dart';
import '../../widgets/cards/progress_card.dart';
import '../../widgets/cards/stats_card.dart';
import '../../widgets/charts/simple_bar_chart.dart';
import '../../widgets/charts/simple_line_chart.dart';
import '../../widgets/others/custom_dialog.dart';
import '../../widgets/others/custom_text_field.dart';
import '../../widgets/others/empty_state.dart';
import '../../widgets/others/info_tile.dart';
import '../../widgets/others/loading_indicator.dart';
import '../../widgets/selections/custom_dropdown.dart';
import '../../widgets/others/timeline_item.dart';
import '../../widgets/user_registration_form.dart';

/// 组件展示页面
class ComponentsDemoScreen extends StatefulWidget {
  const ComponentsDemoScreen({super.key});

  @override
  State<ComponentsDemoScreen> createState() => _ComponentsDemoPageState();
}

class _ComponentsDemoPageState extends State<ComponentsDemoScreen> {
  bool _isLoading = false;
  bool _showStatusBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('组件展示'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('1. 自定义卡片组件'),
                _buildCardsSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('2. 统计卡片'),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('3. 按钮组件'),
                _buildButtonsSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('4. 图表组件'),
                _buildChartsSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('5. SnackBar 演示'),
                _buildSnackBarSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('6. 状态栏组件'),
                _buildStatusBarSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('7. 加载与空状态'),
                _buildLoadingSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('8. 信息瓦片'),
                _buildInfoTilesSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('9. 进度卡片'),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('10. 时间轴'),
                _buildTimelineSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('11. 表单组件'),
                _buildFormSection(),
                const SizedBox(height: 40),
                const SizedBox(height: 24),
                _buildSectionTitle('12. 弹窗组件'),
                _buildDialogsSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // 顶部状态栏（可关闭）
          if (_showStatusBar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: StatusBar(
                message: '正在同步数据，请稍候...',
                type: StatusBarType.loading,
                onDismiss: () {
                  setState(() {
                    _showStatusBar = false;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  // ===== 1. 卡片组件展示 =====
  Widget _buildCardsSection() {
    return Column(
      children: [
        CustomCard(
          title: '基础卡片',
          subtitle: '这是一个带图标和副标题的卡片',
          icon: Icons.star,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            CustomSnackBar.show(
              context,
              message: '你点击了基础卡片',
              type: SnackBarType.info,
            );
          },
        ),
        const SizedBox(height: 12),
        CustomCard(
          title: '自定义颜色卡片',
          subtitle: '可以自定义图标颜色和背景色',
          icon: Icons.palette,
          iconColor: Colors.purple,
          backgroundColor: Colors.purple.shade50,
          onTap: () {},
        ),
      ],
    );
  }

  // ===== 2. 统计卡片展示 =====
  Widget _buildStatsSection() {
    // 根据屏幕宽度判断是否为小屏设备
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isSmallScreen ? 1 : 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: isSmallScreen ? 3.5 : 1.3,
      children: const [
        StatsCard(
          title: '总销售额',
          value: '¥128,500',
          trend: '+12.5%',
          isPositive: true,
          icon: Icons.attach_money,
          iconColor: Colors.green,
        ),
        StatsCard(
          title: '订单数量',
          value: '1,234',
          trend: '-5.2%',
          isPositive: false,
          icon: Icons.shopping_cart,
          iconColor: Colors.blue,
        ),
        StatsCard(
          title: '新用户',
          value: '856',
          trend: '+18.7%',
          isPositive: true,
          icon: Icons.person_add,
          iconColor: Colors.orange,
        ),
        StatsCard(
          title: '活跃用户',
          value: '3,421',
          icon: Icons.groups,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  // ===== 3. 按钮组件展示 =====
  Widget _buildButtonsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton(
              text: '主要按钮',
              onPressed: () {},
              style: CustomButtonStyle.primary,
              icon: Icons.check,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '次要按钮',
              onPressed: () {},
              style: CustomButtonStyle.secondary,
              icon: Icons.settings,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '轮廓按钮',
              onPressed: () {},
              style: CustomButtonStyle.outlined,
              icon: Icons.edit,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: '文本按钮',
                    onPressed: () {},
                    style: CustomButtonStyle.text,
                    icon: Icons.link,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: '危险按钮',
                    onPressed: () {},
                    style: CustomButtonStyle.danger,
                    icon: Icons.delete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '加载中',
              onPressed: () {},
              style: CustomButtonStyle.primary,
              isLoading: _isLoading,
              width: double.infinity,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: _isLoading ? '停止加载' : '开始加载',
              onPressed: () {
                setState(() {
                  _isLoading = !_isLoading;
                });
              },
              style: CustomButtonStyle.secondary,
              icon: _isLoading ? Icons.stop : Icons.play_arrow,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // ===== 4. 图表组件展示 =====
  Widget _buildChartsSection() {
    return const Column(
      children: [
        SimpleLineChart(
          title: '本周销售趋势',
          data: [15, 28, 22, 35, 30, 42, 38],
          labels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
          lineColor: Colors.blue,
        ),
        SizedBox(height: 16),
        SimpleBarChart(
          title: '月度对比',
          data: [65, 72, 58, 80, 75, 88],
          labels: ['1月', '2月', '3月', '4月', '5月', '6月'],
          barColor: Colors.green,
        ),
      ],
    );
  }

  // ===== 5. SnackBar 展示 =====
  Widget _buildSnackBarSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton(
              text: '成功提示',
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: '操作成功！数据已保存',
                  type: SnackBarType.success,
                );
              },
              style: CustomButtonStyle.primary,
              icon: Icons.check_circle,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '错误提示',
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: '操作失败！请检查网络连接',
                  type: SnackBarType.error,
                );
              },
              style: CustomButtonStyle.danger,
              icon: Icons.error,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '警告提示',
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: '注意：此操作不可撤销',
                  type: SnackBarType.warning,
                );
              },
              style: CustomButtonStyle.secondary,
              icon: Icons.warning,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: '信息提示（带操作）',
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: '发现新版本',
                  type: SnackBarType.info,
                  actionLabel: '更新',
                  onAction: () {
                    CustomSnackBar.show(
                      context,
                      message: '开始更新...',
                      type: SnackBarType.success,
                    );
                  },
                );
              },
              style: CustomButtonStyle.outlined,
              icon: Icons.info,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  // ===== 6. 状态栏展示 =====
  Widget _buildStatusBarSection() {
    return Column(
      children: [
        CustomButton(
          text: _showStatusBar ? '隐藏状态栏' : '显示状态栏',
          onPressed: () {
            setState(() {
              _showStatusBar = !_showStatusBar;
            });
          },
          style: CustomButtonStyle.primary,
          icon: _showStatusBar ? Icons.visibility_off : Icons.visibility,
          width: double.infinity,
        ),
        const SizedBox(height: 12),
        const StatusBar(
          message: '信息状态栏示例',
          type: StatusBarType.info,
        ),
        const SizedBox(height: 8),
        const StatusBar(
          message: '成功状态栏示例',
          type: StatusBarType.success,
        ),
        const SizedBox(height: 8),
        const StatusBar(
          message: '警告状态栏示例',
          type: StatusBarType.warning,
        ),
      ],
    );
  }

  // ===== 7. 加载与空状态展示 =====
  Widget _buildLoadingSection() {
    return Column(
      children: [
        Card(
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            child: const LoadingIndicator(
              message: '加载中...',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: EmptyState(
              icon: Icons.inbox,
              title: '暂无数据',
              subtitle: '当前没有任何内容，请添加新项目',
              actionLabel: '添加项目',
              onAction: () {
                CustomSnackBar.show(
                  context,
                  message: '跳转到添加页面',
                  type: SnackBarType.info,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ===== 8. 信息瓦片展示 =====
  Widget _buildInfoTilesSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            InfoTile(
              label: '用户名',
              value: 'Zhang San',
              icon: Icons.person,
            ),
            Divider(),
            InfoTile(
              label: '邮箱',
              value: 'zhangsan@example.com',
              icon: Icons.email,
              iconColor: Colors.blue,
            ),
            Divider(),
            InfoTile(
              label: '电话',
              value: '+86 138-0000-0000',
              icon: Icons.phone,
              iconColor: Colors.green,
            ),
            Divider(),
            InfoTile(
              label: '地址',
              value: '北京市朝阳区',
              icon: Icons.location_on,
              iconColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // ===== 9. 进度卡片展示 =====
  Widget _buildProgressSection() {
    return const Column(
      children: [
        ProgressCard(
          title: '项目进度',
          progress: 0.75,
          subtitle: '还剩 25% 未完成',
          progressColor: Colors.green,
        ),
        SizedBox(height: 12),
        ProgressCard(
          title: '学习进度',
          progress: 0.45,
          subtitle: 'Flutter 高级课程',
          progressColor: Colors.blue,
        ),
        SizedBox(height: 12),
        ProgressCard(
          title: '存储空间',
          progress: 0.92,
          subtitle: '92% 已使用',
          progressColor: Colors.orange,
        ),
      ],
    );
  }

  // ===== 10. 时间轴展示 =====
  Widget _buildTimelineSection() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TimelineItem(
              title: '订单已完成',
              subtitle: '您的订单已成功送达',
              time: '2024-01-15 14:30',
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
            TimelineItem(
              title: '订单配送中',
              subtitle: '快递员正在配送您的订单',
              time: '2024-01-15 10:20',
              icon: Icons.local_shipping,
              iconColor: Colors.blue,
            ),
            TimelineItem(
              title: '订单已发货',
              subtitle: '您的订单已从仓库发出',
              time: '2024-01-14 16:45',
              icon: Icons.inventory,
              iconColor: Colors.orange,
            ),
            TimelineItem(
              title: '订单已确认',
              subtitle: '商家已确认您的订单',
              time: '2024-01-14 09:15',
              icon: Icons.assignment_turned_in,
              iconColor: Colors.purple,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  // ===== 11. 表单组件展示 =====
  Widget _buildFormSection() {
    return Column(
      children: [
        // 简单表单示例
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '简单表单控件',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                const CustomTextField(
                  label: '姓名',
                  hint: '请输入您的姓名',
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 16),
                const CustomTextField(
                  label: '邮箱',
                  hint: '请输入邮箱地址',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                CustomDropdown<String>(
                  label: '城市',
                  hint: '请选择城市',
                  prefixIcon: Icons.location_city,
                  items: const [
                    DropdownMenuItem(value: 'beijing', child: Text('北京')),
                    DropdownMenuItem(value: 'shanghai', child: Text('上海')),
                    DropdownMenuItem(value: 'guangzhou', child: Text('广州')),
                    DropdownMenuItem(value: 'shenzhen', child: Text('深圳')),
                  ],
                  onChanged: (value) {
                    CustomSnackBar.show(
                      context,
                      message: '选择了: $value',
                      type: SnackBarType.info,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 完整注册表单
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.app_registration,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '完整注册表单示例',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '这是一个包含所有表单控件的完整示例',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: '查看完整表单',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text('用户注册表单'),
                          ),
                          body: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: UserRegistrationForm(
                              onSubmit: (data) {
                                Navigator.of(context).pop();
                                CustomSnackBar.show(
                                  context,
                                  message: '注册成功！用户名: ${data['username']}',
                                  type: SnackBarType.success,
                                  duration: const Duration(seconds: 4),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  style: CustomButtonStyle.primary,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== 12. 弹窗组件展示 =====
  Widget _buildDialogsSection() {
    return Column(
      children: [
        // 基础弹窗
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基础弹窗',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: '警告弹窗',
                  icon: Icons.warning,
                  onPressed: () {
                    CustomDialog.showWarning(
                      context: context,
                      title: '警告',
                      message: '此操作可能会影响系统设置，请谨慎操作。',
                      confirmText: '我知道了',
                      onConfirm: () {
                        CustomSnackBar.show(
                          context,
                          message: '已确认警告',
                          type: SnackBarType.info,
                        );
                      },
                    );
                  },
                  style: CustomButtonStyle.secondary,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '确认弹窗',
                  icon: Icons.help_outline,
                  onPressed: () async {
                    final result = await CustomDialog.showConfirm(
                      context: context,
                      title: '确认操作',
                      message: '您确定要删除这个项目吗？此操作无法撤销。',
                      confirmText: '确认删除',
                      cancelText: '取消',
                      onConfirm: () {
                        CustomSnackBar.show(
                          context,
                          message: '项目已删除',
                          type: SnackBarType.success,
                        );
                      },
                    );
                    if (result == false) {
                      CustomSnackBar.show(
                        context,
                        message: '已取消操作',
                        type: SnackBarType.info,
                      );
                    }
                  },
                  style: CustomButtonStyle.primary,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '成功弹窗',
                  icon: Icons.check_circle,
                  onPressed: () {
                    CustomDialog.showSuccess(
                      context: context,
                      title: '操作成功',
                      message: '您的数据已成功保存到云端！',
                      confirmText: '太好了',
                    );
                  },
                  style: CustomButtonStyle.primary,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '错误弹窗',
                  icon: Icons.error,
                  onPressed: () {
                    CustomDialog.showError(
                      context: context,
                      title: '操作失败',
                      message: '网络连接失败，请检查您的网络设置后重试。',
                      confirmText: '我知道了',
                    );
                  },
                  style: CustomButtonStyle.danger,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '信息弹窗',
                  icon: Icons.info,
                  onPressed: () {
                    CustomDialog.showInfo(
                      context: context,
                      title: '系统通知',
                      message: '系统将在今晚 23:00 进行维护，预计持续 2 小时。',
                      confirmText: '知道了',
                    );
                  },
                  style: CustomButtonStyle.outlined,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 表单弹窗
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_document,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '表单弹窗',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '在弹窗中快速收集用户信息',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: '简单表单弹窗',
                  icon: Icons.person_add,
                  onPressed: () {
                    FormDialog.show(
                      context: context,
                      title: '添加联系人',
                      fields: [
                        FormField(
                          key: 'name',
                          label: '姓名',
                          hint: '请输入姓名',
                          icon: Icons.person,
                        ),
                        FormField(
                          key: 'phone',
                          label: '电话',
                          hint: '请输入电话号码',
                          icon: Icons.phone,
                          type: FormFieldType.phone,
                        ),
                        FormField(
                          key: 'email',
                          label: '邮箱',
                          hint: '请输入邮箱地址',
                          icon: Icons.email,
                          type: FormFieldType.email,
                          isRequired: false,
                        ),
                      ],
                      onSubmit: (data) {
                        CustomSnackBar.show(
                          context,
                          message: '联系人 ${data['name']} 已添加',
                          type: SnackBarType.success,
                        );
                      },
                    );
                  },
                  style: CustomButtonStyle.primary,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '复杂表单弹窗',
                  icon: Icons.assignment,
                  onPressed: () {
                    FormDialog.show(
                      context: context,
                      title: '创建新任务',
                      fields: [
                        FormField(
                          key: 'title',
                          label: '任务标题',
                          hint: '请输入任务标题',
                          icon: Icons.title,
                        ),
                        FormField(
                          key: 'description',
                          label: '任务描述',
                          hint: '请输入详细描述',
                          icon: Icons.description,
                          type: FormFieldType.multiline,
                          isRequired: false,
                        ),
                        FormField(
                          key: 'priority',
                          label: '优先级',
                          hint: '请选择优先级',
                          icon: Icons.flag,
                          type: FormFieldType.dropdown,
                          options: ['低', '中', '高', '紧急'],
                        ),
                        FormField(
                          key: 'assignee',
                          label: '负责人',
                          hint: '请选择负责人',
                          icon: Icons.person,
                          type: FormFieldType.dropdown,
                          options: ['张三', '李四', '王五', '赵六'],
                        ),
                      ],
                      onSubmit: (data) {
                        CustomSnackBar.show(
                          context,
                          message: '任务《${data['title']}》已创建',
                          type: SnackBarType.success,
                          duration: const Duration(seconds: 3),
                        );
                      },
                    );
                  },
                  style: CustomButtonStyle.secondary,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: '反馈表单弹窗',
                  icon: Icons.feedback,
                  onPressed: () {
                    FormDialog.show(
                      context: context,
                      title: '意见反馈',
                      confirmText: '提交反馈',
                      fields: [
                        FormField(
                          key: 'type',
                          label: '反馈类型',
                          hint: '请选择反馈类型',
                          icon: Icons.category,
                          type: FormFieldType.dropdown,
                          options: ['功能建议', '问题报告', '使用咨询', '其他'],
                        ),
                        FormField(
                          key: 'content',
                          label: '反馈内容',
                          hint: '请详细描述您的反馈',
                          icon: Icons.message,
                          type: FormFieldType.multiline,
                        ),
                        FormField(
                          key: 'contact',
                          label: '联系方式',
                          hint: '请输入您的邮箱或电话（选填）',
                          icon: Icons.contact_mail,
                          type: FormFieldType.email,
                          isRequired: false,
                        ),
                      ],
                      onSubmit: (data) {
                        // 模拟提交
                        Future.delayed(const Duration(milliseconds: 500), () {
                          CustomDialog.showSuccess(
                            context: context,
                            title: '提交成功',
                            message: '感谢您的反馈！我们会尽快处理。',
                          );
                        });
                      },
                    );
                  },
                  style: CustomButtonStyle.outlined,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
