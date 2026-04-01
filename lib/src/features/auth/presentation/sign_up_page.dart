import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SNScaffold(
      appBar: const SNAppBar(title: 'Đăng ký tài khoản'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              SNTextField(
                controller: _emailController,
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
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
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Mật khẩu tối thiểu 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              const SizedBox(height: AppSpacing.sm),
              SNButton(
                label: 'Tạo tài khoản',
                onPressed: _signUp,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await context.read<AuthService>().signUp(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
