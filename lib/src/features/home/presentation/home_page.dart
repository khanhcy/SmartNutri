import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
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
      title: 'Tong quan hom nay',
      subtitle: 'Theo doi luong dinh duong hieu qua moi ngay.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 640;
              final items = const [
                StatCard(
                  label: 'Calories con lai',
                  value: '1,250 kcal',
                  helper: 'Muc tieu 2,100 kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
                StatCard(
                  label: 'Nuoc da uong',
                  value: '1.6 / 2.5 L',
                  helper: 'Con thieu 0.9 L',
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
                    label: 'Calories con lai',
                    value: '1,250 kcal',
                    helper: 'Muc tieu 2,100 kcal',
                    icon: Icons.local_fire_department_outlined,
                  ),
                  SizedBox(height: AppSpacing.md),
                  StatCard(
                    label: 'Nuoc da uong',
                    value: '1.6 / 2.5 L',
                    helper: 'Con thieu 0.9 L',
                    icon: Icons.water_drop_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tien do macro'),
          const SizedBox(height: AppSpacing.sm),
          const SNCard(
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
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Bua an gan day', actionLabel: 'Xem tat ca'),
          const SNCard(
            child: Column(
              children: [
                SNInfoTile(
                  title: 'Bua sang',
                  subtitle: 'Pho bo - 350 kcal',
                  leadingIcon: Icons.breakfast_dining_outlined,
                ),
                Divider(),
                SNInfoTile(
                  title: 'Bua trua',
                  subtitle: 'Com ga nuong - 520 kcal',
                  leadingIcon: Icons.lunch_dining_outlined,
                ),
              ],
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
