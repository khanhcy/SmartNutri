import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/stat_card.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class MealLogPage extends StatefulWidget {
  const MealLogPage({super.key});

  @override
  State<MealLogPage> createState() => _MealLogPageState();
}

class _MealLogPageState extends State<MealLogPage> {
  bool _showSyncError = false;

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Nhật ký bữa ăn',
      subtitle: 'Ghi lại bữa sáng, trưa, tối và bữa phụ.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Tổng hôm nay',
                  value: '870 kcal',
                  helper: 'Còn lại 1,230 kcal',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  label: 'Bữa đã ghi',
                  value: '2 / 4',
                  helper: 'Sáng, trưa',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Hôm nay'),
          const SizedBox(height: AppSpacing.sm),
          const SNCard(
            child: Row(
              children: [
                Expanded(
                  child: _MealSlot(title: 'Sáng', kcal: '350 kcal', icon: Icons.breakfast_dining),
                ),
                Expanded(
                  child: _MealSlot(title: 'Trưa', kcal: '520 kcal', icon: Icons.lunch_dining),
                ),
                Expanded(
                  child: _MealSlot(title: 'Tối', kcal: '0 kcal', icon: Icons.dinner_dining),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Lịch sử gần đây'),
          const SizedBox(height: AppSpacing.sm),
          if (_showSyncError)
            SizedBox(
              height: 140,
              child: ErrorView(
                message: 'Không tải được lịch sử bữa ăn. Vui lòng thử lại.',
                onRetry: () => setState(() => _showSyncError = false),
              ),
            )
          else
          const SNCard(
            child: Column(
              children: [
                SNInfoTile(
                  title: '30/03 - Tong 1,760 kcal',
                  subtitle: 'Protein 108g | Carb 180g | Fat 58g',
                  leadingIcon: Icons.calendar_today_outlined,
                ),
                Divider(),
                SNInfoTile(
                  title: '29/03 - Tong 1,930 kcal',
                  subtitle: 'Protein 118g | Carb 208g | Fat 64g',
                  leadingIcon: Icons.calendar_today_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const EmptyView(
            title: 'Chưa có bữa phụ hôm nay',
            description: 'Thêm bữa phụ để đủ mục tiêu calorie.',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: SNButton(
              label: 'Thêm bữa ăn',
              onPressed: () {},
              variant: SNButtonVariant.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SNButton(
              label: _showSyncError ? 'Ẩn lỗi đồng bộ' : 'Mô phỏng lỗi đồng bộ',
              variant: SNButtonVariant.ghost,
              onPressed: () => setState(() => _showSyncError = !_showSyncError),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSlot extends StatelessWidget {
  const _MealSlot({
    required this.title,
    required this.kcal,
    required this.icon,
  });

  final String title;
  final String kcal;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Icon(icon),
          const SizedBox(height: AppSpacing.xs),
          Text(title),
          const SizedBox(height: AppSpacing.xs),
          Text(kcal, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
