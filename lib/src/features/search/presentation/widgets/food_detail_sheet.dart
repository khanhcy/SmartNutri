import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/services/recent_foods_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class FoodDetailSheet extends StatefulWidget {
  const FoodDetailSheet({
    super.key,
    required this.food,
    required this.authService,
    required this.mealService,
    required this.recentFoods,
  });
  final FoodItem food;
  final AuthService authService;
  final MealService mealService;
  final RecentFoodsService recentFoods;

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
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
      await widget.recentFoods.add(widget.food);
      if (mounted) {
        HapticFeedback.lightImpact();
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
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
          _error = firestoreWriteErrorMessage(e);
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
