import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/recent_foods_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

/// Call [showAddMealSheet] to open the bottom sheet.
/// Pass [preselectedFood] to skip search and go directly to confirm step
/// (used by AI scan / barcode / suggestions / quick-add).
Future<void> showAddMealSheet(
  BuildContext context, {
  MealType initialMealType = MealType.lunch,
  DateTime? logDate,
  FoodItem? preselectedFood,
}) {
  final day = logDate ?? DateTime.now();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MultiProvider(
      providers: [
        Provider.value(value: context.read<AuthService>()),
        Provider.value(value: context.read<FoodService>()),
        Provider.value(value: context.read<MealService>()),
      ],
      child: _AddMealSheet(
        initialMealType: initialMealType,
        logDate: day,
        preselectedFood: preselectedFood,
      ),
    ),
  );
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({
    required this.initialMealType,
    required this.logDate,
    this.preselectedFood,
  });
  final MealType initialMealType;
  /// Calendar day stored on the meal entry (`date` field).
  final DateTime logDate;
  final FoodItem? preselectedFood;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _searchController = TextEditingController();
  final _portionController = TextEditingController();
  late MealType _selectedMealType;
  FoodItem? _selectedFood;
  bool _isSaving = false;
  String? _error;

  List<FoodItem> _results = [];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
    if (widget.preselectedFood != null) {
      _selectedFood = widget.preselectedFood;
      _portionController.text =
          widget.preselectedFood!.defaultPortionG.round().toString();
    } else {
      _initResults();
    }
    _searchController.addListener(_onSearch);
  }

  Future<void> _initResults() async {
    final foods = await context.read<FoodService>().getAll();
    if (mounted) setState(() => _results = foods.take(10).toList());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    _portionController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchController.text;
    final service = context.read<FoodService>();
    if (q.trim().isEmpty) {
      service.getAll().then((foods) {
        if (mounted) {
          setState(() {
            _selectedFood = null;
            _results = foods.take(10).toList();
          });
        }
      });
    } else {
      service.search(q).then((results) {
        if (mounted) {
          setState(() {
            _selectedFood = null;
            _results = results;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Thêm bữa ăn',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Tìm tên món ăn...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                  ),
                ),
              ),
              if (_selectedFood == null) ...[
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: _results.isEmpty
                      ? const Center(child: Text('Không tìm thấy món phù hợp'))
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: _results.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final food = _results[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    colorScheme.primaryContainer,
                                child: Icon(
                                  Icons.restaurant_outlined,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(food.name),
                              subtitle: Text(
                                '${food.calorieKcal.round()} kcal / 100g  •  '
                                'P: ${food.proteinG.round()}g  '
                                'C: ${food.carbG.round()}g  '
                                'F: ${food.fatG.round()}g',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedFood = food;
                                  _portionController.text =
                                      food.defaultPortionG.round().toString();
                                });
                              },
                            );
                          },
                        ),
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: _buildConfirmStep(colorScheme),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfirmStep(ColorScheme colorScheme) {
    final food = _selectedFood!;
    final portion = double.tryParse(_portionController.text) ??
        food.defaultPortionG;
    final kcal = food.calorieForPortion(portion);
    final protein = food.proteinForPortion(portion);
    final carb = food.carbForPortion(portion);
    final fat = food.fatForPortion(portion);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _selectedFood = null),
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Chọn lại',
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                food.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Loại bữa ăn', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<MealType>(
          showSelectedIcon: false,
          segments: MealType.values
              .map(
                (t) => ButtonSegment<MealType>(
                  value: t,
                  label: Text(t.label, style: const TextStyle(fontSize: 11)),
                ),
              )
              .toList(),
          selected: {_selectedMealType},
          onSelectionChanged: (s) =>
              setState(() => _selectedMealType = s.first),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPortionPresets(),
        Text('Khẩu phần (gram)',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _portionController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            suffixText: 'g',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientBadge(label: 'Calo', value: '${kcal.round()} kcal'),
              _NutrientBadge(label: 'Protein', value: '${protein.toStringAsFixed(1)}g'),
              _NutrientBadge(label: 'Carb', value: '${carb.toStringAsFixed(1)}g'),
              _NutrientBadge(label: 'Fat', value: '${fat.toStringAsFixed(1)}g'),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Thêm vào nhật ký'),
          ),
        ),
      ],
    );
  }

  Widget _buildPortionPresets() {
    final presets = [
      _PortionPreset('100g', 100),
      _PortionPreset('200g', 200),
      _PortionPreset('1 chén', 250),
      _PortionPreset('1 tô', 400),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: presets.map((p) {
          final isActive = _portionController.text == p.grams.toString();
          return ChoiceChip(
            label: Text(p.label, style: const TextStyle(fontSize: 13)),
            selected: isActive,
            onSelected: (_) {
              _portionController.text = p.grams.toString();
              setState(() {}); // trigger nutrient preview update
            },
            visualDensity: VisualDensity.compact,
          );
        }).toList(),
      ),
    );
  }

  Future<void> _save() async {
    final food = _selectedFood!;
    final portion = double.tryParse(_portionController.text);
    if (portion == null || portion <= 0) {
      setState(() => _error = 'Nhập khẩu phần hợp lệ');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final uid = context.read<AuthService>().currentUser!.uid;
    final now = DateTime.now();
    final dateStr = AppDateUtils.toDateStr(widget.logDate);
    final mealService = context.read<MealService>();
    final recentFoods = context.read<RecentFoodsService>();

    final entry = MealEntry(
      id: '',
      uid: uid,
      date: dateStr,
      mealType: _selectedMealType,
      foodName: food.name,
      portionG: portion,
      calorieKcal: food.calorieForPortion(portion),
      proteinG: food.proteinForPortion(portion),
      carbG: food.carbForPortion(portion),
      fatG: food.fatForPortion(portion),
      loggedAt: now,
    );

    try {
      await mealService.addEntry(uid, entry);
      recentFoods.add(_selectedFood!);
      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _error = firestoreWriteErrorMessage(e);
        });
      }
    }
  }
}

class _NutrientBadge extends StatelessWidget {
  const _NutrientBadge({required this.label, required this.value});
  final String label;
  final String value;

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

class _PortionPreset {
  final String label;
  final int grams;
  const _PortionPreset(this.label, this.grams);
}
