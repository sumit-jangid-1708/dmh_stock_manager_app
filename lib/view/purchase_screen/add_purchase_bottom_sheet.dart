import 'package:dmj_stock_manager/model/product_model.dart';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../view_models/controller/item_controller.dart';
import '../../view_models/controller/purchase_controller.dart';
import '../../view_models/controller/vendor_controller.dart';

class AddPurchaseBottomSheet extends StatelessWidget {
  AddPurchaseBottomSheet({super.key});

  final PurchaseController purchaseController = Get.put(PurchaseController());
  final VendorController vendorController = Get.find<VendorController>();
  final ItemController itemController = Get.find<ItemController>();

  final List<String> statusOptions = ["PAID", "UNPAID", "PARTIAL PAID"];

  Future<void> _selectDate(BuildContext context, Rx<DateTime?> rxDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: rxDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      rxDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A1A4F);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Indicator
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Row(
                children: [
                  Icon(Icons.add_shopping_cart, color: primaryColor),
                  SizedBox(width: 10),
                  Text(
                    "Create Purchase Bill",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Vendor Selection
              _sectionHeader("General Information"),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<VendorModel>(
                value: purchaseController.selectedVendor.value,
                hint: const Text("Select Vendor"),
                isExpanded: true,
                decoration: _inputDecoration("Vendor *", Icons.person_outline),
                items: vendorController.vendors.map((vendor) {
                  return DropdownMenuItem<VendorModel>(
                    value: vendor,
                    child: Text(vendor.vendorName ?? "Unnamed"),
                  );
                }).toList(),
                onChanged: (value) =>
                purchaseController.selectedVendor.value = value,
              )),
              const SizedBox(height: 16),

              // Bill Number + Bill Date
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: purchaseController.billNumberController,
                      decoration: _inputDecoration(
                        "Bill Number *",
                        Icons.receipt_long,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, purchaseController.billDate),
                      child: AbsorbPointer(
                        child: Obx(() => TextField(
                          decoration: _inputDecoration(
                            "Bill Date *",
                            Icons.calendar_today_outlined,
                          ),
                          controller: TextEditingController(
                            text: purchaseController.billDate.value != null
                                ? DateFormat('dd MMM, yyyy').format(
                                purchaseController.billDate.value!)
                                : "",
                          ),
                        )),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Items Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Purchase Items"),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: primaryColor),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text(
                      "Add Item",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: purchaseController.addNewItem,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Obx(() => Column(
                children: purchaseController.purchaseItems
                    .asMap()
                    .entries
                    .map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: primaryColor,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() => DropdownButtonFormField<ProductModel>(
                                isExpanded: true,
                                value: item.selectedProduct.value,
                                hint: const Text("Select Product"),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: itemController.products.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      "${p.name} | ${p.size} | ${p.color}",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                item.selectedProduct.value = val,
                              )),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              onPressed: () =>
                                  purchaseController.removeItem(index),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: item.quantityController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  "Qty",
                                  null,
                                  isCompact: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: item.unitPriceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(
                                  "Price",
                                  null,
                                  isCompact: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )),

              const SizedBox(height: 16),

              // Description
              TextField(
                controller: purchaseController.descriptionController,
                maxLines: 2,
                decoration: _inputDecoration(
                  "Description (Optional)",
                  Icons.note_add_outlined,
                ),
              ),
              const SizedBox(height: 25),

              // Payment Details Section
              _sectionHeader("Payment Details"),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _selectDate(context, purchaseController.paidDate),
                      child: AbsorbPointer(
                        child: Obx(() => TextField(
                          decoration: _inputDecoration(
                            "Paid Date",
                            Icons.event_available,
                          ),
                          controller: TextEditingController(
                            text: purchaseController.paidDate.value != null
                                ? DateFormat('dd MMM, yyyy').format(
                                purchaseController.paidDate.value!)
                                : "",
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: purchaseController.paidAmountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        "Paid Amount",
                        Icons.currency_rupee,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => DropdownButtonFormField<String>(
                      value: purchaseController.selectedStatus.value,
                      decoration: _inputDecoration(
                        "Status *",
                        Icons.info_outline,
                      ),
                      items: statusOptions
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          purchaseController.selectedStatus.value = value;
                        }
                      },
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        purchaseController.clearForm();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: purchaseController.isLoading.value
                          ? null
                          : () async {
                        debugPrint("🔘 Create Purchase button clicked!");
                        await purchaseController.addPurchaseBill(
                          onSuccess: () {
                            Navigator.pop(context);
                            debugPrint("✅ Bottom sheet closed via Navigator.pop");
                          },
                        );
                      },
                      child: purchaseController.isLoading.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Create Purchase",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade600,
        letterSpacing: 1.2,
      ),
    );
  }

  // Helper for Input Decoration
  InputDecoration _inputDecoration(String label, IconData? icon,
      {bool isCompact = false}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: const Color(0xFF1A1A4F))
          : null,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isCompact ? 10 : 16,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF1A1A4F),
          width: 1.5,
        ),
      ),
    );
  }
}