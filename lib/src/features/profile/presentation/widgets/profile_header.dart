import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/profile/domain/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});
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
