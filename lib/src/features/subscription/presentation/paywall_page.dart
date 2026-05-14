import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartnutri/src/app/go_router_config.dart';
import 'package:smartnutri/src/core/ui/components/screen_section.dart';
import 'package:smartnutri/src/core/ui/components/sn_button.dart';
import 'package:smartnutri/src/core/ui/components/sn_card.dart';
import 'package:smartnutri/src/core/ui/layout/page_template.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({
    super.key,
    this.source,
    this.reason,
  });

  final String? source;
  final String? reason;

  bool get _isQuotaBlocked => reason == 'quota_exhausted';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PageTemplate(
      title: 'Nâng cấp Premium',
      subtitle: 'Mở khóa AI scan không giới hạn và các quyền lợi nâng cao.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isQuotaBlocked)
            SNCard(
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.error),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Bạn đã dùng hết lượt AI scan miễn phí tháng này.',
                    ),
                  ),
                ],
              ),
            ),
          ScreenSection(
            title: 'Quyền lợi đang có trong MVP',
            topSpacing: _isQuotaBlocked ? AppSpacing.md : 0,
            child: SNCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'SmartNutri Premium',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _Benefit(
                    icon: Icons.check_circle_outline,
                    text: 'AI scan không giới hạn trong bản MVP',
                  ),
                ],
              ),
            ),
          ),
          ScreenSection(
            title: 'Sắp có (roadmap)',
            child: const SNCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Benefit(
                    icon: Icons.schedule_outlined,
                    text: 'Báo cáo dinh dưỡng nâng cao',
                  ),
                  _Benefit(
                    icon: Icons.schedule_outlined,
                    text: 'Meal plans cá nhân hóa',
                  ),
                ],
              ),
            ),
          ),
          ScreenSection(
            title: 'Bước tiếp theo',
            child: SNCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nextStepText()),
                  const SizedBox(height: AppSpacing.md),
                  if (_isQuotaBlocked && source == 'scan_photo') ...[
                    SNButton(
                      label: 'Xem trang gói',
                      variant: SNButtonVariant.secondary,
                      onPressed: () => context.go(AppPaths.subscription),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  SNButton(
                    label: 'Quay lại',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _nextStepText() {
    if (source == 'scan_photo' && _isQuotaBlocked) {
      return 'Trong bản MVP hiện tại, tài khoản Premium được cấp quyền qua admin để demo. Bạn có thể quay lại và thử lại khi có lượt mới hoặc khi tài khoản được mở Premium.';
    }
    return 'Bản MVP hiện tại dùng cấp quyền Premium qua admin để demo. Tích hợp thanh toán thật sẽ được bổ sung ở giai đoạn sau.';
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
