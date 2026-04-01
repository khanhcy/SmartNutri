import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/screen_section.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/stat_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Tổng quan hôm nay',
      subtitle: 'Theo dõi lượng dinh dưỡng hiệu quả mỗi ngày.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              final items = const [
                StatCard(
                  label: 'Calories còn lại',
                  value: '1,250 kcal',
                  helper: 'Mục tiêu 2,100 kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
                StatCard(
                  label: 'Nước đã uống',
                  value: '1.6 / 2.5 L',
                  helper: 'Còn thiếu 0.9 L',
                  icon: Icons.water_drop_outlined,
                ),
              ];
              if (isWide) {
                return Row(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      Expanded(child: items[i]),
                      if (i != items.length - 1)
                        const SizedBox(width: AppSpacing.md),
                    ],
                  ],
                );
              }
              return const Column(
                children: [
                  StatCard(
                    label: 'Calories còn lại',
                    value: '1,250 kcal',
                    helper: 'Mục tiêu 2,100 kcal',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  SizedBox(height: AppSpacing.md),
                  StatCard(
                    label: 'Nước đã uống',
                    value: '1.6 / 2.5 L',
                    helper: 'Còn thiếu 0.9 L',
                    icon: Icons.water_drop_outlined,
                  ),
                ],
              );
            },
          ),
          ScreenSection(
            title: 'Thao tác nhanh',
            child: Row(
              children: [
                Expanded(
                  child: SNButton(
                    label: 'Thêm bữa ăn',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SNButton(
                    label: 'Cập nhật nước',
                    variant: SNButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const ScreenSection(
            title: 'Tiến độ macro',
            child: SNCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MacroProgress(label: 'Protein', ratio: 0.62, value: '74g / 120g'),
                  SizedBox(height: AppSpacing.md),
                  _MacroProgress(label: 'Carb', ratio: 0.48, value: '116g / 240g'),
                  SizedBox(height: AppSpacing.md),
                  _MacroProgress(label: 'Fat', ratio: 0.55, value: '44g / 80g'),
                ],
              ),
            ),
          ),
          const ScreenSection(
            title: 'Bữa ăn gần đây',
            actionLabel: 'Xem tất cả',
            child: SNCard(
              child: Column(
                children: [
                  SNInfoTile(
                    title: 'Bữa sáng',
                    subtitle: 'Phở bò - 350 kcal',
                    leadingIcon: Icons.breakfast_dining_outlined,
                  ),
                  Divider(),
                  SNInfoTile(
                    title: 'Bữa trưa',
                    subtitle: 'Cơm gà nướng - 520 kcal',
                    leadingIcon: Icons.lunch_dining_outlined,
                  ),
                ],
              ),
            ),
          ),
          const ScreenSection(
            title: 'Gợi ý',
            child: SNCard(
              child: SNInfoTile(
                title: 'Gợi ý hôm nay',
                subtitle: 'Bạn còn thiếu 46g protein để đạt mục tiêu ngày.',
                leadingIcon: Icons.tips_and_updates_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  const _MacroProgress({
    required this.label,
    required this.ratio,
    required this.value,
  });

  final String label;
  final double ratio;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(value),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(value: ratio),
      ],
    );
  }
}
