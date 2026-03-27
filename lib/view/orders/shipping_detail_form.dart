import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../res/components/widgets/app_gradient _button.dart';
import '../../res/components/widgets/custom_searchable_dropdown.dart';
import '../../res/components/widgets/custom_text_field.dart';

void showShippingDetailsBottomSheet(BuildContext context) {
  // Controllers
  final TextEditingController trackingIdController = TextEditingController();
  final TextEditingController trackingUrlController = TextEditingController(); // Naya Controller
  final TextEditingController shippingExpenseController = TextEditingController();
  final TextEditingController additionalExpenseController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rx<DateTime?> shippingDate = Rx<DateTime?>(null);

  // Dropdown Selections
  final List<String> courierPartners = ["Delhivery", "BlueDart", "Ecom Express", "FedEx"];
  final Rx<String?> selectedCourier = Rx<String?>(null);

  final List<String> middlePartners = ["Partner A", "Partner B", "Direct"];
  final Rx<String?> selectedMiddlePartner = Rx<String?>(null);

  Get.bottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              "Create Shipment",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
            ),
            const SizedBox(height: 20),

            // 1. Courier & Middle Partner
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Courier Partner"),
                      CustomSearchableDropdown<String>(
                        items: courierPartners,
                        selectedItem: selectedCourier,
                        itemAsString: (item) => item,
                        hintText: "Courier",
                        prefixIcon: Icons.local_shipping_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Middle Partner"),
                      CustomSearchableDropdown<String>(
                        items: middlePartners,
                        selectedItem: selectedMiddlePartner,
                        itemAsString: (item) => item,
                        hintText: "Partner",
                        prefixIcon: Icons.handshake_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Tracking ID & Shipping Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Tracking ID"),
                      AppTextField(
                        controller: trackingIdController,
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
                      _label("Shipping Date"),
                      _datePickerTile(context, shippingDate, "Date"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Tracking URL (Naya Field)
            _label("Tracking / Reference URL"),
            AppTextField(
              controller: trackingUrlController,
              hintText: "https://tracking-link.com",
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // 4. Expenses Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Shipping Expense"),
                      AppTextField(
                        controller: shippingExpenseController,
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
                      _label("Other Expense"),
                      AppTextField(
                        controller: additionalExpenseController,
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

            // 5. Notes / Remarks (Enter Button Enabled)
            _label("Notes / Remarks"),
            AppTextField(
              controller: notesController,
              hintText: "Write details here...",
              prefixIcon: Icons.note_add_outlined,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 24),

            // 6. Submit Button
            AppGradientButton(
              width: double.infinity,
              height: 55,
              text: "Confirm Shipment",
              onPressed: () {
                // Yahan se aap trackingUrlController.text access kar sakte hain
                Get.back();
              },
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    ),
  );
}

// --- Helper Widgets unchanged ---
Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, left: 4),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
    ),
  );
}

Widget _datePickerTile(BuildContext context, Rx<DateTime?> dateObs, String hint) {
  return Obx(() => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) dateObs.value = picked;
    },
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
              dateObs.value == null ? hint : DateFormat('dd/MM/yy').format(dateObs.value!),
              style: TextStyle(fontSize: 14, color: dateObs.value == null ? Colors.grey.shade400 : Colors.black87),
            ),
          ),
          Icon(Icons.calendar_month, size: 18, color: Colors.grey.shade600),
        ],
      ),
    ),
  ));
}