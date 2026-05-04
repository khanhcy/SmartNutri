import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';

/// Wraps any widget tree with an animated offline banner at the top.
///
/// Uses [StreamSubscription] in [initState] / [dispose] — no rebuild side-effects
/// from [addPostFrameCallback] inside [build].
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final StreamSubscription<bool> _sub;

  // Start optimistic (online) — banner won't flash on startup
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _sub = context.read<ConnectivityService>().isOnlineStream.listen(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _sub.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onConnectivityChanged(bool isOnline) {
    if (isOnline == _isOnline) return;
    setState(() => _isOnline = isOnline);
    if (isOnline) {
      // Show "connected" briefly then hide
      _controller.forward().then((_) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) _controller.reverse();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _slide,
          axisAlignment: -1,
          child: _OfflineBannerContent(isOnline: _isOnline),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _OfflineBannerContent extends StatelessWidget {
  const _OfflineBannerContent({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOnline ? Colors.green.shade600 : Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline ? 'Đã kết nối trở lại' : 'Không có kết nối mạng',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
