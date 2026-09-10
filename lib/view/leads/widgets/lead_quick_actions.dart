import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view_models/controller/lead_controller.dart';
import '../lead_bulk_upload_screen.dart';
import '../lead_followups_screen.dart';

class LeadQuickActions extends StatelessWidget {
  const LeadQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button('Follow-ups', Icons.event_note_outlined, () {
          Get.find<LeadController>().getFollowUps(refresh: true);
          Get.to(() => LeadFollowUpsScreen());
        }),
        const SizedBox(width: 10),
        _button(
          'Bulk upload',
          Icons.cloud_upload_outlined,
          () => Get.to(() => LeadBulkUploadScreen()),
        ),
      ],
    );
  }

  Widget _button(String text, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
