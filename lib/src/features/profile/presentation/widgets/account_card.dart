import 'package:flutter/material.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/features/profile/presentation/about_page.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key, required this.email, required this.onEditProfile});
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
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Giới thiệu'),
            subtitle: const Text('Phiên bản và mô tả ứng dụng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutPage()),
                ),
          ),
        ],
      ),
    );
  }
}
