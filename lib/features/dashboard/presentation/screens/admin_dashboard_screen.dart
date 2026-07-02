import 'package:flutter/material.dart';
import '../../../auth/domain/models/user_role.dart';
import '../widgets/dashboard_body.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const DashboardBody(role: UserRole.admin, showCharts: true),
    );
  }
}
