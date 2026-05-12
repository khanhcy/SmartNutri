import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/goal_service.dart';
import 'package:smartnutri/src/core/services/profile_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/nutrition/domain/nutrition_goal.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';
import 'package:smartnutri/src/features/profile/presentation/edit_profile_page.dart';

import 'widgets/account_card.dart';
import 'widgets/goal_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_card.dart';
import 'widgets/sign_out_button.dart';
import 'widgets/stats_row.dart';
import 'widgets/weight_tracker_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;

    return MultiProvider(
      providers: [
        StreamProvider<UserProfile?>(
          create: (context) => context.read<ProfileService>().watchProfile(uid),
          initialData: null,
        ),
        StreamProvider<NutritionGoal?>(
          create: (context) => context.read<GoalService>().watchGoal(uid),
          initialData: null,
        ),
      ],
      child: _ProfileContent(uid: uid),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfile?>();
    final goal = context.watch<NutritionGoal?>() ?? NutritionGoal.defaultGoal(uid);

    return PageTemplate(
      title: 'Hồ sơ',
      subtitle: 'Thông tin tài khoản và mục tiêu dinh dưỡng.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(profile: profile),
          const SizedBox(height: AppSpacing.md),
          if (profile != null) ...[
            StatsRow(profile: profile),
            const SizedBox(height: AppSpacing.md),
          ],
          GoalCard(goal: goal, uid: uid),
          const SizedBox(height: AppSpacing.md),
          SNCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bar_chart_outlined),
              title: const Text('Thống kê 7 ngày'),
              subtitle: const Text(
                'Trung bình calo, macro, nước và chuỗi ngày đạt mục tiêu',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppPaths.stats),
            ),
          ),
          if (profile != null) ...[
            const SizedBox(height: AppSpacing.md),
            WeightTrackerCard(profile: profile),
          ],
          const SizedBox(height: AppSpacing.md),
          AccountCard(
            email: context.read<AuthService>().currentUser?.email ?? '',
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
          const SettingsCard(),
          const SizedBox(height: AppSpacing.md),
          const SignOutButton(),
        ],
      ),
    );
  }
}
