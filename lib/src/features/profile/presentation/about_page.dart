import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((i) {
      if (mounted) setState(() => _info = i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final version = _info != null
        ? '${_info!.version} (${_info!.buildNumber})'
        : '…';

    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SmartNutri',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text('Theo dõi dinh dưỡng mỗi ngày.',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            _InfoRow(icon: Icons.info_outline, label: 'Phiên bản', value: version),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              icon: Icons.restaurant_outlined,
              label: 'Ứng dụng',
              value: 'Ghi nhật ký bữa ăn, nước uống và mục tiêu macro '
                  'đồng bộ trên Firebase.',
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'SmartNutri giúp bạn theo dõi calo, protein, carb, fat và lượng nước, '
              'với lời nhắc tùy chọn và tổng quan 7 ngày.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
