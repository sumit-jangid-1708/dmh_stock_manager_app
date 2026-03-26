import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../res/components/widgets/app_gradient _button.dart';
import '../../res/components/widgets/custom_searchable_dropdown.dart';
import '../../res/components/widgets/custom_text_field.dart';

void showShippingDetailsBottomSheet(BuildContext context) {
  // Controllers and State variables
  final TextEditingController trackingIdController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final Rx<DateTime?> shippingDate = Rx<DateTime?>(null);
  final Rx<DateTime?> expectedDeliveryDate = Rx<DateTime?>(null);

  // Dummy data for Courier Partners
  final List<String> courierPartners = ["Delhivery", "BlueDart", "Ecom Express", "FedEx"];
  final Rx<String?> selectedCourier = Rx<String?>(null);

  Get.bottomSheet(
    isScrollControlled: true,
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
              "Shipping Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A4F),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Courier Partner Dropdown
            _label("Courier Partner"),
            CustomSearchableDropdown<String>(
              items: courierPartners,
              selectedItem: selectedCourier,
              itemAsString: (item) => item,
              hintText: "Select courier type",
              prefixIcon: Icons.local_shipping_outlined,
              onChanged: (val) => selectedCourier.value = val,
            ),
            const SizedBox(height: 20),

            // 2. Tracking ID
            _label("Tracking ID"),
            AppTextField(
              controller: trackingIdController,
              hintText: "Enter Tracking ID",
              prefixIcon: Icons.qr_code_scanner_rounded,
            ),
            const SizedBox(height: 20),

            // 3. Shipping Date & Expected Delivery Date (Row)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Shipping Date"),
                      _datePickerTile(context, shippingDate, "DD/MM/YYYY"),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Expected Delivery"),
                      _datePickerTile(context, expectedDeliveryDate, "DD/MM/YYYY"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Notes
            _label("Notes"),
            AppTextField(
              controller: notesController,
              hintText: "Write Note here...",
              prefixIcon: Icons.note_add_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 32),

            // 5. Submit Button
            AppGradientButton(
              width: double.infinity,
              height: 55,
              text: "Submit",
              onPressed: () {
                Get.back();
              },
            ),
            // Keyboard adjustment for bottom sheet
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    ),
  );
}

// Helper widget for Labels
Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    ),
  );
}

// Helper for Date Pickers using Container and InkWell to match AppTextField UI
Widget _datePickerTile(BuildContext context, Rx<DateTime?> dateObs, String hint) {
  return Obx(() => InkWell(
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A4F)),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) dateObs.value = picked;
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              dateObs.value == null
                  ? hint
                  : DateFormat('dd/MM/yyyy').format(dateObs.value!),
              style: TextStyle(
                fontSize: 14,
                color: dateObs.value == null ? Colors.grey.shade400 : Colors.black87,
              ),
            ),
          ),
          Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey.shade600),
        ],
      ),
    ),
  ));
}