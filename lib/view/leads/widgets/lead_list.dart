import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/lead_models/lead_model.dart';
import '../../../view_models/controller/auth/auth_controller.dart';
import '../../../view_models/controller/lead_controller.dart';
import '../lead_detail_screen.dart';

class LeadList extends StatelessWidget {
  LeadList({super.key});

  final LeadController leadController = Get.find<LeadController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (leadController.leads.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 70),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.black26),
              SizedBox(height: 12),
              Text('No leads found', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${leadController.totalCount.value} leads',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A4F),
            ),
          ),
          const SizedBox(height: 12),
          ...leadController.leads.map((lead) => _LeadCard(lead: lead)),
          if (leadController.totalPages.value > 1) _Pagination(),
        ],
      );
    });
  }
}

class _LeadCard extends StatelessWidget {
  final LeadModel lead;
  final LeadController leadController = Get.find<LeadController>();
  final AuthController authController = Get.find<AuthController>();

  _LeadCard({required this.lead});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(lead.status);
    final name = lead.fullName.isEmpty ? lead.shippingName : lead.fullName;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 11),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          leadController.loadLead(lead.id);
          Get.to(() => LeadDetailScreen(leadId: lead.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(.12),
                child: Text(
                  (name.isEmpty ? '?' : name[0]).toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lead.countryCode} ${lead.phone}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lead.statusDisplay.isEmpty
                          ? lead.status
                          : lead.statusDisplay,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lead.leadId,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      if (authController.canAction('leads', 'delete'))
                        IconButton(
                          onPressed: () => _confirmDelete(context),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 19,
                            color: Colors.red,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.only(left: 6),
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Lead?'),
        content: Text('${lead.fullName} will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await leadController.deleteLead(lead.id);
    }
  }

  Color _statusColor(String status) {
    if (status == 'converted') return Colors.green;
    if (status == 'lost' || status == 'not_interested') return Colors.red;
    if (status == 'new') return Colors.blue;
    return Colors.orange;
  }
}

class _Pagination extends StatelessWidget {
  final LeadController leadController = Get.find<LeadController>();

  _Pagination();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: leadController.currentPage.value > 1
                  ? () => leadController.changePage(
                      leadController.currentPage.value - 1,
                    )
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              '${leadController.currentPage.value} / ${leadController.totalPages.value}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed:
                  leadController.currentPage.value <
                      leadController.totalPages.value
                  ? () => leadController.changePage(
                      leadController.currentPage.value + 1,
                    )
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
