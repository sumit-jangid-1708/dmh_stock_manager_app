import 'dart:io';
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
import 'package:image_picker/image_picker.dart';

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

  // GetX controllers
  final VendorController vendorController = Get.find<VendorController>();
  final DashboardController dashboardController =
  Get.find<DashboardController>();
  final ItemController itemController = Get.find<ItemController>();

  // Local selection state for the dropdown UI
  String? _selectedVendorName;
  String? _selectedVendorId;
  List<SelectedListItem<VendorModel>> get _vendorListItems => vendorController
      .vendors
      .map((v) => SelectedListItem<VendorModel>(data: v))
      .toList();

  void _openVendorPicker() {
    if (vendorController.isLoading.value) return;

    if (vendorController.vendors.isEmpty) {
      vendorController.getVendors();
      return;
    }

    DropDownState(
      dropDown: DropDown(
        data: _vendorListItems,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultiImagePickerWidget(
                onImagesSelected: (files) {
                  setState(() {
                    _selectedImages = files;
                  });
                },
              ),
              const SizedBox(height: 20),

              _buildVendorDropdown(label: 'Vendor Name*'),
              _buildTextField(
                label: 'Item Name',
                hint: 'Enter your Item',
                addProductController: itemController.productName.value,
              ),
              _buildTextField(
                label: 'SKU',
                hint: 'Enter your SKU',
                addProductController: itemController.skuCode.value,
              ),
              _buildTextField(
                label: 'Purchase Price',
                hint: 'Enter purchase price',
                addProductController: itemController.purchasePrice.value,
              ),
              _buildTextField(
                label: 'Set Low Stock',
                hint: 'Enter low stock limit',
                addProductController: itemController.lowStockLimit.value,
              ),

              // Material Row with Add Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Material',
                      items: AppLists.materials,
                      value: _selectedMaterial,
                      onChanged: (val) => setState(() => _selectedMaterial = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextButton.icon(
                      onPressed: () {
                        _showAddDialog(
                          context: context,
                          title: "Add New Material",
                          hint: "Enter material name",
                          onAdd: (value) {
                            AppLists.addMaterial(value);
                            setState(() => _selectedMaterial = value);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ),
                ],
              ),

              // Color and Size Row with Add Buttons
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Colour',
                      items: AppLists.colors,
                      value: _selectedColor,
                      onChanged: (val) => setState(() => _selectedColor = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextButton.icon(
                      onPressed: () {
                        _showAddDialog(
                          context: context,
                          title: "Add New Color",
                          hint: "Enter color name",
                          onAdd: (value) {
                            AppLists.addColor(value);
                            setState(() => _selectedColor = value);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Size',
                      items: AppLists.sizes,
                      value: _selectedSize,
                      onChanged: (val) => setState(() => _selectedSize = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextButton.icon(
                      onPressed: () {
                        _showAddDialog(
                          context: context,
                          title: "Add New Size",
                          hint: "Enter size",
                          onAdd: (value) {
                            AppLists.addSize(value);
                            setState(() => _selectedSize = value);
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add"),
                    ),
                  ),
                ],
              ),

              _buildTextField(
                label: 'HSN/SAC',
                hint: 'Enter HSN/SAC code',
                addProductController: itemController.hsnCode.value,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    itemController.addProduct(
                      _selectedVendorId!,
                      _selectedColor!,
                      _selectedSize!,
                      _selectedMaterial!,
                      itemController.purchasePrice.value.text,
                      _selectedImages,
                      itemController.hsnCode.value.text,
                    );
                    Get.back();
                  },
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ------- UI helpers -------

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? addProductController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: addProductController,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildVendorDropdown({required String label}) {
    return Obx(() {
      final isLoading = vendorController.isLoading.value;
      final hasData = vendorController.vendors.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          InkWell(
            onTap: isLoading ? null : _openVendorPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey.shade100 : null,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedVendorName ??
                          (isLoading
                              ? "Loading vendors…"
                              : hasData
                              ? "Select Vendor"
                              : "No vendors found"),
                      style: TextStyle(
                        color: _selectedVendorName == null
                            ? const Color.fromARGB(255, 109, 109, 109)
                            : Colors.black,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }

  // ✅ Generic dialog for adding Material, Color, or Size
  void _showAddDialog({
    required BuildContext context,
    required String title,
    required String hint,
    required Function(String) onAdd,
  }) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A4F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onAdd(controller.text.trim());
                }
                Get.back();
              },
              child: const Text(
                "Add",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}