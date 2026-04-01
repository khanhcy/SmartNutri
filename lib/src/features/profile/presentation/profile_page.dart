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
      title: 'Ho so',
      subtitle: 'Thong tin tai khoan va muc tieu dinh duong.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Muc tieu'),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Can nang muc tieu',
                  value: '68 kg',
                  helper: 'Hien tai 72 kg',
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: StatCard(
                  label: 'Muc tieu ngay',
                  value: '2,100 kcal',
                  helper: 'Protein 120g',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tai khoan'),
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
                  title: 'Ho so ca nhan',
                  subtitle: 'Cap nhat tuoi, chieu cao, can nang',
                  leadingIcon: Icons.person_outline,
                  trailing: Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Tuy chinh'),
          const SizedBox(height: AppSpacing.sm),
          SNCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _reminderEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nhac ghi bua an'),
                  subtitle: const Text('Thong bao vao 07:00, 12:00, 18:00'),
                  onChanged: (value) => setState(() => _reminderEnabled = value),
                ),
                const Divider(),
                SwitchListTile(
                  value: _darkModeEnabled,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark mode'),
                  subtitle: const Text('Bat giao dien toi'),
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
