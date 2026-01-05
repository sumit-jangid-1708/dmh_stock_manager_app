import 'dart:io';
import 'package:dmj_stock_manager/model/hsn_model.dart';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/multi_image_picker_widget.dart';
import 'package:dmj_stock_manager/utils/app_lists.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemFormBottomSheet extends StatefulWidget {
  const AddItemFormBottomSheet({super.key});

  @override
  State<AddItemFormBottomSheet> createState() => _AddItemFormBottomSheetState();
}

class _AddItemFormBottomSheetState extends State<AddItemFormBottomSheet> {
  List<File> _selectedImages = [];
  String? _selectedColor;
  String? _selectedSize;
  String? _selectedMaterial;
  String? _selectedHsnCode;
  int? _selectedHsnId;

  final VendorController vendorController = Get.find<VendorController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final ItemController itemController = Get.find<ItemController>();

  String? _selectedVendorName;
  String? _selectedVendorId;

  // --- Theme Decoration Helper ---
  InputDecoration _getDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1A1A4F), size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A1A4F), width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // IMAGE PICKER SECTION
                  _buildSectionTitle("Product Media", Icons.image_outlined),
                  const SizedBox(height: 12),
                  MultiImagePickerWidget(
                    onImagesSelected: (files) =>
                        setState(() => _selectedImages = files),
                  ),
                  const SizedBox(height: 24),

                  // BASIC INFO SECTION
                  _buildSectionTitle("Basic Information", Icons.info_outline),
                  const SizedBox(height: 12),
                  _buildVendorSelector(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: itemController.productName.value,
                    decoration: _getDecoration(
                      "Item Name*",
                      Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: itemController.skuCode.value,
                    decoration: _getDecoration(
                      "SKU Code*",
                      Icons.qr_code_scanner,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // PRICING SECTION
                  _buildSectionTitle(
                    "Pricing & Stock",
                    Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    // <--- Row ki jagah Column kar diya
                    children: [
                      TextField(
                        controller: itemController.purchasePrice.value,
                        keyboardType: TextInputType.number,
                        decoration: _getDecoration(
                          "Purchase Price",
                          Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(height: 12), // Vertical spacing add ki
                      TextField(
                        controller: itemController.lowStockLimit.value,
                        keyboardType: TextInputType.number,
                        decoration: _getDecoration(
                          "Low Stock Limit",
                          Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ATTRIBUTES SECTION
                  _buildSectionTitle("Attributes & Tax", Icons.style_outlined),
                  const SizedBox(height: 12),
                  _buildActionDropdown(
                    label: 'Material',
                    items: List<String>.from(AppLists.materials),
                    value: _selectedMaterial,
                    icon: Icons.layers_outlined,
                    onChanged: (val) => setState(() => _selectedMaterial = val),
                    onAdd: () => _showAddDialog(
                      "Material",
                      (v) => AppLists.addMaterial(v),
                      (v) => _selectedMaterial = v,
                    ),
                  ),
                  _buildActionDropdown(
                    label: 'Colour',
                    items: List<String>.from(AppLists.colors),
                    value: _selectedColor,
                    icon: Icons.palette_outlined,
                    onChanged: (val) => setState(() => _selectedColor = val),
                    onAdd: () => _showAddDialog(
                      "Color",
                      (v) => AppLists.addColor(v),
                      (v) => _selectedColor = v,
                    ),
                  ),
                  _buildActionDropdown(
                    label: 'Size',
                    items: List<String>.from(AppLists.sizes),
                    value: _selectedSize,
                    icon: Icons.straighten_outlined,
                    onChanged: (val) => setState(() => _selectedSize = val),
                    onAdd: () => _showAddDialog(
                      "Size",
                      (v) => AppLists.addSize(v),
                      (v) => _selectedSize = v,
                    ),
                  ),
                  _buildHsnDropdown(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Custom UI Components ---
  Widget _buildDragHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A4F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_box_outlined, color: Color(0xFF1A1A4F)),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add New Product",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Complete the details below",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildVendorSelector() {
    return Obx(() {
      final isLoading = vendorController.isLoading.value;
      return InkWell(
        onTap: isLoading ? null : _openVendorPicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business_outlined,
                color: Color(0xFF1A1A4F),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedVendorName ?? "Select Vendor*",
                  style: TextStyle(
                    color: _selectedVendorName == null
                        ? Colors.grey.shade500
                        : Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    required VoidCallback onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Row(
                    children: [
                      Icon(icon, size: 20, color: const Color(0xFF1A1A4F)),
                      const SizedBox(width: 12),
                      Text("Select $label"),
                    ],
                  ),
                  isExpanded: true,
                  items: items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: Color(0xFF1A1A4F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHsnDropdown() {
    return Obx(() {
      final hsnList = itemController.hsnList;
      return _buildActionDropdown(
        label: 'HSN/SAC',
        items: hsnList.map((e) => e.hsnCode ?? "").toList(),
        value: _selectedHsnCode,
        icon: Icons.description,
        onChanged: (selectedCode) {
          if (selectedCode != null) {
            final selectedHsn = hsnList.firstWhere(
              (hsn) => hsn.hsnCode == selectedCode,
            );
            setState(() {
              _selectedHsnCode = selectedCode;
              _selectedHsnId = selectedHsn.id;
            });
          }
        },
        onAdd: () => _showAddHsnDialog(context),
      );
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A4F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          final imagesCopy = List<File>.from(_selectedImages);
          itemController.addProduct(
            _selectedVendorId!,
            _selectedColor!,
            _selectedSize!,
            _selectedMaterial!,
            itemController.purchasePrice.value.text,
            imagesCopy,
            _selectedHsnId.toString(),
          );
          Get.back();
        },
        child: const Text(
          'Add Product to Stock',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // --- Logic Helpers ---

  void _openVendorPicker() {
    DropDownState(
      dropDown: DropDown(
        data: vendorController.vendors
            .map((v) => SelectedListItem<VendorModel>(data: v))
            .toList(),
        onSelected: (selected) {
          if (selected.isNotEmpty) {
            final v = selected.first.data;
            setState(() {
              _selectedVendorName = v.vendorName;
              _selectedVendorId = v.id.toString();
            });
            dashboardController.setSelectedVendor(
              _selectedVendorId!,
              _selectedVendorName!,
            );
          }
        },
      ),
    ).showModal(context);
  }

  void _showAddDialog(
    String name,
    Function(String) addToList,
    Function(String) updateSelected,
  ) {
    final controller = TextEditingController();
    Get.defaultDialog(
      title: "Add $name",
      content: TextField(
        controller: controller,
        decoration: _getDecoration("Enter $name", Icons.edit),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A4F),
        ),
        onPressed: () {
          if (controller.text.isNotEmpty) {
            addToList(controller.text);
            setState(() => updateSelected(controller.text));
          }
          Get.back();
        },
        child: const Text("Add", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddHsnDialog(BuildContext context) {
    final hsnController = TextEditingController();
    final gstController = TextEditingController();

    Get.defaultDialog(
      title: "New HSN Code",
      backgroundColor: Colors.white,
      radius: 16,
      content: Column(
        children: [
          TextField(
            controller: hsnController,
            decoration: _getDecoration("HSN Code", Icons.pin),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: gstController,
            keyboardType: TextInputType.number,
            decoration: _getDecoration("GST %", Icons.percent),
          ),
        ],
      ),
      confirm: Container(
        width: 100,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: () async {
            final code = hsnController.text.trim();
            final gstText = gstController.text.trim();
            if (code.isEmpty || gstText.isEmpty) {
              Get.snackbar(
                "Required",
                "All fields are mandatory",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
            final gst = double.tryParse(gstText) ?? 0.0;
            await itemController.addHsn(code, gst);
            final newHsn = itemController.hsnList.firstWhereOrNull(
              (e) => e.hsnCode == code,
            );
            if (newHsn != null) {
              setState(() {
                _selectedHsnCode = newHsn.hsnCode;
                _selectedHsnId = newHsn.id;
              });
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text("Save", style: TextStyle(color: Colors.white)),
        ),
      ),
      cancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
