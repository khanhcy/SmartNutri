import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
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
  DateTime? logDate,
}) {
  final day = logDate ?? DateTime.now();
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
      child: _CustomMealSheet(
        initialMealType: initialMealType,
        logDate: day,
      ),
    ),
  );
}

class _CustomMealSheet extends StatefulWidget {
  const _CustomMealSheet({
    required this.initialMealType,
    required this.logDate,
  });
  final MealType initialMealType;
  final DateTime logDate;

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
    _proteinCtrl.addListener(_updateCalories);
    _carbCtrl.addListener(_updateCalories);
    _fatCtrl.addListener(_updateCalories);
  }

  void _updateCalories() {
    final p = double.tryParse(_proteinCtrl.text) ?? 0;
    final c = double.tryParse(_carbCtrl.text) ?? 0;
    final f = double.tryParse(_fatCtrl.text) ?? 0;
    
    // Only auto-update if macros are greater than 0
    if (p > 0 || c > 0 || f > 0) {
      final kcal = (p * 4) + (c * 4) + (f * 9);
      if (kcal > 0) {
        _kcalCtrl.text = kcal.round().toString();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _portionCtrl.dispose();
    _kcalCtrl.dispose();
    _proteinCtrl.removeListener(_updateCalories);
    _proteinCtrl.dispose();
    _carbCtrl.removeListener(_updateCalories);
    _carbCtrl.dispose();
    _fatCtrl.removeListener(_updateCalories);
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
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              Text(
                'Nhập món thủ công',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ghi lại các bữa ăn chưa có trong danh sách. Nếu nhập Macro, Calo sẽ tự động khớp.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Tên món
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Tên món ăn',
                  hintText: 'Vd: Phở bò tái, Sinh tố bơ...',
                  prefixIcon: const Icon(Icons.restaurant_menu),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên món' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: _StyledTextField(
                      controller: _portionCtrl,
                      label: 'Khẩu phần',
                      suffix: 'g',
                      icon: Icons.scale,
                      validator: _positiveNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StyledTextField(
                      controller: _kcalCtrl,
                      label: 'Tổng Calo',
                      suffix: 'kcal',
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Dinh dưỡng đa lượng (Tùy chọn)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              Row(
                children: [
                  Expanded(
                    child: _StyledTextField(
                      controller: _proteinCtrl,
                      label: 'Protein',
                      suffix: 'g',
                      iconColor: Colors.blue,
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StyledTextField(
                      controller: _carbCtrl,
                      label: 'Carb',
                      suffix: 'g',
                      iconColor: Colors.orange,
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StyledTextField(
                      controller: _fatCtrl,
                      label: 'Fat',
                      suffix: 'g',
                      iconColor: Colors.pink,
                      validator: _nonNegativeNumberValidator,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<MealType>(
                initialValue: _mealType,
                decoration: InputDecoration(
                  labelText: 'Thêm vào bữa',
                  prefixIcon: const Icon(Icons.schedule),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: MealType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _mealType = v ?? MealType.lunch),
              ),

              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!,
                    style: TextStyle(color: colorScheme.error, fontSize: 13)),
              ],

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Text('Lưu vào nhật ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
      date: AppDateUtils.toDateStr(widget.logDate),
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
          _error = firestoreWriteErrorMessage(e);
        });
      }
    }
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.suffix,
    this.icon,
    this.iconColor,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData? icon;
  final Color? iconColor;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: TextStyle(
            color: iconColor ?? colorScheme.primary, fontWeight: FontWeight.bold),
        prefixIcon: icon != null
            ? Icon(icon, color: iconColor ?? colorScheme.primary, size: 20)
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
    );
  }
}
