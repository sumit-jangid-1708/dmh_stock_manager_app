import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../model/lead_models/lead_follow_up_model.dart';
import '../../model/lead_models/lead_model.dart';
import '../../model/lead_models/leads_options_model.dart';
import '../../res/components/widgets/custom_searchable_dropdown.dart';
import '../../view_models/controller/lead_controller.dart';
import '../../view_models/controller/auth/auth_controller.dart';

class LeadFollowUpsScreen extends StatelessWidget {
  LeadFollowUpsScreen({super.key});

  final LeadController leadController = Get.find<LeadController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text('Lead Follow-ups'),
        backgroundColor: const Color(0xFF1A1A4F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => leadController.getFollowUps(refresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: () => leadController.getFollowUps(refresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTabs(),
              const SizedBox(height: 14),
              _filters(context),
              const SizedBox(height: 16),
              _followUpList(context),
            ],
          ),
        ),
    );
  }

  Widget _sectionTabs() {
    const sections = {
      'overdue': 'Overdue',
      'today': 'Today',
      'upcoming': 'Upcoming',
      'completed': 'Completed',
    };
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sections.entries.map((section) {
            final selected =
                leadController.followUpSection.value == section.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(section.value),
                selected: selected,
                showCheckmark: false,
                selectedColor: const Color(0xFF1A1A4F),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
                onSelected: (_) {
                  leadController.followUpSection.value = section.key;
                  leadController.getFollowUps(refresh: true);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _dropdown<LeadOption>(
            'All statuses',
            leadController.leadOptions.value?.followUpStatuses ?? [],
            leadController.followUpStatusFilter,
            (item) => item.label,
          ),
          _dropdown<Employee>(
            'All employees',
            leadController.leadOptions.value?.employees ?? [],
            leadController.followUpEmployeeFilter,
            (item) => item.name,
          ),
          _dropdown<LeadModel>(
            'All leads',
            leadController.leads,
            leadController.followUpLeadFilter,
            (item) => item.fullName.isEmpty ? item.shippingName : item.fullName,
          ),
          _dateFilter(context, leadController.followUpStartDate, 'From date'),
          _dateFilter(context, leadController.followUpEndDate, 'To date'),
          ElevatedButton.icon(
            onPressed: () => leadController.getFollowUps(refresh: true),
            icon: const Icon(Icons.filter_alt_outlined),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A4F),
              foregroundColor: Colors.white,
            ),
          ),
          OutlinedButton(
            onPressed: leadController.clearFollowUpFilters,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>(
    String hint,
    List<T> items,
    Rxn<T> selected,
    String Function(T) label,
  ) {
    return SizedBox(
      width: (Get.width - 42) / 2,
      child: CustomSearchableDropdown<T>(
        items: items,
        selectedItem: selected,
        itemAsString: label,
        hintText: hint,
        onChanged: (value) => selected.value = value,
      ),
    );
  }

  Widget _dateFilter(BuildContext context, Rxn<DateTime> date, String hint) {
    return Obx(
      () => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date.value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) date.value = picked;
        },
        child: Container(
          width: (Get.width - 42) / 2,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  date.value == null
                      ? hint
                      : DateFormat('dd MMM yyyy').format(date.value!),
                ),
              ),
              const Icon(Icons.calendar_today_outlined, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _followUpList(BuildContext context) {
    return Obx(() {
      if (leadController.isFollowUpLoading.value &&
          leadController.followUps.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 70),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (leadController.followUps.isEmpty) {
        return const Padding(
          padding: EdgeInsets.only(top: 70),
          child: Center(child: Text('No follow-ups found')),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${leadController.followUpCount.value} follow-ups',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...leadController.followUps.map(
            (followUp) => _followUpCard(context, followUp),
          ),
          if (leadController.followUpPages.value > 1) _pagination(),
        ],
      );
    });
  }

  Widget _followUpCard(BuildContext context, LeadFollowUpModel followUp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.event_outlined)),
        title: Text(
          followUp.leadName.isEmpty ? followUp.leadCode : followUp.leadName,
        ),
        subtitle: Text(
          '${followUp.followUpDate}  ${followUp.followUpTime}\n'
          '${followUp.followUpTypeDisplay.isEmpty ? followUp.followUpType : followUp.followUpTypeDisplay}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authController.canAction('leads', 'delete'))
              IconButton(
                onPressed: () => _confirmFollowUpDelete(context, followUp),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () async {
          if (await leadController.getFollowUpDetail(followUp.id) &&
              context.mounted) {
            _showFollowUpDetail(context);
          }
        },
      ),
    );
  }

  Future<void> _confirmFollowUpDelete(
    BuildContext context,
    LeadFollowUpModel followUp,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Follow-up?'),
        content: const Text('This follow-up will be deleted permanently.'),
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
      await leadController.deleteFollowUp(followUp.id);
    }
  }

  void _showFollowUpDetail(BuildContext context) {
    final followUp = leadController.selectedFollowUp.value;
    if (followUp == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              followUp.leadName.isEmpty ? followUp.leadCode : followUp.leadName,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Date: ${followUp.followUpDate} ${followUp.followUpTime}'),
            Text('Type: ${followUp.followUpTypeDisplay}'),
            Text('Status: ${followUp.statusDisplay}'),
            Text('Assigned to: ${followUp.assignedToName}'),
            if (followUp.notes.isNotEmpty) Text('Notes: ${followUp.notes}'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  _editDialog(context, followUp);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('EDIT FOLLOW-UP'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDialog(
    BuildContext context,
    LeadFollowUpModel followUp,
  ) async {
    String date = followUp.followUpDate;
    String time = followUp.followUpTime;
    String notes = followUp.notes;
    LeadOption? type = leadController.leadOptions.value?.followUpTypes
        .firstWhereOrNull((item) => item.value == followUp.followUpType);
    LeadOption? status = leadController.leadOptions.value?.followUpStatuses
        .firstWhereOrNull((item) => item.value == followUp.status);
    Employee? employee = leadController.leadOptions.value?.employees
        .firstWhereOrNull((item) => item.id == followUp.assignedTo);

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Follow-up'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: date,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                ),
                onChanged: (value) => date = value,
              ),
              TextFormField(
                initialValue: time,
                decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
                onChanged: (value) => time = value,
              ),
              DropdownButtonFormField<LeadOption>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: (leadController.leadOptions.value?.followUpTypes ?? [])
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => type = value,
              ),
              DropdownButtonFormField<LeadOption>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items:
                    (leadController.leadOptions.value?.followUpStatuses ?? [])
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) => status = value,
              ),
              DropdownButtonFormField<Employee>(
                initialValue: employee,
                decoration: const InputDecoration(labelText: 'Assigned to'),
                items: (leadController.leadOptions.value?.employees ?? [])
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item.name)),
                    )
                    .toList(),
                onChanged: (value) => employee = value,
              ),
              TextFormField(
                initialValue: notes,
                decoration: const InputDecoration(labelText: 'Notes'),
                onChanged: (value) => notes = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (type == null || status == null || employee == null) return;
              final updated = await leadController.updateFollowUp(followUp.id, {
                'follow_up_date': date,
                'follow_up_time': time,
                'follow_up_type': type!.value,
                'status': status!.value,
                'notes': notes,
                'assigned_to': employee!.id,
              });
              if (updated && dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _pagination() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: leadController.followUpPage.value > 1
                ? () => leadController.changeFollowUpPage(
                    leadController.followUpPage.value - 1,
                  )
                : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            '${leadController.followUpPage.value} / '
            '${leadController.followUpPages.value}',
          ),
          IconButton(
            onPressed:
                leadController.followUpPage.value <
                    leadController.followUpPages.value
                ? () => leadController.changeFollowUpPage(
                    leadController.followUpPage.value + 1,
                  )
                : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
