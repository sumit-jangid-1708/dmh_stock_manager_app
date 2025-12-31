import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:dmj_stock_manager/model/product_model.dart';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import '../../view_models/controller/purchase_controller.dart';

class AddPurchaseBottomSheet extends StatelessWidget {
  AddPurchaseBottomSheet({super.key});

  final PurchaseController purchaseController = Get.put(PurchaseController());
  final VendorController vendorController = Get.find<VendorController>();
  final ItemController itemController = Get.find<ItemController>();

  final Rx<DateTime?> billDate = Rx<DateTime?>(DateTime.now());
  final Rx<DateTime?> dueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> paidDate = Rx<DateTime?>(null);

  final TextEditingController billNumberController = TextEditingController(
    text: "PO-2026",
  );
  final TextEditingController billAmountController = TextEditingController(
    text: "₹0.00",
  );
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();

  final RxString selectedVendor = "".obs;
  final RxString paymentStatus = "UNPAID".obs; // Payment Status

  final List<String> vendors = ["Vendor A", "Vendor B", "Vendor C"];
  //
  // List<SelectedListItem<VendorModel>> get _vendorListItems => vendorController
  //     .vendors
  //     .map((v) => SelectedListItem<VendorModel>(data: v)) // ⬅️ pass full object
  //     .toList();

  Future<void> _selectDate(
    BuildContext context,
    Rx<DateTime?> dateController,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateController.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateController.value = picked;
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required void Function(T?) onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              hint: Text("--Select $label--"),
              value: value,
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem<T>(
                  value: e,
                  child: Text(labelBuilder(e)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Purchase Bill",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Vendor Dropdown
            Obx(() {
              return _buildDropdown<VendorModel>(
                label: "Vendor",
                items: vendorController.vendors.toList(),
                value: vendorController.selectedVendor.value,
                onChanged: (v) => vendorController.selectedVendor.value = v,
                labelBuilder: (v) => v.vendorName ?? "Unknown",
              );
            }),

            // Bill Details
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: billNumberController,
                    // readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Bill Number*",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    return GestureDetector(
                      onTap: () => _selectDate(context, billDate),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: DateFormat(
                              'd/MM/yyyy',
                            ).format(billDate.value ?? DateTime.now()),
                          ),
                          decoration: InputDecoration(
                            labelText: "Bill Date*",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items Section
            const Text(
              "Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            Obx(() {
              return Column(
                children: purchaseController.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDropdown(
                          label: "Product",
                          items: itemController.products,
                          value: itemController.selectedProduct.value,
                          onChanged: (v) =>
                              itemController.selectedProduct.value = v,
                          labelBuilder: (v) => v.name ?? "Unknown",
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: item["quantity"],
                                decoration: InputDecoration(
                                  labelText: "Qty",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: item["unit"],
                                decoration: InputDecoration(
                                  labelText: "Unit",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A4F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  purchaseController.removeItemRow(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: purchaseController.addItemRow,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Item",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description (Optional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 1,
            ),

            const SizedBox(height: 16),
            const Text(
              "Payment Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Obx(() {
              return GestureDetector(
                onTap: () => _selectDate(
                  context,
                  paidDate,
                ), // reuse existing date selector
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: paidDate.value == null
                          ? ""
                          : DateFormat('d/mm/yyyy').format(paidDate.value!),
                    ),
                    decoration: InputDecoration(
                      labelText: "Paid Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            TextField(
              controller: paidAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Paid Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Obx(() {
              return _buildDropdown<String>(
                label: "Payment Status",
                items: const ["PAID", "UNPAID", " PARTIAL PAID"],
                value: paymentStatus.value,
                onChanged: (v) => paymentStatus.value = v ?? "UNPAID",
                labelBuilder: (v) => v,
              );
            }),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A4F),
                    ),
                    onPressed: () {
                      // Save or Submit logic here
                      Get.back();
                    },
                    child: const Text(
                      "Create",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
