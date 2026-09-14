import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view_models/controller/lead_controller.dart';

class LeadStatsCards extends StatelessWidget {
  LeadStatsCards({super.key});

  final LeadController leadController = Get.find<LeadController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = leadController.leadStats.value;
      final cards = [
        ['Total Leads', '${stats?.total ?? 0}'],
        ['New Leads', '${stats?.newLeads ?? 0}'],
        ['Active Leads', '${stats?.active ?? 0}'],
        ['Follow-ups Today', '${stats?.followUpsToday ?? 0}'],
        ['Overdue', '${stats?.overdueFollowUps ?? 0}'],
        ['Converted', '${stats?.converted ?? 0}'],
        ['Lost', '${stats?.lost ?? 0}'],
        ['Conversion Rate', '${stats?.conversionRate ?? 0}%'],
      ];

      return SizedBox(
        height: 85,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, index) =>
              _StatCard(label: cards[index][0], value: cards[index][1]),
        ),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A4F),
            ),
          ),
        ],
      ),
    );
  }
}
