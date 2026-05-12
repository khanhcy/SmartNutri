import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/recent_foods_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

import 'widgets/food_tile.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _queryController = TextEditingController();
  Timer? _debounce;
  List<FoodItem> _results = [];
  List<String> _categories = ['Tất cả'];
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _initCategories();
    _initResults();
    _queryController.addListener(_onQueryChanged);
  }

  Future<void> _initCategories() async {
    final cats = await context.read<FoodService>().getCategories();
    if (mounted) {
      setState(() => _categories = ['Tất cả', ...cats]);
    }
  }

  Future<void> _initResults() async {
    final foods = await context.read<FoodService>().getAll();
    if (mounted) {
      setState(() => _results = foods);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () async {
      if (!mounted) return;
      final q = _queryController.text.trim();
      final service = context.read<FoodService>();
      final items = q.isEmpty ? await service.getAll() : await service.search(q);
      if (mounted) {
        setState(() => _results = _filterByCategory(items));
      }
    });
  }

  List<FoodItem> _filterByCategory(List<FoodItem> items) {
    if (_selectedCategory == 'Tất cả') return items;
    return items.where((f) => f.category == _selectedCategory).toList();
  }

  void _selectCategory(String cat) {
    setState(() {
      _selectedCategory = cat;
      _onQueryChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PageTemplate(
      title: 'Tìm món ăn',
      subtitle: 'Tra cứu dinh dưỡng và thêm vào nhật ký.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    hintText: 'Tìm tên món ăn... (vd: phở bò, cơm gà)',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _queryController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Xoá tìm kiếm',
                            onPressed: () {
                              _queryController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: 'Nhập thủ công',
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 48),
                  ),
                  onPressed: () => showCustomMealSheet(context),
                  child: const Icon(Icons.edit_note),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) => _selectCategory(cat),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (_queryController.text.isEmpty && _selectedCategory == 'Tất cả') ...[
            Consumer<RecentFoodsService>(
              builder: (context, recents, _) {
                if (recents.recents.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đã dùng gần đây',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SNCard(
                      child: Column(
                        children: [
                          for (int i = 0; i < recents.recents.length; i++) ...[
                            FoodTile(food: recents.recents[i]),
                            if (i < recents.recents.length - 1)
                              const Divider(height: 1),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tất cả món (${_results.length})',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: colorScheme.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                );
              },
            ),
          ],

          if (_results.isNotEmpty &&
              (_queryController.text.isNotEmpty || _selectedCategory != 'Tất cả'))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '${_results.length} món',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),

          if (_results.isEmpty)
            SNCard(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.search_off_rounded,
                          size: 48, color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Không tìm thấy món phù hợp',
                        style: Theme.of(context).textTheme.titleMedium),
                    if (_queryController.text.isNotEmpty ||
                        _selectedCategory != 'Tất cả') ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bạn có thể nhập thủ công bằng nút bên cạnh',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gợi ý theo buổi',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: colorScheme.primary,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ..._suggestionTiles(context),
                    ],
                  ],
                ),
              ),
            )
          else
            SNCard(
              child: Column(
                children: [
                  for (int i = 0; i < _results.length; i++) ...[
                    FoodTile(food: _results[i]),
                    if (i < _results.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _suggestionTiles(BuildContext context) {
    // synchronous cache-read — suggestions are pre-loaded
    final foodService = context.read<FoodService>();
    return [
      FutureBuilder<List<FoodItem>>(
        future: foodService.suggestedForCurrentMealtime(),
        builder: (context, snap) {
          final foods = snap.data ?? [];
          if (foods.isEmpty) return const SizedBox.shrink();
          return Column(
            children: [
              for (int i = 0; i < foods.length; i++) ...[
                FoodTile(food: foods[i]),
                if (i < foods.length - 1) const Divider(height: 1),
              ],
            ],
          );
        },
      ),
    ];
  }
}
