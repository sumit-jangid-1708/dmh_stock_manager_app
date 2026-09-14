import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/lead_models/lead_detail_model.dart';
import '../../model/lead_models/lead_activity_model.dart';
import '../../model/lead_models/lead_follow_up_model.dart';
import '../../model/lead_models/lead_note_model.dart';
import '../../model/lead_models/lead_status_history_model.dart';
import '../../model/lead_models/leads_options_model.dart';
import '../../view_models/controller/lead_controller.dart';
import '../../view_models/controller/auth/auth_controller.dart';
import 'lead_form_screen.dart';

class LeadDetailScreen extends GetView<LeadController> {
  const LeadDetailScreen({super.key, required this.leadId});
  final int leadId;
  AuthController get authController => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF7F8FC),
    appBar: AppBar(
      title: const Text('Lead Details'),
      backgroundColor: const Color(0xFF1A1A4F),
      foregroundColor: Colors.white,
      actions: [
        if (authController.canAction('leads', 'edit'))
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              final lead = controller.leadDetail.value;
              if (lead == null) return;
              controller.prepareEdit(lead);
              Get.to(() => LeadFormScreen());
            },
          ),
        if (authController.canAction('leads', 'edit') ||
            authController.canAction('leads', 'delete'))
          PopupMenuButton<String>(
            onSelected: (v) => _menuAction(context, v),
            itemBuilder: (_) => [
              if (authController.canAction('leads', 'edit'))
                const PopupMenuItem(
                  value: 'convert',
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    title: Text('Convert Lead'),
                  ),
                ),
              if (authController.canAction('leads', 'edit'))
                const PopupMenuItem(
                  value: 'lost',
                  child: ListTile(
                    leading: Icon(Icons.cancel_outlined, color: Colors.orange),
                    title: Text('Mark Lost'),
                  ),
                ),
              if (authController.canAction('leads', 'delete'))
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Delete Lead'),
                  ),
                ),
            ],
          ),
      ],
    ),
    body: Obx(() {
        if (controller.isDetailLoading.value ||
            controller.leadDetail.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A1A4F)),
          );
        }
        final lead = controller.leadDetail.value!;
        return RefreshIndicator(
          onRefresh: () => controller.loadLead(leadId),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _header(lead),
              const SizedBox(height: 14),
              if (authController.canAction('leads', 'edit'))
                Row(
                  children: [
                    Expanded(
                      child: _action(
                        'STATUS',
                        Icons.swap_horiz_rounded,
                        Colors.blue,
                        () => _statusDialog(context, lead),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _action(
                        'NOTE',
                        Icons.note_add_outlined,
                        Colors.indigo,
                        () => _noteDialog(context, lead),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _action(
                        'FOLLOW-UP',
                        Icons.event_available_outlined,
                        Colors.orange,
                        () => _followUpDialog(context, lead),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 14),
              _section('Contact & Shipping', [
                _row(Icons.phone_outlined, '${lead.countryCode} ${lead.phone}'),
                if (lead.shippingPhone.isNotEmpty)
                  _row(Icons.phone_android_outlined, lead.shippingPhone),
                if (lead.whatsappNumber.isNotEmpty)
                  _row(Icons.chat_outlined, lead.whatsappNumber),
                if (lead.email.isNotEmpty)
                  _row(Icons.email_outlined, lead.email),
                if (lead.companyName.isNotEmpty)
                  _row(Icons.business_outlined, lead.companyName),
                if (lead.designation.isNotEmpty)
                  _row(Icons.work_outline, lead.designation),
                if ([
                  lead.shippingAddress1,
                  lead.shippingAddress2,
                  lead.shippingCity,
                  lead.shippingProvinceName,
                  lead.shippingZip,
                  lead.shippingCountry,
                ].any((e) => e.isNotEmpty))
                  _row(
                    Icons.location_on_outlined,
                    [
                      lead.shippingAddress1,
                      lead.shippingAddress2,
                      lead.shippingCity,
                      lead.shippingProvinceName,
                      lead.shippingZip,
                      lead.shippingCountry,
                    ].where((e) => e.isNotEmpty).join(', '),
                  ),
                if ((lead.assignedToName ?? '').isNotEmpty)
                  _row(
                    Icons.badge_outlined,
                    'Assigned to ${lead.assignedToName!}',
                  ),
              ]),
              _section('Lead Information', [
                if (lead.sourceDisplay.isNotEmpty)
                  _row(Icons.campaign_outlined, lead.sourceDisplay),
                if (lead.priorityDisplay.isNotEmpty)
                  _row(Icons.flag_outlined, lead.priorityDisplay),
                if (lead.nextFollowUp != null)
                  _row(Icons.event_outlined, lead.nextFollowUp!),
                if (lead.notes.isNotEmpty)
                  _row(Icons.notes_outlined, lead.notes),
                if (lead.lostReasonDisplay.isNotEmpty)
                  _row(Icons.cancel_outlined, lead.lostReasonDisplay),
              ]),
              if (lead.products.isNotEmpty)
                _section(
                  'Interested Products',
                  lead.products
                      .map(
                        (p) =>
                            _row(Icons.inventory_2_outlined, _productText(p)),
                      )
                      .toList(),
                ),
              if (controller.leadFollowUps.isNotEmpty)
                _section(
                  'Follow-ups',
                  controller.leadFollowUps
                      .map(
                        (e) =>
                            _timeline(e, Icons.event_outlined, Colors.orange),
                      )
                      .toList(),
                ),
              if (controller.leadNotes.isNotEmpty)
                _section(
                  'Notes',
                  controller.leadNotes
                      .map(
                        (e) => _timeline(
                          e,
                          Icons.sticky_note_2_outlined,
                          Colors.indigo,
                        ),
                      )
                      .toList(),
                ),
              if (controller.leadStatusHistory.isNotEmpty)
                _section(
                  'Status History',
                  controller.leadStatusHistory
                      .map(
                        (e) => _timeline(
                          e,
                          Icons.swap_horiz_rounded,
                          Colors.purple,
                        ),
                      )
                      .toList(),
                ),
              if (controller.leadActivities.isNotEmpty)
                _section(
                  'Activity Timeline',
                  controller.leadActivities
                      .map(
                        (e) => _timeline(
                          e,
                          Icons.history_rounded,
                          Colors.blueGrey,
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
  );

  Widget _header(LeadDetailModel lead) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: Colors.white24,
          child: Text(
            (lead.fullName.isEmpty ? '?' : lead.fullName[0]).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.fullName.isEmpty ? lead.shippingName : lead.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 4),
              Text(lead.leadId, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 7),
              Text(
                lead.statusDisplay.isEmpty ? lead.status : lead.statusDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (lead.priorityDisplay.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              lead.priorityDisplay,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
      ],
    ),
  );

  Widget _action(String text, IconData icon, Color color, VoidCallback tap) =>
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 5),
            child: Column(
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  Widget _section(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            letterSpacing: .8,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A4F),
          ),
        ),
        const Divider(height: 24),
        ...children,
      ],
    ),
  );
  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.indigo.shade300),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, height: 1.35),
          ),
        ),
      ],
    ),
  );
  Widget _timeline(dynamic e, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(.1),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _timelineTitle(e),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (_timelineDescription(e).isNotEmpty)
                Text(
                  _timelineDescription(e),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              if (_timelineDate(e).isNotEmpty)
                Text(
                  _timelineDate(e),
                  style: const TextStyle(fontSize: 11, color: Colors.orange),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  String _productText(dynamic product) {
    if (product is! Map) return product.toString();
    final name = (product['name'] ?? product['product_name'] ?? '').toString();
    final sku = (product['sku'] ?? '').toString();
    return sku.isEmpty ? name : '$name • $sku';
  }

  String _timelineTitle(dynamic item) {
    if (item is LeadActivityModel) return item.title;
    if (item is LeadFollowUpModel) {
      return item.followUpType.isEmpty ? 'Follow-up' : item.followUpType;
    }
    if (item is LeadNoteModel) return item.note;
    if (item is LeadStatusHistoryModel) {
      return '${item.oldStatusDisplay} → ${item.newStatusDisplay}';
    }
    if (item is Map) {
      return (item['title'] ??
              item['notes'] ??
              item['note'] ??
              item['follow_up_type'] ??
              'Update')
          .toString();
    }
    return 'Update';
  }

  String _timelineDescription(dynamic item) {
    if (item is LeadActivityModel) return item.description;
    if (item is LeadFollowUpModel) return item.notes;
    if (item is LeadNoteModel) return item.createdByName;
    if (item is LeadStatusHistoryModel) return item.reason;
    if (item is Map) return item['description']?.toString() ?? '';
    return '';
  }

  String _timelineDate(dynamic item) {
    if (item is LeadActivityModel) return item.createdAt;
    if (item is LeadFollowUpModel) {
      return '${item.followUpDate} ${item.followUpTime}';
    }
    if (item is LeadNoteModel) return item.createdAt;
    if (item is LeadStatusHistoryModel) return item.createdAt;
    if (item is Map && item['follow_up_date'] != null) {
      return '${item['follow_up_date']} ${item['follow_up_time'] ?? ''}';
    }
    return '';
  }

  Future<void> _statusDialog(BuildContext context, LeadDetailModel lead) async {
    LeadOption? selected = controller.leadOptions.value?.statuses
        .firstWhereOrNull((e) => e.value == lead.status);
    String reason = '';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<LeadOption>(
              initialValue: selected,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: (controller.leadOptions.value?.statuses ?? [])
                  .where((e) => e.value != 'converted' && e.value != 'lost')
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => selected = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => reason = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (selected == null) return;
              if (await controller.changeStatus(
                    lead.id,
                    selected!.value,
                    reason,
                  ) &&
                  ctx.mounted)
                Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _noteDialog(BuildContext context, LeadDetailModel lead) async {
    String note = '';
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Note'),
        content: TextFormField(
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a note...',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => note = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (note.trim().isNotEmpty &&
                  await controller.addNote(lead.id, note.trim()) &&
                  ctx.mounted)
                Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _followUpDialog(
    BuildContext context,
    LeadDetailModel lead,
  ) async {
    String date = '', time = '', notes = '';
    LeadOption? type;
    Employee? employee;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Schedule Follow-up'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (v) => date = v,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Time (HH:mm)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (v) => time = v,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<LeadOption>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: (controller.leadOptions.value?.followUpTypes ?? [])
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                    )
                    .toList(),
                onChanged: (v) => type = v,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Employee>(
                initialValue: employee,
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  border: OutlineInputBorder(),
                ),
                items: (controller.leadOptions.value?.employees ?? [])
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (v) => employee = v,
              ),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => notes = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (date.isEmpty || type == null) return;
              final ok = await controller.addFollowUp(lead.id, {
                'follow_up_date': date,
                'follow_up_time': time,
                'follow_up_type': type!.value,
                'notes': notes,
                if (employee != null) 'assigned_to': employee!.id,
              });
              if (ok && ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Future<void> _menuAction(BuildContext context, String value) async {
    final lead = controller.leadDetail.value;
    if (lead == null) return;
    if (value == 'delete') {
      final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Lead?'),
          content: Text('${lead.fullName} will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (yes == true && await controller.deleteLead(lead.id)) Get.back();
    } else if (value == 'lost') {
      LeadOption? reason;
      String notes = '';
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark Lead Lost'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LeadOption>(
                initialValue: reason,
                decoration: const InputDecoration(
                  labelText: 'Lost reason',
                  border: OutlineInputBorder(),
                ),
                items: (controller.leadOptions.value?.lostReasons ?? [])
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                    )
                    .toList(),
                onChanged: (v) => reason = v,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => notes = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (reason == null) return;
                if (await controller.markLost(lead.id, reason!.value, notes) &&
                    ctx.mounted)
                  Navigator.pop(ctx);
              },
              child: const Text('Mark Lost'),
            ),
          ],
        ),
      );
    } else if (value == 'convert') {
      String date = DateTime.now().toIso8601String().substring(0, 10),
          product = '',
          amount = '',
          notes = '';
      LeadOption? payment;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Convert Lead'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: date,
                  decoration: const InputDecoration(
                    labelText: 'Conversion date',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => date = v,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Product / Service',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => product = v,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Deal amount',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => amount = v,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<LeadOption>(
                  initialValue: payment,
                  decoration: const InputDecoration(
                    labelText: 'Payment status',
                    border: OutlineInputBorder(),
                  ),
                  items: (controller.leadOptions.value?.paymentStatuses ?? [])
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                      )
                      .toList(),
                  onChanged: (v) => payment = v,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => notes = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (payment == null) return;
                final ok = await controller.convertLead(lead.id, {
                  'conversion_date': date,
                  'product_service': product,
                  'deal_amount': amount,
                  'payment_status': payment!.value,
                  'notes': notes,
                });
                if (ok && ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Convert'),
            ),
          ],
        ),
      );
    }
  }
}
