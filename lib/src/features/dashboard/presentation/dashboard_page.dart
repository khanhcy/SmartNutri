import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/auth_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartNutri Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Dang xuat',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chao, ${user.email}'),
            const SizedBox(height: 8),
            const Text('MVP Core da san sang cho daily nutrition tracking.'),
          ],
        ),
      ),
    );
  }
}
