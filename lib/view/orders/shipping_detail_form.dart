import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../model/order_models/courier_partner_model.dart';
import '../../res/components/widgets/app_gradient _button.dart';
import '../../res/components/widgets/custom_text_field.dart';
import '../../view_models/controller/order_controller.dart';

// ─── Public entry point ───────────────────────────────────────────────────────
void showShippingDetailsBottomSheet(BuildContext context, int orderId) {
  Get.bottomSheet(
    _ShippingDetailBottomSheet(orderId: orderId),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    // ✅ keyboard ke liye zaroori
    ignoreSafeArea: false,
  );
}

class _ShippingDetailBottomSheet extends StatefulWidget {
  final int orderId;
  const _ShippingDetailBottomSheet({required this.orderId});

  @override
  State<_ShippingDetailBottomSheet> createState() =>
      _ShippingDetailBottomSheetState();
}

class _ShippingDetailBottomSheetState
    extends State<_ShippingDetailBottomSheet> {
  final OrderController _ctrl = Get.find<OrderController>();

  late final TextEditingController _trackingIdCtrl;
  late final TextEditingController _trackingUrlCtrl;
  late final TextEditingController _shippingExpCtrl;
  late final TextEditingController _additionalExpCtrl;
  late final TextEditingController _notesCtrl;

  final Rx<CourierPartnerDetailModel?> _selectedCourier =
      Rx<CourierPartnerDetailModel?>(null);
  final Rx<MediatorDetailModel?> _selectedMediator = Rx<MediatorDetailModel?>(
    null,
  );
  final Rx<DateTime?> _shippingDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _trackingIdCtrl = TextEditingController();
    _trackingUrlCtrl = TextEditingController();
    _shippingExpCtrl = TextEditingController();
    _additionalExpCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
    _ctrl.fetchCourierPartners();
  }

  @override
  void dispose() {
    _trackingIdCtrl.dispose();
    _trackingUrlCtrl.dispose();
    _shippingExpCtrl.dispose();
    _additionalExpCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _openAddCourierDialog() {
    Get.dialog(const _AddCourierDialog(), barrierDismissible: false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) _shippingDate.value = picked;
  }

  void _submit() {
    if (_selectedCourier.value == null) {
      Get.snackbar(
        "Error",
        "Please select courier partner",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_selectedMediator.value == null) {
      Get.snackbar(
        "Error",
        "Please select mediator",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_trackingIdCtrl.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter tracking ID",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (_shippingDate.value == null) {
      Get.snackbar(
        "Error",
        "Please select shipping date",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _ctrl.createShipment(
      orderId: widget.orderId,
      courierPartnerId: _selectedCourier.value!.id,
      mediatorId: _selectedMediator.value!.id,
      trackingId: _trackingIdCtrl.text.trim(),
      shippingDate: DateFormat('yyyy-MM-dd').format(_shippingDate.value!),
      trackingUrl: _trackingUrlCtrl.text.trim(),
      shippingExpense: double.tryParse(_shippingExpCtrl.text.trim()) ?? 0,
      otherExpense: double.tryParse(_additionalExpCtrl.text.trim()) ?? 0,
      notes: _notesCtrl.text.trim(),
      // ✅ Problem 2 Fix: callback se close karo — controller pe depend mat karo
      onSuccess: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Problem 1 Fix: viewInsets yahan lao — bahar nahi
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // ✅ height = screen - status bar - keyboard
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
          // ── Drag handle ──
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // ✅ Problem 1 Fix: bottomInset as padding inside scroll view
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 4, 24, 32 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create Shipment",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A4F),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 1. Courier Partner ──
                  _SheetLabel("Courier Partner"),
                  Obx(() {
                    final couriers = _ctrl.courierPartners;
                    return Row(
                      children: [
                        Expanded(
                          child: _ctrl.isLoadingCouriers.value
                              ? _loadingDropdown("Loading couriers…")
                              : _CourierDropdown<CourierPartnerDetailModel>(
                                  items: couriers,
                                  selectedObs: _selectedCourier,
                                  labelOf: (c) => c.title,
                                  hint: couriers.isEmpty
                                      ? "No couriers available"
                                      : "Select Courier",
                                  prefixIcon: Icons.local_shipping_outlined,
                                  onChanged: (val) {
                                    _selectedCourier.value = val;
                                    _selectedMediator.value = null;
                                  },
                                ),
                        ),
                        const SizedBox(width: 10),
                        _AddIconButton(onTap: _openAddCourierDialog),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  // ── 2. Mediator Partner ──
                  _SheetLabel("Mediator Partner"),
                  Obx(() {
                    final mediators = _selectedCourier.value?.mediators ?? [];
                    return _CourierDropdown<MediatorDetailModel>(
                      items: mediators,
                      selectedObs: _selectedMediator,
                      labelOf: (m) => m.title,
                      hint: mediators.isEmpty
                          ? "Select courier first"
                          : "Select Mediator",
                      prefixIcon: Icons.handshake_outlined,
                    );
                  }),
                  const SizedBox(height: 16),

                  // ── 3. Tracking ID & Shipping Date ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SheetLabel("Tracking ID"),
                            AppTextField(
                              controller: _trackingIdCtrl,
                              hintText: "Enter ID",
                              prefixIcon: Icons.qr_code_scanner_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SheetLabel("Shipping Date"),
                            Obx(
                              () => _DatePickerTile(
                                label: _shippingDate.value == null
                                    ? "Date"
                                    : DateFormat(
                                        'dd/MM/yy',
                                      ).format(_shippingDate.value!),
                                isEmpty: _shippingDate.value == null,
                                onTap: _pickDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── 4. Tracking URL ──
                  _SheetLabel("Tracking / Reference URL"),
                  AppTextField(
                    controller: _trackingUrlCtrl,
                    hintText: "https://tracking-link.com",
                    prefixIcon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 16),

                  // ── 5. Expenses ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SheetLabel("Shipping Expense"),
                            AppTextField(
                              controller: _shippingExpCtrl,
                              hintText: "Amount",
                              prefixIcon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SheetLabel("Other Expense"),
                            AppTextField(
                              controller: _additionalExpCtrl,
                              hintText: "Amount",
                              prefixIcon: Icons.add_card_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── 6. Notes ──
                  _SheetLabel("Notes / Remarks"),
                  AppTextField(
                    controller: _notesCtrl,
                    hintText: "Write details here…",
                    prefixIcon: Icons.note_add_outlined,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 28),

                  // ── 7. Submit ──
                  Obx(
                    () => AppGradientButton(
                      width: double.infinity,
                      height: 55,
                      text: _ctrl.isCreatingShipment.value
                          ? "Creating..."
                          : "Confirm Shipment",
                      onPressed: _ctrl.isCreatingShipment.value
                          ? null
                          : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Courier Dialog ────────────────────────────────────────────────────────
// ✅ Also converted to StatefulWidget — same controller-lifecycle fix

class _AddCourierDialog extends StatefulWidget {
  const _AddCourierDialog();

  @override
  State<_AddCourierDialog> createState() => _AddCourierDialogState();
}

class _AddCourierDialogState extends State<_AddCourierDialog> {
  final OrderController _ctrl = Get.find<OrderController>();

  late final TextEditingController _courierTitleCtrl;
  final List<TextEditingController> _mediatorCtrls = [];

  @override
  void initState() {
    super.initState();
    _courierTitleCtrl = TextEditingController();
    _mediatorCtrls.add(TextEditingController()); // start with one mediator
  }

  @override
  void dispose() {
    _courierTitleCtrl.dispose();
    for (final c in _mediatorCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMediator() {
    setState(() => _mediatorCtrls.add(TextEditingController()));
  }

  void _removeMediator(int index) {
    setState(() {
      _mediatorCtrls[index].dispose();
      _mediatorCtrls.removeAt(index);
    });
  }

  void _submit() {
    final mediatorTitles = _mediatorCtrls
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    _ctrl.createCourierPartner(
      title: _courierTitleCtrl.text.trim(),
      mediatorTitles: mediatorTitles,
      onSuccess: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
    // Dialog is closed by the controller on success
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add Courier Partner",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A4F),
                ),
              ),
              const SizedBox(height: 16),

              // Courier name
              TextField(
                controller: _courierTitleCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "Courier Name",
                  hintText: "e.g. Delhivery",
                  prefixIcon: const Icon(Icons.local_shipping_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Mediators header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Mediators",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A1A4F),
                    ),
                  ),
                  InkWell(
                    onTap: _addMediator,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 16, color: Color(0xFF1A1A4F)),
                          SizedBox(width: 4),
                          Text(
                            "Add Mediator",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1A1A4F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Mediator rows
              // ✅ setState-driven list — no Obx needed since this is StatefulWidget
              ...List.generate(_mediatorCtrls.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mediatorCtrls[i],
                          decoration: InputDecoration(
                            hintText: "Mediator ${i + 1}",
                            prefixIcon: const Icon(Icons.handshake_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      if (_mediatorCtrls.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: InkWell(
                            onTap: () => _removeMediator(i),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red.shade400,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Action buttons
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _ctrl.isCreatingCourier.value
                            ? null
                            : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _ctrl.isCreatingCourier.value
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: _ctrl.isCreatingCourier.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Create",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Generic inline dropdown ──────────────────────────────────────────────────
// ✅ Simple, self-contained dropdown — avoids CustomSearchableDropdown's
//    Rx<T?> selectedItem requirement which caused stale-ref issues in
//    function-based sheets.

class _CourierDropdown<T> extends StatelessWidget {
  const _CourierDropdown({
    required this.items,
    required this.selectedObs,
    required this.labelOf,
    required this.hint,
    required this.prefixIcon,
    this.onChanged,
  });

  final List<T> items;
  final Rx<T?> selectedObs;
  final String Function(T) labelOf;
  final String hint;
  final IconData prefixIcon;
  final void Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            isExpanded: true,
            value: selectedObs.value,
            hint: Row(
              children: [
                Icon(prefixIcon, size: 18, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(
                  hint,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade600,
            ),
            borderRadius: BorderRadius.circular(16),
            onChanged: items.isEmpty
                ? null
                : (val) {
                    selectedObs.value = val;
                    onChanged?.call(val);
                  },
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Row(
                      children: [
                        Icon(prefixIcon, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            labelOf(item),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            selectedItemBuilder: (ctx) => items
                .map(
                  (item) => Row(
                    children: [
                      Icon(
                        prefixIcon,
                        size: 18,
                        color: const Color(0xFF1A1A4F),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          labelOf(item),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A4F),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Small helper widgets ──────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  const _AddIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A4F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.isEmpty,
    required this.onTap,
  });

  final String label;
  final bool isEmpty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}

Widget _loadingDropdown(String message) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200, width: 1.2),
    ),
    child: Row(
      children: [
        const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 10),
        Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}
