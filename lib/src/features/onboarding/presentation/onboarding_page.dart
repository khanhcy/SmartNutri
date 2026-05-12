import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/utils/firestore_write_message.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.user});
  final AuthUser user;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int _currentStep = 0;
  String _gender = 'male';
  String _activityLevel = 'light';
  bool _isSaving = false;
  String? _error;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    final fbName = widget.user.displayName;
    _nameController.text = (fbName != null && fbName.isNotEmpty)
        ? fbName
        : widget.user.email.split('@').first;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    final error = _validateCurrentStep();
    if (error != null) {
      setState(() => _error = error);
      HapticFeedback.vibrate();
      return;
    }
    setState(() => _error = null);
    HapticFeedback.lightImpact();

    if (_currentStep < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    } else {
      _saveProfile();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() => _error = null);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) return 'Vui lòng nhập tên';
        break;
      case 1:
        if (int.tryParse(_ageController.text) == null) return 'Nhập tuổi hợp lệ';
        break;
      case 2:
        if (double.tryParse(_heightController.text) == null) return 'Nhập chiều cao hợp lệ';
        break;
      case 3:
        if (double.tryParse(_weightController.text) == null) return 'Nhập cân nặng hợp lệ';
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Progress & Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: _currentStep > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: _currentStep > 0 ? _prevPage : null,
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: (_currentStep + 1) / 6),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable manual swipe to enforce validation
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildSlide(
                    icon: Icons.waving_hand_rounded,
                    title: 'Chào bạn mới!',
                    subtitle: 'Chúng tôi nên gọi bạn là gì?',
                    input: _buildLargeInput(
                      controller: _nameController,
                      hint: 'Tên của bạn',
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  _buildSlide(
                    icon: Icons.cake_rounded,
                    title: 'Bạn bao nhiêu tuổi?',
                    subtitle: 'Giúp chúng tôi tính toán trao đổi chất chính xác hơn.',
                    input: _buildLargeInput(
                      controller: _ageController,
                      hint: 'Tuổi',
                      suffix: 'tuổi',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  _buildSlide(
                    icon: Icons.height_rounded,
                    title: 'Chiều cao của bạn?',
                    subtitle: 'Chỉ số này dùng để tính BMI.',
                    input: _buildLargeInput(
                      controller: _heightController,
                      hint: 'Chiều cao',
                      suffix: 'cm',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  _buildSlide(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Cân nặng hiện tại?',
                    subtitle: 'Đừng lo, thông tin này được bảo mật tuyệt đối.',
                    input: _buildLargeInput(
                      controller: _weightController,
                      hint: 'Cân nặng',
                      suffix: 'kg',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  _buildSlide(
                    icon: Icons.wc_rounded,
                    title: 'Giới tính sinh học',
                    subtitle: 'Ảnh hưởng đến nhu cầu calo mỗi ngày.',
                    input: _buildSelector(
                      value: _gender,
                      items: {'male': 'Nam', 'female': 'Nữ', 'other': 'Khác'},
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                  _buildSlide(
                    icon: Icons.directions_run_rounded,
                    title: 'Mức độ vận động',
                    subtitle: 'Bạn thường di chuyển như thế nào trong tuần?',
                    input: _buildSelector(
                      value: _activityLevel,
                      items: {
                        'sedentary': 'Ít vận động (Ngồi nhiều)',
                        'light': 'Vận động nhẹ (1-3 ngày/tuần)',
                        'moderate': 'Vận động vừa (3-5 ngày/tuần)',
                        'active': 'Năng động (6-7 ngày/tuần)'
                      },
                      onChanged: (v) => setState(() => _activityLevel = v),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Area: Error & Next Button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _isSaving ? null : _nextPage,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _currentStep == 5 ? 'Bắt đầu ngay' : 'Tiếp tục',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget input,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Pulsing icon with glow
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnim.value,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.8),
                      colorScheme.primaryContainer.withValues(alpha: 0.2),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary
                          .withValues(alpha: 0.2 * _pulseAnim.value),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(icon, size: 68, color: colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          input,
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    ));
  }

  Widget _buildLargeInput({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        suffixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        border: InputBorder.none,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      ),
    );
  }

  Widget _buildSelector({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: items.entries.map((e) {
        final isSelected = e.key == value;
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(e.key);
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isSelected) Icon(Icons.check_circle_rounded, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
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
