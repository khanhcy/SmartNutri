import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/ui/components/section_header.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/sn_info_tile.dart';
import 'package:smartnutri/src/core/ui/components/stat_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});

  final AuthUser user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _reminderEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return PageTemplate(
      title: 'Hồ sơ',
      subtitle: 'Thông tin tài khoản và mục tiêu dinh dưỡng.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Mục tiêu'),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 620) {
                return const Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Cân nặng mục tiêu',
                        value: '68 kg',
                        helper: 'Hiện tại 72 kg',
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatCard(
                        label: 'Mục tiêu ngày',
                        value: '2,100 kcal',
                        helper: 'Protein 120g',
                      ),
                    ),
                  ],
                );
              }
              return const Column(
                children: [
                  StatCard(
                    label: 'Cân nặng mục tiêu',
                    value: '68 kg',
                    helper: 'Hiện tại 72 kg',
                  ),
                  SizedBox(height: AppSpacing.md),
                  StatCard(
                    label: 'Mục tiêu ngày',
                    value: '2,100 kcal',
                    helper: 'Protein 120g',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SNCard(
            child: SNInfoTile(
              title: 'Gợi ý cá nhân hóa',
              subtitle: 'Giảm 300 kcal buổi tối để đạt mục tiêu cân nặng nhanh hơn.',
              leadingIcon: Icons.auto_awesome_outlined,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tài khoản'),
          const SizedBox(height: AppSpacing.sm),
          SNCard(
            child: Column(
              children: [
                SNInfoTile(
                  title: 'Email',
                  subtitle: widget.user.email,
                  leadingIcon: Icons.email_outlined,
                ),
                const Divider(),
                const SNInfoTile(
                  title: 'Hồ sơ cá nhân',
                  subtitle: 'Cập nhật tuổi, chiều cao, cân nặng',
                  leadingIcon: Icons.person_outline,
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tùy chỉnh'),
          const SizedBox(height: AppSpacing.sm),
          SNCard(
            child: Column(
              children: [
                const SNInfoTile(
                  title: 'Ngôn ngữ ứng dụng',
                  subtitle: 'Tiếng Việt',
                  leadingIcon: Icons.language_outlined,
                  trailing: Icon(Icons.chevron_right),
                ),
                const Divider(),
                SwitchListTile(
                  value: _reminderEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nhắc ghi bữa ăn'),
                  subtitle: const Text('Thông báo vào 07:00, 12:00, 18:00'),
                  onChanged: (value) => setState(() => _reminderEnabled = value),
                ),
                const Divider(),
                SwitchListTile(
                  value: _darkModeEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark mode'),
                  subtitle: const Text('Bật giao diện tối'),
                  onChanged: (value) => setState(() => _darkModeEnabled = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
