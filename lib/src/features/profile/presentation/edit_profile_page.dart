import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.profile,
    required this.goal,
  });

  final UserProfile profile;
  final NutritionGoal goal;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _calorieController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbController;
  late final TextEditingController _fatController;
  late final TextEditingController _waterController;

  late String _gender;
  late String _activityLevel;
  bool _isSaving = false;
  String? _error;

  // Whether the goal fields were manually edited by the user
  bool _goalManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    final g = widget.goal;
    _nameController = TextEditingController(text: p.displayName);
    _ageController = TextEditingController(text: p.age.toString());
    _heightController = TextEditingController(text: p.heightCm.toString());
    _weightController = TextEditingController(text: p.weightKg.toString());
    _calorieController = TextEditingController(text: g.calorieTarget.toString());
    _proteinController = TextEditingController(text: g.proteinG.toString());
    _carbController = TextEditingController(text: g.carbG.toString());
    _fatController = TextEditingController(text: g.fatG.toString());
    _waterController = TextEditingController(text: g.waterTargetMl.round().toString());
    _gender = p.gender;
    _activityLevel = p.activityLevel;

    // Auto-recalculate goals whenever profile inputs change
    _heightController.addListener(_onProfileInputChanged);
    _weightController.addListener(_onProfileInputChanged);
    _ageController.addListener(_onProfileInputChanged);

    // Mark goal as manually edited if user touches those fields
    _calorieController.addListener(_onGoalManualEdit);
    _proteinController.addListener(_onGoalManualEdit);
    _carbController.addListener(_onGoalManualEdit);
    _fatController.addListener(_onGoalManualEdit);
  }

  void _onProfileInputChanged() {
    // Only auto-recalculate if user hasn't manually overridden the goal fields
    if (!_goalManuallyEdited) {
      _recalculateGoal();
    }
  }

  void _onGoalManualEdit() {
    // Once user edits goal fields directly, stop auto-recalculating
    _goalManuallyEdited = true;
  }

  @override
  void dispose() {
    _heightController.removeListener(_onProfileInputChanged);
    _weightController.removeListener(_onProfileInputChanged);
    _ageController.removeListener(_onProfileInputChanged);
    _calorieController.removeListener(_onGoalManualEdit);
    _proteinController.removeListener(_onGoalManualEdit);
    _carbController.removeListener(_onGoalManualEdit);
    _fatController.removeListener(_onGoalManualEdit);
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _recalculateGoal() {
    final weight = double.tryParse(_weightController.text) ?? widget.profile.weightKg;
    final height = double.tryParse(_heightController.text) ?? widget.profile.heightCm;
    final age = int.tryParse(_ageController.text) ?? widget.profile.age;
    final goal = NutritionGoal.fromProfile(
      uid: widget.profile.uid,
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
    );
    // Temporarily remove manual-edit listeners while we auto-fill
    _calorieController.removeListener(_onGoalManualEdit);
    _proteinController.removeListener(_onGoalManualEdit);
    _carbController.removeListener(_onGoalManualEdit);
    _fatController.removeListener(_onGoalManualEdit);
    setState(() {
      _goalManuallyEdited = false;
      _calorieController.text = goal.calorieTarget.toString();
      _proteinController.text = goal.proteinG.toString();
      _carbController.text = goal.carbG.toString();
      _fatController.text = goal.fatG.toString();
    });
    _calorieController.addListener(_onGoalManualEdit);
    _proteinController.addListener(_onGoalManualEdit);
    _carbController.addListener(_onGoalManualEdit);
    _fatController.addListener(_onGoalManualEdit);
  }

  @override
  Widget build(BuildContext context) {
    return SNScaffold(
      appBar: const SNAppBar(title: 'Chỉnh sửa hồ sơ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin cá nhân',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              SNTextField(
                controller: _nameController,
                label: 'Tên hiển thị',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: SNTextField(
                      controller: _ageController,
                      label: 'Tuổi',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          int.tryParse(v ?? '') == null ? 'Nhập số hợp lệ' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration:
                          const InputDecoration(labelText: 'Giới tính'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Nam')),
                        DropdownMenuItem(value: 'female', child: Text('Nữ')),
                        DropdownMenuItem(value: 'other', child: Text('Khác')),
                      ],
                      onChanged: (v) {
                        setState(() => _gender = v ?? 'male');
                        if (!_goalManuallyEdited) _recalculateGoal();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: SNTextField(
                      controller: _heightController,
                      label: 'Chiều cao (cm)',
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null
                          ? 'Nhập số hợp lệ'
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SNTextField(
                      controller: _weightController,
                      label: 'Cân nặng (kg)',
                      keyboardType: TextInputType.number,
                      validator: (v) => double.tryParse(v ?? '') == null
                          ? 'Nhập số hợp lệ'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _activityLevel,
                decoration:
                    const InputDecoration(labelText: 'Mức vận động'),
                items: const [
                  DropdownMenuItem(value: 'sedentary', child: Text('Ít vận động')),
                  DropdownMenuItem(value: 'light', child: Text('Vận động nhẹ')),
                  DropdownMenuItem(value: 'moderate', child: Text('Vận động vừa')),
                  DropdownMenuItem(value: 'active', child: Text('Năng động')),
                ],
                onChanged: (v) {
                  setState(() => _activityLevel = v ?? 'light');
                  if (!_goalManuallyEdited) _recalculateGoal();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: _recalculateGoal,
                icon: const Icon(Icons.calculate_outlined, size: 18),
                label: const Text('Tính lại mục tiêu tự động'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Mục tiêu dinh dưỡng',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              SNTextField(
                controller: _calorieController,
                label: 'Calo mục tiêu / ngày (kcal)',
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') == null ? 'Nhập số hợp lệ' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: SNTextField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Nhập số hợp lệ'
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SNTextField(
                      controller: _carbController,
                      label: 'Carb (g)',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Nhập số hợp lệ'
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SNTextField(
                      controller: _fatController,
                      label: 'Fat (g)',
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? '') == null
                          ? 'Nhập số hợp lệ'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SNTextField(
                controller: _waterController,
                label: 'Mục tiêu nước / ngày (ml)',
                keyboardType: TextInputType.number,
                validator: (v) => int.tryParse(v ?? '') == null
                    ? 'Nhập số hợp lệ'
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              SizedBox(
                width: double.infinity,
                child: SNButton(
                  label: 'Lưu thay đổi',
                  onPressed: _save,
                  isLoading: _isSaving,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final updatedProfile = UserProfile(
      uid: widget.profile.uid,
      email: widget.profile.email,
      displayName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
      gender: _gender,
      activityLevel: _activityLevel,
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );

    final updatedGoal = NutritionGoal(
      uid: widget.goal.uid,
      calorieTarget: int.parse(_calorieController.text.trim()),
      proteinG: int.parse(_proteinController.text.trim()),
      carbG: int.parse(_carbController.text.trim()),
      fatG: int.parse(_fatController.text.trim()),
      targetWeightKg: widget.goal.targetWeightKg,
      waterTargetMl: double.parse(_waterController.text.trim()),
      updatedAt: DateTime.now(),
    );

    try {
      await Future.wait([
        context.read<ProfileService>().upsertProfile(updatedProfile),
        context.read<GoalService>().upsertGoal(updatedGoal),
      ]);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu thay đổi'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = firestoreWriteErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
