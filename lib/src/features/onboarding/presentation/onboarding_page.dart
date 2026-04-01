import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/dashboard/presentation/main_shell_page.dart';
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
    _nameController.text = widget.user.email.split('@').first;
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
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: AppSpacing.sm),
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
          value: _gender,
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
          value: _activityLevel,
          decoration: const InputDecoration(labelText: 'Mức vận động hằng ngày?'),
          items: const [
            DropdownMenuItem(value: 'sedentary', child: Text('Ít vận động')),
            DropdownMenuItem(value: 'light', child: Text('Vận động nhẹ')),
            DropdownMenuItem(value: 'moderate', child: Text('Vận động vừa')),
            DropdownMenuItem(value: 'active', child: Text('Năng động')),
          ],
          onChanged: (value) => setState(() => _activityLevel = value ?? 'light'),
        );
    }
  }

  void _onNextPressed() {
    final validationError = _validateCurrentStep();
    if (validationError != null) {
      setState(() {
        _error = validationError;
      });
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
    if (value == null || value.trim().isEmpty) {
      return 'Không được để trống';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Không được để trống';
    }
    if (num.tryParse(value) == null) {
      return 'Cần nhập số hợp lệ';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final profile = UserProfile(
      uid: widget.user.uid,
      email: widget.user.email,
      displayName: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      heightCm: double.parse(_heightController.text.trim()),
      weightKg: double.parse(_weightController.text.trim()),
      gender: _gender,
      activityLevel: _activityLevel,
      onboardingCompleted: true,
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<ProfileService>().upsertProfile(profile);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MainShellPage(user: widget.user),
        ),
      );
    } catch (_) {
      setState(() {
        _error = 'Lưu hồ sơ thất bại. Vui lòng thử lại.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
