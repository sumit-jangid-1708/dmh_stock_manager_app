import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../view_models/controller/auth/auth_controller.dart';
import '../../view_models/controller/lead_controller.dart';
import 'lead_form_screen.dart';
import 'widgets/lead_filters.dart';
import 'widgets/lead_list.dart';
import 'widgets/lead_quick_actions.dart';
import 'widgets/lead_stats_cards.dart';

class LeadScreen extends StatelessWidget {
  LeadScreen({super.key});

  final LeadController leadController = Get.find<LeadController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Lead Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: leadController.loadInitial, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      floatingActionButton: _addLeadButton(),
      body: Obx(() {
        if (leadController.isLoading.value && leadController.leadStats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: leadController.loadInitial,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 90),
            children: [
              const LeadQuickActions(),
              const SizedBox(height: 16),
              LeadStatsCards(),
              const SizedBox(height: 20),
              LeadFilters(),
              const SizedBox(height: 20),
              LeadList(),
            ],
          ),
        );
      }),
    );
  }

  Widget? _addLeadButton() {
    if (!authController.canAction('leads', 'add')) return null;
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF1A1A4F),
      foregroundColor: Colors.white,
      onPressed: () {
        leadController.clearForm();
        Get.to(() => LeadFormScreen());
      },
      icon: const Icon(Icons.add),
      label: const Text('ADD LEAD'),
    );
  }
}
