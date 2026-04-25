// lib/view/widgets/company_details_form_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/bills_model/company_details_model.dart';
import '../../../view_models/controller/billing_controller.dart';
import 'app_gradient _button.dart';
import 'custom_searchable_dropdown.dart';
import 'custom_text_field.dart';

/// Bottom sheet that collects company details via four dropdown + add-button rows.
///
/// All list state lives in [BillingController]. This widget is purely UI.
///
/// Usage:
/// ```dart
/// final details = await CompanyDetailsFormSheet.show(context, bill: bill, action: 'share');
/// ```
class CompanyDetailsFormSheet extends StatelessWidget {
  const CompanyDetailsFormSheet({super.key});

  /// Opens the sheet.
  /// Returns [CompanyDetails] on submit or `null` if dismissed.
  static Future<CompanyDetails?> show(BuildContext context) {
    return showModalBottomSheet<CompanyDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CompanyDetailsFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BillingController>();
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.business_center_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                      Text(
                        'Select or add values for each field',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    controller.resetCompanySelections();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // ── Form rows ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
              child: Column(
                children: [
                  // Company Name
                  _DropdownRow(
                    label: 'Company Name',
                    icon: Icons.business_rounded,
                    items: controller.companyNames,
                    selectedItem: controller.selectedName,
                    hintText: 'Select company name',
                    addDialogTitle: 'Add Company Name',
                    addDialogHint: 'e.g. Sharma Traders Pvt. Ltd.',
                    addDialogIcon: Icons.business_rounded,
                    onAdd: controller.addCompanyName,
                  ),
                  const SizedBox(height: 16),

                  // GST Number (optional)
                  _DropdownRow(
                    label: 'GST Number (Optional)',
                    icon: Icons.receipt_long_rounded,
                    items: controller.gstNumbers,
                    selectedItem: controller.selectedGst,
                    hintText: 'Select GST number',
                    addDialogTitle: 'Add GST Number',
                    addDialogHint: 'e.g. 27AAPFU0939F1ZV',
                    addDialogIcon: Icons.receipt_long_rounded,
                    addDialogCaps: TextCapitalization.characters,
                    onAdd: controller.addGstNumber,
                    isOptional: true,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  _DropdownRow(
                    label: 'Business Address',
                    icon: Icons.location_on_rounded,
                    items: controller.addresses,
                    selectedItem: controller.selectedAddress,
                    hintText: 'Select address',
                    addDialogTitle: 'Add Address',
                    addDialogHint: 'Street, City, State, PIN',
                    addDialogIcon: Icons.location_on_rounded,
                    addDialogMaxLines: 3,
                    onAdd: controller.addAddress,
                  ),
                  const SizedBox(height: 16),

                  // Contact Number
                  _DropdownRow(
                    label: 'Contact Number',
                    icon: Icons.phone_rounded,
                    items: controller.phoneNumbers,
                    selectedItem: controller.selectedPhone,
                    hintText: 'Select contact number',
                    addDialogTitle: 'Add Contact Number',
                    addDialogHint: 'e.g. +91 98765 43210',
                    addDialogIcon: Icons.phone_rounded,
                    addDialogKeyboardType: TextInputType.phone,
                    onAdd: controller.addPhoneNumber,
                  ),

                  const SizedBox(height: 32),

                  // ── Generate button ──────────────────────────────────
                  Obx(() => AppGradientButton(
                    text: 'Generate PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    isLoading: controller.isGeneratingPdf.value,
                    width: double.infinity,
                    height: 56,
                    fontSize: 16,
                    borderRadius: 16,
                    onPressed: controller.isGeneratingPdf.value
                        ? null
                        : () => _onGenerate(context, controller),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onGenerate(BuildContext context, BillingController controller) {
    final error = controller.validateCompanySelection();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final details = controller.buildCompanyDetails();
    Navigator.of(context).pop(details);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DropdownRow
// One full row: label + icon, the searchable dropdown, and the "+" button.
// ─────────────────────────────────────────────────────────────────────────────

class _DropdownRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final RxList<String> items;
  final Rx<String?> selectedItem;
  final String hintText;
  final String addDialogTitle;
  final String addDialogHint;
  final IconData addDialogIcon;
  final TextCapitalization addDialogCaps;
  final TextInputType addDialogKeyboardType;
  final int addDialogMaxLines;
  final Future<void> Function(String) onAdd;
  final bool isOptional;

  const _DropdownRow({
    required this.label,
    required this.icon,
    required this.items,
    required this.selectedItem,
    required this.hintText,
    required this.addDialogTitle,
    required this.addDialogHint,
    required this.addDialogIcon,
    required this.onAdd,
    this.addDialogCaps = TextCapitalization.none,
    this.addDialogKeyboardType = TextInputType.text,
    this.addDialogMaxLines = 1,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF1A1A4F)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A4F),
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 4),
              Text(
                '(optional)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),

        // Dropdown + Add button row
        Obx(() => Row(
          children: [
            // ── Dropdown ──────────────────────────────────────────────
            Expanded(
              child: CustomSearchableDropdown<String>(
                items: items,
                selectedItem: selectedItem,
                itemAsString: (s) => s,
                hintText: hintText,
                searchHint: 'Search…',
                enabled: items.isNotEmpty,
                onChanged: (val) => selectedItem.value = val,
              ),
            ),

            const SizedBox(width: 10),

            // ── "+" Add button ─────────────────────────────────────────
            _AddButton(
              onTap: () => _showAddDialog(context),
            ),
          ],
        )),

        // Empty state hint
        Obx(() {
          if (items.isNotEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'No items yet — tap + to add one',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddItemDialog(
        title: addDialogTitle,
        hint: addDialogHint,
        icon: addDialogIcon,
        caps: addDialogCaps,
        keyboardType: addDialogKeyboardType,
        maxLines: addDialogMaxLines,
        onSave: onAdd,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddButton  — the circular "+" button beside every dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A4F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddItemDialog
// Dialog with a single AppTextField + Save/Cancel buttons.
// Calls [onSave] with the entered string; the controller adds it to its list.
// ─────────────────────────────────────────────────────────────────────────────

class _AddItemDialog extends StatefulWidget {
  final String title;
  final String hint;
  final IconData icon;
  final TextCapitalization caps;
  final TextInputType keyboardType;
  final int maxLines;
  final Future<void> Function(String) onSave;

  const _AddItemDialog({
    required this.title,
    required this.hint,
    required this.icon,
    required this.caps,
    required this.keyboardType,
    required this.maxLines,
    required this.onSave,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String? _validator(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field cannot be empty';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dialog header ──────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Input field ────────────────────────────────────────
              AppTextField(
                controller: _ctrl,
                hintText: widget.hint,
                prefixIcon: widget.icon,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                validator: _validator,
              ),

              const SizedBox(height: 24),

              // ── Action buttons ─────────────────────────────────────
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Save
                  Expanded(
                    child: AppGradientButton(
                      text: 'Save',
                      icon: Icons.check_rounded,
                      isLoading: _saving,
                      height: 48,
                      borderRadius: 12,
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}