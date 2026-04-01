import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class MealLogPage extends StatelessWidget {
  const MealLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Nhat ky bua an',
      subtitle: 'Ghi lai bua sang, trua, toi va bua phu.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Hom nay'),
          const SizedBox(height: AppSpacing.sm),
          const SNCard(
            child: Row(
              children: [
                Expanded(
                  child: _MealSlot(title: 'Sang', kcal: '350 kcal', icon: Icons.breakfast_dining),
                ),
                Expanded(
                  child: _MealSlot(title: 'Trua', kcal: '520 kcal', icon: Icons.lunch_dining),
                ),
                Expanded(
                  child: _MealSlot(title: 'Toi', kcal: '0 kcal', icon: Icons.dinner_dining),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Lich su gan day'),
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
            title: 'Chua co bua phu hom nay',
            description: 'Them bua phu de du muc tieu calorie.',
          ),
          const SizedBox(height: AppSpacing.md),
          SNButton(
            label: 'Them bua an',
            onPressed: () {},
            variant: SNButtonVariant.secondary,
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
