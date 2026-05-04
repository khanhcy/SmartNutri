import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_text_field.dart';
import 'package:smartnutri/src/core/ui/layout/sn_app_bar.dart';
import 'package:smartnutri/src/core/ui/layout/sn_scaffold.dart';
import 'package:smartnutri/src/core/ui/theme/app_colors.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SNScaffold(
      appBar: const SNAppBar(title: 'Tạo tài khoản'),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.35),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 56,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tạo tài khoản mới',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Bắt đầu hành trình theo dõi dinh dưỡng của bạn.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SNCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SNTextField(
                            controller: _nameController,
                            label: 'Tên của bạn',
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Nhập tên hiển thị'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SNTextField(
                            controller: _emailController,
                            label: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty || !v.contains('@')) {
                                return 'Nhập email hợp lệ';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SNTextField(
                            controller: _passwordController,
                            label: 'Mật khẩu',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Mật khẩu tối thiểu 6 ký tự'
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SNTextField(
                            controller: _confirmController,
                            label: 'Xác nhận mật khẩu',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (v) => v != _passwordController.text
                                ? 'Mật khẩu không khớp'
                                : null,
                          ),
                          if (_error != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: AppSpacing.sm),
                              child: Text(
                                _error!,
                                style:
                                    const TextStyle(color: AppColors.danger),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),
                          SNButton(
                            label: 'Tạo tài khoản',
                            onPressed: _signUp,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SNButton(
                      label: 'Đã có tài khoản? Đăng nhập',
                      variant: SNButtonVariant.ghost,
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().signUp(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
