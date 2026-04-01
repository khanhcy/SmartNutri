import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final TextEditingController _queryController = TextEditingController();
  final Set<String> _selectedFilters = {'High protein'};

  static const List<String> _filters = [
    'High protein',
    'Low carb',
    'Quick meal',
    'Vietnamese',
  ];

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Tim mon an',
      subtitle: 'Tim nhanh de them vao nhat ky bua an.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SNTextField(
            controller: _queryController,
            label: 'Ten mon an',
            hint: 'Vi du: com ga, pho bo',
            prefixIcon: const Icon(Icons.search),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _filters.map((filter) {
              final selected = _selectedFilters.contains(filter);
              return FilterChip(
                label: Text(filter),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedFilters.add(filter);
                    } else {
                      _selectedFilters.remove(filter);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Ket qua goi y', actionLabel: 'Sap xep'),
          const SNCard(
            child: Column(
              children: [
                SNInfoTile(
                  title: 'Pho bo',
                  subtitle: '350 kcal - 20g protein',
                  leadingIcon: Icons.ramen_dining_outlined,
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
                SNInfoTile(
                  title: 'Com ga nuong',
                  subtitle: '520 kcal - 32g protein',
                  leadingIcon: Icons.rice_bowl_outlined,
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
                SNInfoTile(
                  title: 'Salad uc ga',
                  subtitle: '290 kcal - 28g protein',
                  leadingIcon: Icons.eco_outlined,
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SNButton(
            label: 'Them mon da chon vao bua trua',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
