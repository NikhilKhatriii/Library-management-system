import 'package:flutter/material.dart';
import '../../../auth/domain/models/user_role.dart';
import '../widgets/dashboard_body.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const DashboardBody(role: UserRole.teacher),
    );
  }
}
