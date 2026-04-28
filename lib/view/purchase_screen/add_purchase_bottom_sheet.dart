import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/model/vendor_model/vendor_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_searchable_dropdown.dart';
import 'package:dmj_stock_manager/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../res/components/widgets/custom_text_field.dart';
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
    if (picked != null) rxDate.value = picked;
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

              // ── 1. VENDOR & BILL INFO ──────────────────────────────────
              _sectionHeader("Vendor & Bill Details"),
              const SizedBox(height: 12),
              CustomSearchableDropdown<VendorModel>(
                items: vendorController.vendors,
                selectedItem: purchaseController.selectedVendor,
                itemAsString: (vendor) => vendor.vendorName ?? "Unnamed",
                hintText: "Select Vendor *",
                prefixIcon: Icons.person_outline,
                searchHint: "Search vendors...",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: purchaseController.billNumberController,
                      hintText: "Bill No *",
                      prefixIcon: Icons.receipt_long,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _selectDate(context, purchaseController.billDate),
                      child: AbsorbPointer(
                        child: Obx(
                          () => AppTextField(
                            controller: TextEditingController(
                              text: purchaseController.billDate.value != null
                                  ? DateFormat(
                                      'dd MMM, yyyy',
                                    ).format(purchaseController.billDate.value!)
                                  : "",
                            ),
                            hintText: "Bill Date *",
                            prefixIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Supply and Type in one row for better space usage
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: "Place of Supply",
                      prefixIcon: Icons.location_on_outlined,
                      controller: purchaseController.placeOfSupplyController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: purchaseController.selectedPurchaseType.value,
                        decoration: Utils.inputDecoration(
                          "Tax Type",
                          Icons.category_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "WITH_GST",
                            child: Text("With GST"),
                          ),
                          DropdownMenuItem(
                            value: "WITHOUT_GST",
                            child: Text("No GST"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            purchaseController.selectedPurchaseType.value = val;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // ── GST Section (Conditional) ──────────────────────────────
              Obx(() {
                if (purchaseController.selectedPurchaseType.value != 'WITH_GST') {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _GstTypeChip(
                                label: "SGST + CGST",
                                value: "SGST_CGST",
                                groupValue:
                                    purchaseController.selectedGstType.value,
                                onTap: () =>
                                    purchaseController.selectedGstType.value =
                                        "SGST_CGST",
                              ),
                              _GstTypeChip(
                                label: "IGST Only",
                                value: "IGST",
                                groupValue:
                                    purchaseController.selectedGstType.value,
                                onTap: () =>
                                    purchaseController.selectedGstType.value =
                                        "IGST",
                              ),
                            ],
                          ),
                          if (purchaseController.selectedGstType.value ==
                              'SGST_CGST') ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    controller:
                                        purchaseController.sgstController,
                                    hintText: "SGST %",
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.percent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppTextField(
                                    controller:
                                        purchaseController.cgstController,
                                    hintText: "CGST %",
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.percent,
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: purchaseController.igstController,
                              hintText: "IGST %",
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.percent,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 25),

              // ── 2. ITEMS SECTION ───────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("Purchase Items"),
                  TextButton.icon(
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

              Obx(
                () => Column(
                  children: purchaseController.purchaseItems
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildItemCard(
                          index,
                          item,
                          itemController,
                          purchaseController,
                          primaryColor,
                        );
                      })
                      .toList(),
                ),
              ),

              const SizedBox(height: 25),

              // ── 3. FINANCIAL DETAILS ───────────────────────────────────
              _sectionHeader("Charges & Discounts"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: "Discount",
                      prefixIcon: Icons.discount_outlined,
                      controller: purchaseController.discountController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      hintText: "Shipping",
                      prefixIcon: Icons.local_shipping_outlined,
                      controller: purchaseController.shippingController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      hintText: "Other Exp",
                      prefixIcon: Icons.add_card,
                      controller: purchaseController.otherChargesController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      hintText: "Round Off",
                      prefixIcon: Icons.auto_fix_normal,
                      controller: purchaseController.roundOffController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: purchaseController.descriptionController,
                hintText: "Internal Remarks/Description",
                prefixIcon: Icons.note_add_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 25),

              // ── 4. PAYMENT STATUS ──────────────────────────────────────
              _sectionHeader("Payment Information"),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.green.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: purchaseController.selectedStatus.value,
                        decoration: Utils.inputDecoration(
                          "Status *",
                          Icons.info_outline,
                        ),
                        items: statusOptions
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            purchaseController.selectedStatus.value = v!,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: Utils.inputDecoration("Mode", Icons.payment),
                      items: const [
                        DropdownMenuItem(value: "CASH", child: Text("Cash")),
                        DropdownMenuItem(value: "UPI", child: Text("UPI")),
                        DropdownMenuItem(value: "BANK", child: Text("Bank")),
                      ],
                      onChanged: (val) {},
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: purchaseController.paidAmountController,
                            hintText: "Paid Amount",
                            prefixIcon: Icons.currency_rupee,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(
                              context,
                              purchaseController.paidDate,
                            ),
                            child: AbsorbPointer(
                              child: Obx(
                                () => AppTextField(
                                  controller: TextEditingController(
                                    text:
                                        purchaseController.paidDate.value !=
                                            null
                                        ? DateFormat('dd MMM, yyyy').format(
                                            purchaseController.paidDate.value!,
                                          )
                                        : "",
                                  ),
                                  hintText: "Paid Date",
                                  prefixIcon: Icons.event_available,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      hintText: "Transaction ID / Reference",
                      prefixIcon: Icons.numbers,
                      controller: purchaseController.transactionIdController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ── ACTION BUTTONS ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: purchaseController.isLoading.value
                            ? null
                            : () => purchaseController.addPurchaseBill(
                                onSuccess: () => Get.back(),
                              ),
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
                                "Create Bill",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    int index,
    dynamic item,
    ItemController itemController,
    PurchaseController purchaseController,
    Color primaryColor,
  ) {
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
                radius: 12,
                backgroundColor: primaryColor,
                child: Text(
                  "${index + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomSearchableDropdown<ProductModel>(
                  items: itemController.products,
                  selectedItem: item.selectedProduct,
                  itemAsString: (p) => "${p.name} | ${p.sku}",
                  hintText: "Select Product",
                  prefixIcon: Icons.inventory_2_outlined,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => purchaseController.removeItem(index),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: item.quantityController,
                  hintText: "Qty",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.numbers,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextField(
                  controller: item.unitPriceController,
                  hintText: "Price",
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.currency_rupee,
                ),
              ),
              // const SizedBox(width: 10),
              // Expanded(
              //   child: AppTextField(
              //     controller: purchaseController.gatPercentController,
              //     hintText: "GST %",
              //     keyboardType: TextInputType.number,
              //     prefixIcon: Icons.percent,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.blueGrey.shade700,
        letterSpacing: 1.1,
      ),
    );
  }
} // ─────────────────────────────────────────────────────────────────────────────
// _GstTypeChip — small selectable pill for SGST+CGST / IGST toggle
// ─────────────────────────────────────────────────────────────────────────────

class _GstTypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const _GstTypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A1A4F);
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
