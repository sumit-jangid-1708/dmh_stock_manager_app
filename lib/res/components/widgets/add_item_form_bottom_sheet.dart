import 'dart:io';
import 'package:dmj_stock_manager/model/vendor_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/res/components/widgets/multi_image_picker_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_searchable_dropdown.dart';
import 'package:dmj_stock_manager/utils/app_lists.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddItemFormBottomSheet extends StatefulWidget {
  const AddItemFormBottomSheet({super.key});

  @override
  State<AddItemFormBottomSheet> createState() => _AddItemFormBottomSheetState();
}

class _AddItemFormBottomSheetState extends State<AddItemFormBottomSheet> {
  List<File> _selectedImages = [];

  // Using Rx for reactive dropdown selections
  final Rx<String?> _selectedColor = Rx<String?>(null);
  final Rx<String?> _selectedSize = Rx<String?>(null);
  final Rx<String?> _selectedMaterial = Rx<String?>(null);
  final Rx<String?> _selectedHsnCode = Rx<String?>(null);
  final Rx<VendorModel?> _selectedVendor = Rx<VendorModel?>(null);
  final Rx<dynamic> _selectedHsn = Rx<dynamic>(null);

  int? _selectedHsnId;

  final VendorController vendorController = Get.find<VendorController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final ItemController itemController = Get.find<ItemController>();

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

                  // Vendor Dropdown
                  CustomSearchableDropdown<VendorModel>(
                    items: vendorController.vendors,
                    selectedItem: _selectedVendor,
                    itemAsString: (vendor) => vendor.vendorName ?? "Unknown",
                    hintText: "Select Vendor*",
                    prefixIcon: Icons.business_outlined,
                    searchHint: "Search vendors...",
                    onChanged: (vendor) {
                      if (vendor != null) {
                        dashboardController.setSelectedVendor(
                          vendor.id.toString(),
                          vendor.vendorName ?? "",
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),
                  AppTextField(
                    controller: itemController.productName.value,
                    hintText: "Item Name",
                    prefixIcon: Icons.inventory_2_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: itemController.skuCode.value,
                    hintText: "SKU Code",
                    prefixIcon: Icons.qr_code_scanner,
                  ),
                  const SizedBox(height: 24),

                  // PRICING SECTION
                  _buildSectionTitle(
                    "Pricing & Stock",
                    Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: itemController.purchasePrice.value,
                    hintText: "Purchase Price",
                    prefixIcon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: itemController.lowStockLimit.value,
                    hintText: "Low Stock Limit",
                    prefixIcon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 24),

                  // ATTRIBUTES SECTION
                  _buildSectionTitle("Attributes & Tax", Icons.style_outlined),
                  const SizedBox(height: 12),

                  // Material Dropdown
                  _buildSearchableDropdownWithAdd(
                    label: 'Material',
                    items: AppLists.materials,
                    selectedItem: _selectedMaterial,
                    icon: Icons.layers_outlined,
                    onAdd: () => _showAddDialog(
                      "Material",
                      (v) => AppLists.addMaterial(v),
                      (v) => _selectedMaterial.value = v,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Color Dropdown
                  _buildSearchableDropdownWithAdd(
                    label: 'Colour',
                    items: AppLists.colors,
                    selectedItem: _selectedColor,
                    icon: Icons.palette_outlined,
                    onAdd: () => _showAddDialog(
                      "Color",
                      (v) => AppLists.addColor(v),
                      (v) => _selectedColor.value = v,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Size Dropdown
                  _buildSearchableDropdownWithAdd(
                    label: 'Size',
                    items: AppLists.sizes,
                    selectedItem: _selectedSize,
                    icon: Icons.straighten_outlined,
                    onAdd: () => _showAddDialog(
                      "Size",
                      (v) => AppLists.addSize(v),
                      (v) => _selectedSize.value = v,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // HSN Dropdown
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

  Widget _buildSearchableDropdownWithAdd({
    required String label,
    required List<String> items,
    required Rx<String?> selectedItem,
    required IconData icon,
    required VoidCallback onAdd,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomSearchableDropdown<String>(
            items: items,
            selectedItem: selectedItem,
            itemAsString: (item) => item,
            hintText: "Select $label",
            prefixIcon: icon,
            searchHint: "Search $label...",
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
    );
  }

  Widget _buildHsnDropdown() {
    return Obx(() {
      final hsnList = itemController.hsnList;

      return Row(
        children: [
          Expanded(
            child: CustomSearchableDropdown<dynamic>(
              items: hsnList.toList(),
              selectedItem: _selectedHsn,
              itemAsString: (hsn) => hsn.hsnCode ?? "Unknown",
              hintText: "Select HSN/SAC",
              prefixIcon: Icons.description,
              searchHint: "Search HSN codes...",
              onChanged: (selectedHsnItem) {
                if (selectedHsnItem != null) {
                  _selectedHsn.value = selectedHsnItem;
                  _selectedHsnCode.value = selectedHsnItem.hsnCode;
                  _selectedHsnId = selectedHsnItem.id;
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => _showAddHsnDialog(context),
              icon: const Icon(Icons.add, color: Color(0xFF1A1A4F)),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AppGradientButton(
        text: "Add Product to Stock",
        onPressed: () {
          final vendor = _selectedVendor.value;
          final color = _selectedColor.value;
          final size = _selectedSize.value;
          final material = _selectedMaterial.value;

          if (vendor == null ||
              color == null ||
              size == null ||
              material == null) {
            Get.snackbar(
              "Required Fields",
              "Please fill all required fields",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          final imagesCopy = List<File>.from(_selectedImages);
          itemController.addProduct(
            vendor.id.toString(),
            color,
            size,
            material,
            itemController.purchasePrice.value.text,
            imagesCopy,
            _selectedHsnId.toString(),
          );
          Get.back();
        },
      ),
    );
  }

  // --- Logic Helpers ---

  void _showAddDialog(
    String name,
    Function(String) addToList,
    Function(String) updateSelected,
  ) {
    final controller = TextEditingController();
    Get.defaultDialog(
      backgroundColor: Colors.white,
      title: "Add $name",
      content: AppTextField(
        controller: controller,
        hintText: "Enter $name",
        prefixIcon: Icons.edit,
      ),

      confirm: AppGradientButton(
        onPressed: () {
          if (controller.text.isNotEmpty) {
            addToList(controller.text);
            updateSelected(controller.text);
          }
          Get.back();
        },
        text: "Add",
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
          AppTextField(
            controller: hsnController,
            hintText: "HSN Code",
            prefixIcon: Icons.pin,
          ),
          const SizedBox(height: 10),
          AppTextField(
            controller: gstController,
            hintText: "GST %",
            prefixIcon: Icons.percent,
            keyboardType: TextInputType.number,
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
        child: AppGradientButton(
          text: "Save",
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
              _selectedHsn.value = newHsn;
              _selectedHsnCode.value = newHsn.hsnCode;
              _selectedHsnId = newHsn.id;

              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ),
      cancel: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Cancel", style: TextStyle(color: Color(0xFF1A1A4F))),
      ),
    );
  }
}
