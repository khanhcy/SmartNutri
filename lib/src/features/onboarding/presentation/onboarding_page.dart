import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
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

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.user});

  final AuthUser user;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  int _currentStep = 0;
  String _gender = 'male';
  String _activityLevel = 'light';
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Ưu tiên displayName từ Firebase Auth (đăng ký có nhập tên), fallback phần email
    final fbName = widget.user.displayName;
    _nameController.text = (fbName != null && fbName.isNotEmpty)
        ? fbName
        : widget.user.email.split('@').first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SNScaffold(
      appBar: const SNAppBar(title: 'Thiết lập hồ sơ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trả lời từng câu hỏi để hoàn tất hồ sơ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            LinearProgressIndicator(value: (_currentStep + 1) / 6),
            const SizedBox(height: AppSpacing.xs),
            Text('Câu hỏi ${_currentStep + 1}/6'),
            const SizedBox(height: AppSpacing.lg),
            _buildCurrentQuestion(),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: SNButton(
                      label: 'Quay lại',
                      onPressed: _isSaving
                          ? null
                          : () => setState(() {
                                _error = null;
                                _currentStep -= 1;
                              }),
                      variant: SNButtonVariant.secondary,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SNButton(
                    label: _currentStep == 5 ? 'Hoàn tất' : 'Tiếp theo',
                    onPressed: _isSaving ? null : _onNextPressed,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentQuestion() {
    switch (_currentStep) {
      case 0:
        return SNTextField(
          controller: _nameController,
          label: 'Bạn muốn chúng tôi gọi bạn là gì?',
          hint: 'Ví dụ: An',
        );
      case 1:
        return SNTextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          label: 'Bạn bao nhiêu tuổi?',
        );
      case 2:
        return SNTextField(
          controller: _heightController,
          keyboardType: TextInputType.number,
          label: 'Chiều cao của bạn (cm)?',
        );
      case 3:
        return SNTextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          label: 'Cân nặng hiện tại (kg)?',
        );
      case 4:
        return DropdownButtonFormField<String>(
          initialValue: _gender,
          decoration: const InputDecoration(labelText: 'Giới tính của bạn?'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('Nam')),
            DropdownMenuItem(value: 'female', child: Text('Nữ')),
            DropdownMenuItem(value: 'other', child: Text('Khác')),
          ],
          onChanged: (value) => setState(() => _gender = value ?? 'male'),
        );
      default:
        return DropdownButtonFormField<String>(
          initialValue: _activityLevel,
          decoration:
              const InputDecoration(labelText: 'Mức vận động hằng ngày?'),
          items: const [
            DropdownMenuItem(value: 'sedentary', child: Text('Ít vận động (ngồi nhiều)')),
            DropdownMenuItem(value: 'light', child: Text('Vận động nhẹ (1-3 ngày/tuần)')),
            DropdownMenuItem(value: 'moderate', child: Text('Vận động vừa (3-5 ngày/tuần)')),
            DropdownMenuItem(value: 'active', child: Text('Năng động (6-7 ngày/tuần)')),
          ],
          onChanged: (value) =>
              setState(() => _activityLevel = value ?? 'light'),
        );
    }
  }

  void _onNextPressed() {
    final validationError = _validateCurrentStep();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    if (_currentStep < 5) {
      setState(() {
        _error = null;
        _currentStep += 1;
      });
      return;
    }

    _saveProfile();
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _requiredValidator(_nameController.text);
      case 1:
        return _numberValidator(_ageController.text);
      case 2:
        return _numberValidator(_heightController.text);
      case 3:
        return _numberValidator(_weightController.text);
      default:
        return null;
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được để trống';
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Không được để trống';
    if (num.tryParse(value) == null) return 'Cần nhập số hợp lệ';
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final weight = double.parse(_weightController.text.trim());
    final height = double.parse(_heightController.text.trim());
    final age = int.parse(_ageController.text.trim());

    final profile = UserProfile(
      uid: widget.user.uid,
      email: widget.user.email,
      displayName: _nameController.text.trim(),
      age: age,
      heightCm: height,
      weightKg: weight,
      gender: _gender,
      activityLevel: _activityLevel,
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );

    final goal = NutritionGoal.fromProfile(
      uid: widget.user.uid,
      weightKg: weight,
      heightCm: height,
      age: age,
      gender: _gender,
      activityLevel: _activityLevel,
    );

    try {
      await Future.wait([
        context.read<ProfileService>().upsertProfile(profile),
        context.read<GoalService>().upsertGoal(goal),
      ]);
      // AuthGate's StreamBuilder detects onboardingCompleted=true and navigates automatically.
    } catch (e) {
      if (mounted) {
        setState(() => _error = firestoreWriteErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
