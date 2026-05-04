import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/meal_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/core/utils/date_utils.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:uuid/uuid.dart';

/// Bottom sheet để nhập bữa ăn thủ công (không cần tìm trong danh sách).
void showCustomMealSheet(
  BuildContext context, {
  MealType initialMealType = MealType.lunch,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => MultiProvider(
      providers: [
        Provider.value(value: context.read<AuthService>()),
        Provider.value(value: context.read<MealService>()),
      ],
      child: _CustomMealSheet(initialMealType: initialMealType),
    ),
  );
}

class _CustomMealSheet extends StatefulWidget {
  const _CustomMealSheet({required this.initialMealType});
  final MealType initialMealType;

  @override
  State<_CustomMealSheet> createState() => _CustomMealSheetState();
}

class _CustomMealSheetState extends State<_CustomMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _portionCtrl = TextEditingController(text: '100');
  final _kcalCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController(text: '0');
  final _carbCtrl = TextEditingController(text: '0');
  final _fatCtrl = TextEditingController(text: '0');

  late MealType _mealType;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _portionCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.dispose();
    _carbCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, viewInsets + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
              Row(
                children: [
                  Icon(Icons.edit_note, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Nhập bữa ăn thủ công',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Nhập thông tin dinh dưỡng cho bữa ăn chưa có trong danh sách.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),

              // Tên món
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Tên món ăn *',
                  hintText: 'Vd: Cơm nhà, Gà luộc tự làm...',
                  prefixIcon: Icon(Icons.restaurant_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập tên món ăn' : null,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Khẩu phần + Calo (hàng ngang)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _portionCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Khẩu phần *',
                        suffixText: 'g',
                      ),
                      validator: _positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _kcalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Calo *',
                        suffixText: 'kcal',
                      ),
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Macro row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Protein',
                        suffixText: 'g',
                        suffixStyle: TextStyle(color: Colors.blue.shade600),
                      ),
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextFormField(
                      controller: _carbCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Carb',
                        suffixText: 'g',
                        suffixStyle: TextStyle(color: Colors.orange.shade600),
                      ),
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: TextFormField(
                      controller: _fatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Fat',
                        suffixText: 'g',
                        suffixStyle: TextStyle(color: Colors.pink.shade600),
                      ),
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Loại bữa ăn
              DropdownButtonFormField<MealType>(
                initialValue: _mealType,
                decoration: const InputDecoration(
                  labelText: 'Loại bữa ăn',
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: MealType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _mealType = v ?? MealType.lunch),
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!,
                    style: TextStyle(color: colorScheme.error, fontSize: 13)),
              ],

              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Lưu vào nhật ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _positiveNumberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Phải > 0';
    return null;
  }

  String? _nonNegativeNumberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = double.tryParse(v);
    if (n == null || n < 0) return 'Không hợp lệ';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    final uid = context.read<AuthService>().currentUser!.uid;
    final now = DateTime.now();

    final entry = MealEntry(
      id: const Uuid().v4(),
      uid: uid,
      date: AppDateUtils.todayStr(),
      mealType: _mealType,
      foodName: _nameCtrl.text.trim(),
      portionG: double.parse(_portionCtrl.text),
      calorieKcal: double.parse(_kcalCtrl.text),
      proteinG: double.parse(_proteinCtrl.text),
      carbG: double.parse(_carbCtrl.text),
      fatG: double.parse(_fatCtrl.text),
      loggedAt: now,
    );

    try {
      await context.read<MealService>().addEntry(uid, entry);
      if (mounted) {
        HapticFeedback.lightImpact();
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${entry.foodName}" vào nhật ký'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Không thể lưu: ${e.toString()}';
        });
      }
    }
  }
}
