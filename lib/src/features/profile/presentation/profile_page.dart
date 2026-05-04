import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/providers/app_settings_provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';
import 'package:smartnutri/src/features/profile/presentation/edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;

    return StreamBuilder<UserProfile?>(
      stream: context.read<ProfileService>().watchProfile(uid),
      builder: (context, profileSnap) {
        final profile = profileSnap.data;

        return StreamBuilder<NutritionGoal?>(
          stream: context.read<GoalService>().watchGoal(uid),
          builder: (context, goalSnap) {
            final goal = goalSnap.data ?? NutritionGoal.defaultGoal(uid);

            return PageTemplate(
              title: 'Hồ sơ',
              subtitle: 'Thông tin tài khoản và mục tiêu dinh dưỡng.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(profile: profile),
                  const SizedBox(height: AppSpacing.md),
                  if (profile != null) ...[
                    _StatsRow(profile: profile),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _GoalCard(goal: goal, uid: uid),
                  const SizedBox(height: AppSpacing.md),
                  _AccountCard(
                    email: context.read<AuthService>().currentUser!.email,
                    onEditProfile: profile == null
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => EditProfilePage(
                                  profile: profile,
                                  goal: goal,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _SettingsCard(),
                  const SizedBox(height: AppSpacing.md),
                  _SignOutButton(authService: context.read<AuthService>()),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = profile?.displayName ?? '...';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            initial,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            if (profile != null)
              Text(
                '${profile!.gender == 'male' ? 'Nam' : profile!.gender == 'female' ? 'Nữ' : 'Khác'}  •  ${profile!.age} tuổi  •  ${_activityLabel(profile!.activityLevel)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ],
    );
  }

  String _activityLabel(String level) => switch (level) {
        'sedentary' => 'Ít vận động',
        'light' => 'Vận động nhẹ',
        'moderate' => 'Vận động vừa',
        'active' => 'Năng động',
        _ => level,
      };
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final bmi = profile.weightKg / ((profile.heightCm / 100) * (profile.heightCm / 100));
    final bmiLabel = bmi < 18.5
        ? 'Gầy'
        : bmi < 25
            ? 'Bình thường'
            : bmi < 30
                ? 'Thừa cân'
                : 'Béo phì';
    final bmiColor = bmi < 18.5
        ? Colors.blue
        : bmi < 25
            ? Colors.green
            : bmi < 30
                ? Colors.orange
                : Colors.red;

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Chiều cao',
            value: '${profile.heightCm.round()} cm',
            icon: Icons.height,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            label: 'Cân nặng',
            value: '${profile.weightKg.toStringAsFixed(1)} kg',
            icon: Icons.monitor_weight_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatChip(
            label: 'BMI',
            value: bmi.toStringAsFixed(1),
            sub: bmiLabel,
            subColor: bmiColor,
            icon: Icons.analytics_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.sub,
    this.subColor,
  });
  final String label;
  final String value;
  final String? sub;
  final Color? subColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SNCard(
      child: Column(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (sub != null)
            Text(sub!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: subColor))
          else
            Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.uid});
  final NutritionGoal goal;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Mục tiêu dinh dưỡng',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Icon(Icons.flag_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _GoalRow(label: 'Calo / ngày', value: '${goal.calorieTarget} kcal',
              icon: Icons.local_fire_department_outlined),
          const Divider(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniGoal(label: 'Protein', value: '${goal.proteinG}g',
                    color: Colors.blue),
              ),
              Expanded(
                child: _MiniGoal(label: 'Carb', value: '${goal.carbG}g',
                    color: Colors.orange),
              ),
              Expanded(
                child: _MiniGoal(label: 'Fat', value: '${goal.fatG}g',
                    color: Colors.pink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MiniGoal extends StatelessWidget {
  const _MiniGoal({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.email, required this.onEditProfile});
  final String email;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: Text(email),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: const Text('Chỉnh sửa hồ sơ'),
            subtitle: const Text('Cập nhật thông tin cá nhân & mục tiêu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onEditProfile,
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.sm, top: AppSpacing.xs, bottom: AppSpacing.xs),
            child: Text(
              'Tùy chỉnh',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            secondary: Icon(
              settings.isDarkMode ? Icons.dark_mode : Icons.light_mode_outlined,
            ),
            title: const Text('Dark mode'),
            subtitle: Text(settings.isDarkMode ? 'Giao diện tối' : 'Giao diện sáng'),
            value: settings.isDarkMode,
            onChanged: settings.setDarkMode,
          ),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.authService});
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: () => _confirmSignOut(context),
      icon: const Icon(Icons.logout),
      label: const Text('Đăng xuất'),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi SmartNutri không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await authService.signOut();
    }
  }
}
