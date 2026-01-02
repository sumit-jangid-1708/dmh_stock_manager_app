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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: itemController.purchasePrice.value,
                          keyboardType: TextInputType.number,
                          decoration: _getDecoration(
                            "Purchase Price",
                            Icons.payments_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: itemController.lowStockLimit.value,
                          keyboardType: TextInputType.number,
                          decoration: _getDecoration(
                            "Low Stock Limit",
                            Icons.warning_amber_rounded,
                          ),
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
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A4F),
        ),
        onPressed: () async {
          final code = hsnController.text;
          final gst = double.tryParse(gstController.text) ?? 0.0;
          await itemController.addHsn(code, gst);
          final newHsn = itemController.hsnList.lastWhere(
            (e) => e.hsnCode == code,
          );
          setState(() {
            _selectedHsnCode = code;
            _selectedHsnId = newHsn.id;
          });
          Get.back();
        },
        child: const Text("Save", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:dmj_stock_manager/model/hsn_model.dart';
// import 'package:dmj_stock_manager/model/vendor_model.dart';
// import 'package:dmj_stock_manager/res/components/widgets/multi_image_picker_widget.dart';
// import 'package:dmj_stock_manager/utils/app_lists.dart';
// import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
// import 'package:drop_down_list/drop_down_list.dart';
// import 'package:drop_down_list/model/selected_list_item.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddItemFormBottomSheet extends StatefulWidget {
//   const AddItemFormBottomSheet({super.key});
//
//   @override
//   State<AddItemFormBottomSheet> createState() => _AddItemFormBottomSheetState();
// }
//
// class _AddItemFormBottomSheetState extends State<AddItemFormBottomSheet> {
//   List<File> _selectedImages = [];
//   String? _selectedColor;
//   String? _selectedSize;
//   String? _selectedMaterial;
//   String? _selectedHsnCode;
//   int? _selectedHsnId;
//
//   // GetX controllers
//   final VendorController vendorController = Get.find<VendorController>();
//   final DashboardController dashboardController =
//       Get.find<DashboardController>();
//   final ItemController itemController = Get.find<ItemController>();
//
//   // Local selection state for the dropdown UI
//   String? _selectedVendorName;
//   String? _selectedVendorId;
//   List<SelectedListItem<VendorModel>> get _vendorListItems => vendorController
//       .vendors
//       .map((v) => SelectedListItem<VendorModel>(data: v))
//       .toList();
//
//   void _openVendorPicker() {
//     if (vendorController.isLoading.value) return;
//
//     if (vendorController.vendors.isEmpty) {
//       vendorController.getVendors();
//       return;
//     }
//
//     DropDownState(
//       dropDown: DropDown(
//         data: _vendorListItems,
//         onSelected: (selected) {
//           if (selected.isNotEmpty) {
//             final v = selected.first.data;
//             setState(() {
//               _selectedVendorName = v.vendorName;
//               _selectedVendorId = v.id.toString();
//             });
//             dashboardController.setSelectedVendor(
//               _selectedVendorId!,
//               _selectedVendorName!,
//             );
//           }
//         },
//       ),
//     ).showModal(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: 16,
//         right: 16,
//         top: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               MultiImagePickerWidget(
//                 onImagesSelected: (files) {
//                   setState(() {
//                     _selectedImages = files;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),
//
//               _buildVendorDropdown(label: 'Vendor Name*'),
//               _buildTextField(
//                 label: 'Item Name',
//                 hint: 'Enter your Item',
//                 addProductController: itemController.productName.value,
//               ),
//               _buildTextField(
//                 label: 'SKU',
//                 hint: 'Enter your SKU',
//                 addProductController: itemController.skuCode.value,
//               ),
//               _buildTextField(
//                 label: 'Purchase Price',
//                 hint: 'Enter purchase price',
//                 addProductController: itemController.purchasePrice.value,
//               ),
//               _buildTextField(
//                 label: 'Set Low Stock',
//                 hint: 'Enter low stock limit',
//                 addProductController: itemController.lowStockLimit.value,
//               ),
//
//               // Material Row with Add Button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Material',
//                       items: List<String>.from(AppLists.materials),
//                       value: _selectedMaterial,
//                       onChanged: (val) =>
//                           setState(() => _selectedMaterial = val),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: TextButton.icon(
//                       onPressed: () {
//                         _showAddDialog(
//                           context: context,
//                           title: "Add New Material",
//                           hint: "Enter material name",
//                           onAdd: (value) {
//                             AppLists.addMaterial(value);
//                             setState(() => _selectedMaterial = value);
//                           },
//                         );
//                       },
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add"),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Color Row with Add Button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Colour',
//                       items: List<String>.from(AppLists.colors),
//                       value: _selectedColor,
//                       onChanged: (val) => setState(() => _selectedColor = val),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: TextButton.icon(
//                       onPressed: () {
//                         _showAddDialog(
//                           context: context,
//                           title: "Add New Color",
//                           hint: "Enter color name",
//                           onAdd: (value) {
//                             AppLists.addColor(value);
//                             setState(() => _selectedColor = value);
//                           },
//                         );
//                       },
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add"),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // Size Row with Add Button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Size',
//                       items: List<String>.from(AppLists.sizes),
//                       value: _selectedSize,
//                       onChanged: (val) => setState(() => _selectedSize = val),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: TextButton.icon(
//                       onPressed: () {
//                         _showAddDialog(
//                           context: context,
//                           title: "Add New Size",
//                           hint: "Enter size",
//                           onAdd: (value) {
//                             AppLists.addSize(value);
//                             setState(() => _selectedSize = value);
//                           },
//                         );
//                       },
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add"),
//                     ),
//                   ),
//                 ],
//               ),
//
//               // HSN/SAC Row with Add Button
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Expanded(
//                     child: Obx(() {
//                       final hsnList = List<HsnGstModel>.from(itemController.hsnList);
//                       // final hsnList = itemController.hsnList
//                       //     .map((e) => e.hsnCode ?? "")
//                       //     .where((code) => code.isNotEmpty)
//                       //     .toSet()
//                       //     .toList();
//                       return _buildDropdownField(
//                         label: 'HSN/SAC',
//                         items:hsnList.map((e) => e.hsnCode ?? "").toList(),
//
//                         value: _selectedHsnCode,
//                         onChanged: (selectedCode) {
//                           if (selectedCode != null) {
//                             final selectedHsn = hsnList
//                                 .firstWhere(
//                                   (hsn) => hsn.hsnCode == selectedCode,
//                                 );
//                             setState(() {
//                               _selectedHsnCode = selectedCode;
//                               _selectedHsnId = selectedHsn.id; // ← ID स्टोर करो
//                             });
//                           }
//                         },
//                       );
//                     }),
//                   ),
//                   const SizedBox(width: 8),
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: TextButton.icon(
//                       onPressed: () {
//                         _showAddHsnDialog(context);
//                       },
//                       icon: const Icon(Icons.add),
//                       label: const Text("Add"),
//                     ),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A1A4F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () {
//                     final imagesCopy = List<File>.from(_selectedImages);
//                      itemController.addProduct(
//                       _selectedVendorId!,
//                       _selectedColor!,
//                       _selectedSize!,
//                       _selectedMaterial!,
//                       itemController.purchasePrice.value.text,
//                       imagesCopy,
//                       _selectedHsnId.toString(),
//                     );
//
//                     // itemController.clearAddProductForm();
//                     // setState(() {
//                     //   _selectedImages.clear();
//                     //   _selectedColor = null;
//                     //   _selectedSize = null;
//                     //   _selectedMaterial = null;
//                     //   _selectedHsnCode = null;
//                     //   _selectedHsnId = null;
//                     //   _selectedVendorName = null;
//                     //   _selectedVendorId = null;
//                     // });
//                     Get.back();
//                   },
//                   child: const Text(
//                     'Submit',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ------- UI helpers -------
//
//   Widget _buildTextField({
//     required String label,
//     required String hint,
//     TextEditingController? addProductController,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 6),
//         TextField(
//           controller: addProductController,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildDropdownField({
//     required String label,
//     required List<String> items,
//     required String? value,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label),
//         const SizedBox(height: 6),
//         DropdownButtonFormField<String>(
//           value: value,
//           items: items
//               .map((item) => DropdownMenuItem(value: item, child: Text(item)))
//               .toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//           ),
//         ),
//         const SizedBox(height: 12),
//       ],
//     );
//   }
//
//   Widget _buildVendorDropdown({required String label}) {
//     return Obx(() {
//       final isLoading = vendorController.isLoading.value;
//       final hasData = vendorController.vendors.isNotEmpty;
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label),
//           const SizedBox(height: 6),
//           InkWell(
//             onTap: isLoading ? null : _openVendorPicker,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               decoration: BoxDecoration(
//                 color: isLoading ? Colors.grey.shade100 : null,
//                 border: Border.all(width: 1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       _selectedVendorName ??
//                           (isLoading
//                               ? "Loading vendors…"
//                               : hasData
//                               ? "Select Vendor"
//                               : "No vendors found"),
//                       style: TextStyle(
//                         color: _selectedVendorName == null
//                             ? const Color.fromARGB(255, 109, 109, 109)
//                             : Colors.black,
//                       ),
//                     ),
//                   ),
//                   const Icon(Icons.keyboard_arrow_down),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//         ],
//       );
//     });
//   }
//
//   // ✅ Generic dialog for adding Material, Color, or Size
//   void _showAddDialog({
//     required BuildContext context,
//     required String title,
//     required String hint,
//     required Function(String) onAdd,
//   }) {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(title),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: hint,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A1A4F),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () {
//                 if (controller.text.trim().isNotEmpty) {
//                   onAdd(controller.text.trim());
//                 }
//                 Get.back();
//               },
//               child: const Text("Add", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   // ✅ HSN Code Add Dialog (with HSN Code + GST Percentage)
//   void _showAddHsnDialog(BuildContext context) {
//     final TextEditingController hsnController = TextEditingController();
//     final TextEditingController gstController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Add New HSN Code"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: hsnController,
//                 decoration: InputDecoration(
//                   labelText: "HSN Code",
//                   hintText: "Enter HSN code",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: gstController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: "GST Percentage",
//                   hintText: "Enter GST %",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1A1A4F),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onPressed: () async {
//                 final hsnCode = hsnController.text.trim();
//                 final gstText = gstController.text.trim();
//
//                 if (itemController.hsnList.any((e) => e.hsnCode == hsnCode)) {
//                   Get.snackbar("Info", "This HSN code already exists");
//                   return;
//                 }
//
//                 if (hsnCode.isEmpty || gstText.isEmpty) {
//                   Get.snackbar(
//                     "Error",
//                     "Please fill both fields",
//                     snackPosition: SnackPosition.TOP,
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                   );
//                   return;
//                 }
//
//                 final gstPercentage = double.tryParse(gstText);
//                 if (gstPercentage == null) {
//                   Get.snackbar(
//                     "Error",
//                     "Invalid GST percentage",
//                     snackPosition: SnackPosition.TOP,
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                   );
//                   return;
//                 }
//
//                 Get.back(); // Close dialog first
//                 // Call controller method to add HSN
//                 await itemController.addHsn(hsnCode, gstPercentage);
//                 // Set the newly added HSN as selected
//                 final newHsn = itemController.hsnList.lastWhere((e) => e.hsnCode == hsnCode);
//                 setState(() {
//                   _selectedHsnCode = hsnCode;
//                   _selectedHsnId = newHsn.id;
//                 });
//               },
//               child: const Text("Add", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
