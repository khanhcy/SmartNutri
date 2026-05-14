import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/services/subscription_service.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/features/subscription/domain/subscription_status.dart';

class SubscriptionSummaryCard extends StatelessWidget {
  const SubscriptionSummaryCard({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    final service = context.read<SubscriptionService>();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<SubscriptionOverview>(
      stream: service.watchOverview(uid),
      builder: (context, snapshot) {
        final overview = snapshot.data;
        final hasError = snapshot.hasError;
        final isPremium = overview?.isPremium ?? false;

        final title = hasError
            ? 'Gói SmartNutri'
            : isPremium
                ? 'SmartNutri Premium'
                : 'Gói Free';

        final subtitle = hasError
            ? 'Không tải được trạng thái gói. Nhấn để xem chi tiết.'
            : _buildSubtitle(overview);

        final icon = hasError
            ? Icons.warning_amber_rounded
            : isPremium
                ? Icons.workspace_premium
                : Icons.lock_open_outlined;

        final iconColor = hasError
            ? colorScheme.error
            : isPremium
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant;

        return SNCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(icon, color: iconColor),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppPaths.subscription),
          ),
        );
      },
    );
  }

  String _buildSubtitle(SubscriptionOverview? overview) {
    if (overview == null) return 'Đang tải trạng thái gói...';
    if (overview.isPremium) return 'Premium • AI scan không giới hạn trong MVP';

    final usage = overview.aiScanUsage;
    if (usage.remaining <= 0) {
      return 'Free • Đã hết lượt AI scan tháng này (${usage.used}/${usage.limit})';
    }
    if (usage.remaining <= 1) {
      return 'Free • Sắp hết lượt AI scan (${usage.remaining}/${usage.limit})';
    }
    return 'Free • Còn ${usage.remaining}/${usage.limit} lượt AI scan';
  }
}
