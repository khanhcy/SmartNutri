import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/auth/presentation/widgets/cinematic_input.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.tertiary.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.lg),

                            // Back button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            Text(
                              'Tạo tài khoản\nmiễn phí',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                    letterSpacing: -1.0,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Theo dõi dinh dưỡng của bạn mọi lúc, mọi nơi.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            CinematicInput(
                              controller: _nameController,
                              label: 'Tên hiển thị',
                              icon: Icons.badge_outlined,
                              textCapitalization: TextCapitalization.words,
                              autofocus: true,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Nhập tên của bạn'
                                      : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            CinematicInput(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Nhập email';
                                if (!v.contains('@')) return 'Email không hợp lệ';
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            CinematicInput(
                              controller: _passwordController,
                              label: 'Mật khẩu',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Mật khẩu tối thiểu 6 ký tự'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            CinematicInput(
                              controller: _confirmController,
                              label: 'Xác nhận mật khẩu',
                              icon: Icons.lock_reset_rounded,
                              obscureText: _obscureConfirm,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => setState(
                                    () => _obscureConfirm = !_obscureConfirm),
                              ),
                              validator: (v) => v != _passwordController.text
                                  ? 'Mật khẩu không khớp'
                                  : null,
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: colorScheme.error, size: 18),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: TextStyle(
                                          color: colorScheme.onErrorContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: AppSpacing.xl),

                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _isLoading ? null : _signUp,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5)
                                    : const Text('Tạo tài khoản',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md),
                                  child: Text('hoặc',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant)),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Tiếp tục với Google'),
                              onPressed:
                                  _isLoading ? null : _signUpWithGoogle,
                            ),

                            if (defaultTargetPlatform == TargetPlatform.iOS ||
                                defaultTargetPlatform ==
                                    TargetPlatform.macOS) ...[
                              const SizedBox(height: AppSpacing.sm),
                              SignInWithAppleButton(
                                onPressed: () {
                                  if (!_isLoading) _signUpWithApple();
                                },
                              ),
                            ],

                            const SizedBox(height: AppSpacing.xl),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Đã có tài khoản?',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  child: const Text('Đăng nhập',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signInWithGoogle();
    } catch (error) {
      if (mounted) {
        setState(() =>
            _error = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithApple() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await context.read<AuthService>().signInWithApple();
    } catch (error) {
      if (mounted) {
        setState(() =>
            _error = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
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
            displayName: _nameController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() =>
            _error = error.toString().replaceFirst('Exception: ', ''));
        HapticFeedback.vibrate();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
