// lib/view/widgets/company_details_form_sheet.dart

import 'package:flutter/material.dart';
import '../../../model/bills_model/company_details_model.dart';

/// A reusable modal bottom sheet that collects company details
/// before PDF generation. Does NOT persist data globally.
///
/// Usage:
/// ```dart
/// final details = await CompanyDetailsFormSheet.show(
///   context,
///   prefill: _lastUsedDetails, // optional — pre-fill from session cache
/// );
/// if (details != null) { /* generate PDF */ }
/// ```
class CompanyDetailsFormSheet extends StatefulWidget {
  /// Optional pre-fill values (e.g., from a session-level cache).
  final CompanyDetails? prefill;

  const CompanyDetailsFormSheet({super.key, this.prefill});

  /// Static helper to show the sheet and await the result.
  /// Returns [CompanyDetails] on submit, or `null` if dismissed.
  static Future<CompanyDetails?> show(
      BuildContext context, {
        CompanyDetails? prefill,
      }) {
    return showModalBottomSheet<CompanyDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CompanyDetailsFormSheet(prefill: prefill),
    );
  }

  @override
  State<CompanyDetailsFormSheet> createState() =>
      _CompanyDetailsFormSheetState();
}

class _CompanyDetailsFormSheetState extends State<CompanyDetailsFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.prefill?.name ?? '');
    _gstCtrl = TextEditingController(text: widget.prefill?.gst ?? '');
    _addressCtrl = TextEditingController(text: widget.prefill?.address ?? '');
    _phoneCtrl = TextEditingController(text: widget.prefill?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── Validation helpers ──────────────────────────────────────────────────

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// GST is optional — returns null (no error) when the field is empty.
  /// If a value IS entered it must match the standard 15-char format.
  String? _gstValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional field
    final cleaned = value.trim();
    final gstRegex = RegExp(r'^[0-9A-Z]{15}$');
    if (!gstRegex.hasMatch(cleaned)) {
      return 'Enter a valid 15-digit GST number';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Contact number is required';
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  // ── Submit ───────────────────────────────────────────────────────────────

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final details = CompanyDetails(
      name: _nameCtrl.text.trim(),
      // Store null when the field is left blank — model field is nullable.
      gst: _gstCtrl.text.trim().isEmpty
          ? null
          : _gstCtrl.text.trim().toUpperCase(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );

    // Pop with the result so the caller can act on it.
    Navigator.of(context).pop(details);
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // 85 % height gives room for keyboard.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ───────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
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
                        'These will appear on the invoice header',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const Divider(height: 24),

          // ── Form ─────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _FormField(
                      label: 'Company Name',
                      controller: _nameCtrl,
                      icon: Icons.business_rounded,
                      hint: 'e.g. Sharma Traders Pvt. Ltd.',
                      validator: (v) =>
                          _requiredValidator(v, 'Company name'),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'GST Number (Optional)',
                      controller: _gstCtrl,
                      icon: Icons.receipt_long_rounded,
                      hint: 'e.g. 27AAPFU0939F1ZV',
                      caps: TextCapitalization.characters,
                      validator: _gstValidator,
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Business Address',
                      controller: _addressCtrl,
                      icon: Icons.location_on_rounded,
                      hint: 'Street, City, State, PIN',
                      maxLines: 3,
                      validator: (v) =>
                          _requiredValidator(v, 'Address'),
                    ),
                    const SizedBox(height: 16),
                    _FormField(
                      label: 'Contact Number',
                      controller: _phoneCtrl,
                      icon: Icons.phone_rounded,
                      hint: 'e.g. +91 98765 43210',
                      keyboardType: TextInputType.phone,
                      validator: _phoneValidator,
                    ),
                    const SizedBox(height: 28),

                    // ── Submit button ──────────────────────────────────
                    _SubmitButton(
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;
  final TextCapitalization caps;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.caps = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: caps,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A4F),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A4ABF), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A4F).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Generate PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}