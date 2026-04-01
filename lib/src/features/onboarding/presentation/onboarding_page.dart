import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.user});

  final AuthUser user;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Thiet lap ho so')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoan tat onboarding de bat dau theo doi suc khoe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ten hien thi'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Tuoi'),
                  validator: _numberValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Chieu cao (cm)'),
                  validator: _numberValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Can nang (kg)'),
                  validator: _numberValidator,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gioi tinh'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Nam')),
                    DropdownMenuItem(value: 'female', child: Text('Nu')),
                    DropdownMenuItem(value: 'other', child: Text('Khac')),
                  ],
                  onChanged: (value) => setState(() => _gender = value ?? 'male'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _activityLevel,
                  decoration: const InputDecoration(labelText: 'Muc van dong'),
                  items: const [
                    DropdownMenuItem(value: 'sedentary', child: Text('It van dong')),
                    DropdownMenuItem(value: 'light', child: Text('Van dong nhe')),
                    DropdownMenuItem(value: 'moderate', child: Text('Van dong vua')),
                    DropdownMenuItem(value: 'active', child: Text('Nang dong')),
                  ],
                  onChanged: (value) =>
                      setState(() => _activityLevel = value ?? 'light'),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Luu ho so'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Khong duoc de trong';
    }
    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Khong duoc de trong';
    }
    if (num.tryParse(value) == null) {
      return 'Can nhap so hop le';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
    } catch (_) {
      setState(() {
        _error = 'Luu ho so that bai. Vui long thu lai.';
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
