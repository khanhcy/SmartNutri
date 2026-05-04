import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final _queryController = TextEditingController();
  Timer? _debounce;
  List<FoodItem> _results = [];
  late final List<String> _categories;
  String _selectedCategory = 'Tất cả';

  @override
  void initState() {
    super.initState();
    // Use pre-computed cached category list from FoodService
    _categories = ['Tất cả', ...FoodService.categories];
    _results = context.read<FoodService>().getAll();
    _queryController.addListener(_onQueryChanged);
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
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      final q = _queryController.text.trim();
      setState(() {
        _results = q.isEmpty
            ? _filterByCategory(context.read<FoodService>().getAll())
            : _filterByCategory(context.read<FoodService>().search(q));
      });
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
          // ── Search bar ─────────────────────────────────────────────────
          TextField(
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
          const SizedBox(height: AppSpacing.sm),

          // ── Category filter chips (derived from data) ──────────────────
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

          // ── Results count hint ─────────────────────────────────────────
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Text(
                '${_results.length} món',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),

          // ── Results list ───────────────────────────────────────────────
          if (_results.isEmpty)
            SNCard(
              child: Column(
                children: [
                  Icon(Icons.search_off,
                      size: 40, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Không tìm thấy món phù hợp'),
                ],
              ),
            )
          else
            SNCard(
              child: Column(
                children: [
                  for (int i = 0; i < _results.length; i++) ...[
                    _FoodTile(food: _results[i]),
                    if (i < _results.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food});
  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.restaurant_outlined,
            color: colorScheme.primary, size: 20),
      ),
      title: Text(food.name),
      subtitle: Text(
        '${food.calorieKcal.round()} kcal / 100g  •  '
        'P:${food.proteinG.round()}g  '
        'C:${food.carbG.round()}g  '
        'F:${food.fatG.round()}g',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        onPressed: () => _showDetailSheet(context),
        icon: Icon(Icons.add_circle_outline, color: colorScheme.primary),
        tooltip: 'Thêm vào nhật ký',
      ),
      onTap: () => _showDetailSheet(context),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FoodDetailSheet(
        food: food,
        authService: context.read<AuthService>(),
        mealService: context.read<MealService>(),
      ),
    );
  }
}

class _FoodDetailSheet extends StatefulWidget {
  const _FoodDetailSheet({
    required this.food,
    required this.authService,
    required this.mealService,
  });
  final FoodItem food;
  final AuthService authService;
  final MealService mealService;

  @override
  State<_FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<_FoodDetailSheet> {
  final _portionController = TextEditingController();
  MealType _mealType = MealType.lunch;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _portionController.text = widget.food.defaultPortionG.round().toString();
    final hour = DateTime.now().hour;
    _mealType = hour < 10
        ? MealType.breakfast
        : hour < 14
            ? MealType.lunch
            : hour < 19
                ? MealType.dinner
                : MealType.snack;
  }

  @override
  void dispose() {
    _portionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final portion =
        double.tryParse(_portionController.text) ?? food.defaultPortionG;
    final kcal = food.calorieForPortion(portion);
    final protein = food.proteinForPortion(portion);
    final carb = food.carbForPortion(portion);
    final fat = food.fatForPortion(portion);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(food.name, style: Theme.of(context).textTheme.titleLarge),
          Text(food.category, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),

          // Portion input
          TextField(
            controller: _portionController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Khẩu phần',
              suffixText: 'g',
              errorText: _portionError(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Macro preview
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Badge('${kcal.round()} kcal', 'Calo'),
                _Badge('${protein.toStringAsFixed(1)}g', 'Protein'),
                _Badge('${carb.toStringAsFixed(1)}g', 'Carb'),
                _Badge('${fat.toStringAsFixed(1)}g', 'Fat'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Meal type selector
          DropdownButtonFormField<MealType>(
            initialValue: _mealType,
            decoration: InputDecoration(
              labelText: 'Loại bữa ăn',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
            items: MealType.values
                .map((t) =>
                    DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) =>
                setState(() => _mealType = v ?? MealType.lunch),
          ),

          // Error message
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: TextStyle(
                  color: colorScheme.error, fontSize: 13),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving || _portionError() != null ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Thêm vào nhật ký'),
            ),
          ),
        ],
      ),
    );
  }

  String? _portionError() {
    final v = double.tryParse(_portionController.text);
    if (v == null || v <= 0) return 'Khẩu phần phải lớn hơn 0';
    return null;
  }

  Future<void> _save() async {
    final portion = double.tryParse(_portionController.text);
    if (portion == null || portion <= 0) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final uid = widget.authService.currentUser!.uid;
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final entry = MealEntry(
      id: '',
      uid: uid,
      date: dateStr,
      mealType: _mealType,
      foodName: widget.food.name,
      portionG: portion,
      calorieKcal: widget.food.calorieForPortion(portion),
      proteinG: widget.food.proteinForPortion(portion),
      carbG: widget.food.carbForPortion(portion),
      fatG: widget.food.fatForPortion(portion),
      loggedAt: now,
    );

    try {
      await widget.mealService.addEntry(uid, entry);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm ${widget.food.name} vào nhật ký'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = 'Không thể lưu: ${e.toString()}';
        });
      }
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
