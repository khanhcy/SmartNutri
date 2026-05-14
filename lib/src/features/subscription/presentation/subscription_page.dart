import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';
import 'package:smartnutri/src/core/services/subscription_service.dart';
import 'package:smartnutri/src/core/ui/components/screen_section.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/components/state_view.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/subscription/domain/subscription_status.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthService>().currentUser!.uid;
    final service = context.read<SubscriptionService>();

    return StreamBuilder<SubscriptionOverview>(
      stream: service.watchOverview(uid),
      builder: (context, snapshot) {
        return PageTemplate(
          title: 'Gói SmartNutri',
          subtitle: 'Quản lý quyền lợi Free/Premium và lượt AI scan.',
          child: _buildContent(context, snapshot),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AsyncSnapshot<SubscriptionOverview> snapshot,
  ) {
    if (snapshot.hasError) {
      return const ErrorView(
        message: 'Không tải được thông tin gói. Vui lòng thử lại sau.',
      );
    }

    final overview = snapshot.data;
    if (overview == null) {
      return const LoadingView(message: 'Đang tải thông tin gói...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScreenSection(
          title: 'Gói hiện tại',
          topSpacing: 0,
          child: _PlanCard(overview: overview),
        ),
        ScreenSection(
          title: 'AI scan tháng ${overview.aiScanUsage.monthKey}',
          child: _QuotaCard(overview: overview),
        ),
        ScreenSection(
          title: 'Quyền lợi Premium',
          child: _BenefitsCard(isPremium: overview.isPremium),
        ),
        if (!overview.isPremium)
          ScreenSection(
            title: 'Nâng cấp',
            child: _UpgradeCard(
              onTap: () => context.push(
                '${AppPaths.paywall}?source=subscription_page',
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.overview});

  final SubscriptionOverview overview;

  @override
  Widget build(BuildContext context) {
    final isPremium = overview.isPremium;
    final colorScheme = Theme.of(context).colorScheme;

    return SNCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPremium
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.lock_open_outlined,
              color: isPremium ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'SmartNutri Premium' : 'Gói Free',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isPremium
                      ? 'Bạn đang mở khóa toàn bộ quyền lợi Premium hiện có trong MVP.'
                      : 'Bạn đang dùng gói miễn phí với quota AI scan hằng tháng.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotaCard extends StatelessWidget {
  const _QuotaCard({required this.overview});

  final SubscriptionOverview overview;

  @override
  Widget build(BuildContext context) {
    final usage = overview.aiScanUsage;
    final colorScheme = Theme.of(context).colorScheme;

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overview.isPremium)
            Text(
              'Premium được dùng AI scan không giới hạn trong bản MVP.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else ...[
            LinearProgressIndicator(
              value: usage.limit == 0 ? 1 : usage.used / usage.limit,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Đã dùng ${usage.used}/${usage.limit} lượt.'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              usage.remaining <= 0
                  ? 'Bạn đã hết lượt AI scan miễn phí tháng này.'
                  : usage.remaining <= 1
                      ? 'Bạn sắp hết lượt AI scan miễn phí.'
                      : 'Bạn còn ${usage.remaining} lượt AI scan miễn phí.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: usage.remaining <= 0
                        ? colorScheme.error
                        : colorScheme.onSurface,
                    fontWeight:
                        usage.remaining <= 1 ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đang có trong MVP',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BenefitRow(
            icon: isPremium ? Icons.check_circle : Icons.lock_outline,
            iconColor: isPremium ? colorScheme.primary : colorScheme.onSurface,
            text: 'AI scan không giới hạn cho tài khoản Premium',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sắp có (roadmap)',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BenefitRow(
            icon: Icons.schedule_outlined,
            iconColor: colorScheme.onSurfaceVariant,
            text: 'Báo cáo dinh dưỡng nâng cao',
          ),
          _BenefitRow(
            icon: Icons.schedule_outlined,
            iconColor: colorScheme.onSurfaceVariant,
            text: 'Meal plans cá nhân hóa',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SNCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nâng cấp để mở khóa AI scan không giới hạn trong MVP.'),
          const SizedBox(height: AppSpacing.md),
          SNButton(label: 'Xem Premium', onPressed: onTap),
        ],
      ),
    );
  }
}
