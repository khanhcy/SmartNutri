import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/screen_section.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
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
  bool _isSearching = false;

  static const List<String> _filters = [
    'High protein',
    'Low carb',
    'Quick meal',
    'Vietnamese',
  ];

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Tìm món ăn',
      subtitle: 'Tìm nhanh để thêm vào nhật ký bữa ăn.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SNTextField(
            controller: _queryController,
            label: 'Tên món ăn',
            hint: 'Ví dụ: cơm gà, phở bò',
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
                    _simulateSearch();
                  });
                },
              );
            }).toList(),
          ),
          ScreenSection(
            title: 'Kết quả gợi ý',
            actionLabel: 'Sắp xếp',
            child: _buildSearchState(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SNButton(
            label: 'Thêm món đã chọn vào bữa trưa',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSearchState() {
    if (_isSearching) {
      return const SizedBox(
        height: 180,
        child: LoadingView(message: 'Đang tìm món phù hợp...'),
      );
    }

    if (_queryController.text.trim().isEmpty) {
      return const SizedBox(
        height: 180,
        child: EmptyView(
          title: 'Nhập tên món để bắt đầu',
          description: 'Ví dụ: phở bò, cơm gà, salad.',
        ),
      );
    }

    return const SNCard(
      child: Column(
        children: [
          SNInfoTile(
            title: 'Phở bò',
            subtitle: '350 kcal - 20g protein',
            leadingIcon: Icons.ramen_dining_outlined,
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          SNInfoTile(
            title: 'Cơm gà nướng',
            subtitle: '520 kcal - 32g protein',
            leadingIcon: Icons.rice_bowl_outlined,
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(),
          SNInfoTile(
            title: 'Salad ức gà',
            subtitle: '290 kcal - 28g protein',
            leadingIcon: Icons.eco_outlined,
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Future<void> _simulateSearch() async {
    setState(() => _isSearching = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  void _onQueryChanged() {
    setState(() {});
    if (_queryController.text.trim().isNotEmpty) {
      _simulateSearch();
    }
  }
}
