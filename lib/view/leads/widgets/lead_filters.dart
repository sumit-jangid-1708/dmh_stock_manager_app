import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../model/lead_models/leads_options_model.dart';
import '../../../res/components/widgets/custom_searchable_dropdown.dart';
import '../../../view_models/controller/lead_controller.dart';

class LeadFilters extends StatelessWidget {
  LeadFilters({super.key});

  final LeadController leadController = Get.find<LeadController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LeadTabs(),
        const SizedBox(height: 16),
        TextField(
          controller: leadController.searchController,
          decoration: _inputDecoration(
            'Search customer, phone, city or product',
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final options = leadController.leadOptions.value;
          return Wrap(
            spacing: 10,
            runSpacing: 12,
            children: [
              _dropdown<LeadOption>(
                'All statuses',
                options?.statuses ?? [],
                leadController.leadStatusFilter,
                (item) => item.label,
              ),
              _dropdown<LeadOption>(
                'All priorities',
                options?.priorities ?? [],
                leadController.leadPriorityFilter,
                (item) => item.label,
              ),
              _dropdown<LeadOption>(
                'All sources',
                options?.sources ?? [],
                leadController.leadSourceFilter,
                (item) => item.label,
              ),
              _dropdown<Employee>(
                'All employees',
                options?.employees ?? [],
                leadController.leadEmployeeFilter,
                (item) => item.name,
              ),
              _dropdown<LeadOption>(
                'Sort by',
                leadController.sortOptions,
                leadController.leadSortFilter,
                (item) => item.label,
              ),
              _DateFilter(date: leadController.startDate),
              _DateFilter(date: leadController.endDate),
            ],
          );
        }),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => leadController.loadLeads(refresh: true),
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: leadController.clearFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown<T>(
    String hint,
    List<T> items,
    Rxn<T> selected,
    String Function(T) label,
  ) {
    return SizedBox(
      width: (Get.width - 40) / 2,
      child: CustomSearchableDropdown<T>(
        items: items,
        selectedItem: selected,
        itemAsString: label,
        hintText: hint,
        onChanged: (value) => selected.value = value,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}

class _LeadTabs extends StatelessWidget {
  final LeadController leadController = Get.find<LeadController>();

  _LeadTabs();

  @override
  Widget build(BuildContext context) {
    const tabs = {
      'all': 'All Leads',
      'active': 'Active Leads',
      'converted': 'Converted Leads',
      'lost': 'Lost Leads',
    };

    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.entries.map((tab) {
            final selected = leadController.selectedView.value == tab.key;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tab.value),
                selected: selected,
                onSelected: (_) {
                  leadController.selectedView.value = tab.key;
                  leadController.loadLeads(refresh: true);
                },
                selectedColor: const Color(0xFF1A1A4F),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DateFilter extends StatelessWidget {
  final Rxn<DateTime> date;

  const _DateFilter({required this.date});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date.value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) date.value = picked;
        },
        child: Container(
          width: (Get.width - 40) / 2,
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
                      ? 'mm/dd/yyyy'
                      : DateFormat('MM/dd/yyyy').format(date.value!),
                  style: TextStyle(
                    fontSize: 13,
                    color: date.value == null ? Colors.grey : Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.calendar_today_outlined, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
