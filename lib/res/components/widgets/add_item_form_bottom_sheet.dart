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
  String? _selectedVendorId; // keep as string for form payloads
  List<SelectedListItem<VendorModel>> get _vendorListItems => vendorController
      .vendors
      .map((v) => SelectedListItem<VendorModel>(data: v)) // ⬅️ pass full object
      .toList();

  void _openVendorPicker() {
    if (vendorController.isLoading.value) return;

    if (vendorController.vendors.isEmpty) {
      // Optionally fetch if empty
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
        bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard safe area
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // For bottom sheet
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

              // 🔽 Vendor dropdown with search
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
                addProductController: itemController.purchasePrice.value, // 👈 new controller
              ),
              _buildTextField(
                label: 'Set Low Stock',
                hint: 'Enter low stock limit',
                addProductController: itemController.lowStockLimit.value,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Expanded(child: _buildDropdownField(label: 'Category')),
                  // const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Material',
                      items: AppLists.materials,
                      value: _selectedMaterial,
                      onChanged: (val) => setState(() => _selectedMaterial = val),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _showAddMaterialDialog(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Material"),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Colour',
                      items: AppLists.colors,
                      value: _selectedColor,
                      onChanged: (val) => setState(() => _selectedColor = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdownField(
                      label: 'Size',
                      items: AppLists.sizes,
                      value: _selectedSize,
                      onChanged: (val) => setState(() => _selectedSize = val),
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
                      itemController.purchasePrice.value.text,  // ⬅️ pass purchase price
                      _selectedImages, // ⬅️ pass selected images
                      itemController.hsnCode.value.text,
                    );
                    // Example: use dashboardController.selectedVendorId.value
                    // in your API payload
                    // print('Submitting with vendor: ${dashboardController.selectedVendorId.value}');
                    Get.back(); // Close bottom sheet
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
      // live react to loading / data from VendorController
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
                // border: Border.all(color: Colors.grey),
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

  void _showAddMaterialDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Material"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter material name",
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
                    )
                ),
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    AppLists.addMaterial(controller.text.trim()); // ✅ save to storage
                    // refresh UI by forcing rebuild
                    _selectedMaterial = controller.text.trim();
                    (context as Element).markNeedsBuild(); // simple trick for refresh
                  }
                  Get.back();
                },
                child: const Text("Add", style: TextStyle(color: Colors.white,),)
            ),
          ],
        );
      },
    );
  }
}

//
// import 'dart:io';
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
//   File? _selectedImage;
//   String? _selectedColor;
//   String? _selectedSize;
//   String? _selectedMaterial;
//
//   // GetX controllers
//   final VendorController vendorController = Get.find<VendorController>();
//   final DashboardController dashboardController =
//       Get.find<DashboardController>();
//   final ItemController itemController = Get.find<ItemController>();
//
//   // Local selection state for the dropdown UI
//   String? _selectedVendorName;
//   String? _selectedVendorId; // keep as string for form payloads
//
//   // Future<void> _pickImage() async {
//   //   final ImagePicker picker = ImagePicker();
//   //   final XFile? pickedFile = await picker.pickImage(
//   //     source: ImageSource.gallery,
//   //   );
//   //
//   //   if (pickedFile != null) {
//   //     setState(() {
//   //       _selectedImage = File(pickedFile.path);
//   //     });
//   //   }
//   // }
//
//   // Map vendors -> SelectedListItem (most common API of drop_down_list)
//   // ⬇️ Map vendors -> SelectedListItem<VendorModel> (v2 API uses only `data`)
//   List<SelectedListItem<VendorModel>> get _vendorListItems => vendorController
//       .vendors
//       .map((v) => SelectedListItem<VendorModel>(data: v)) // ⬅️ pass full object
//       .toList();
//
//   void _openVendorPicker() {
//     if (vendorController.isLoading.value) return;
//
//     if (vendorController.vendors.isEmpty) {
//       // Optionally fetch if empty
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
//         bottom: MediaQuery.of(context).viewInsets.bottom, // Keyboard safe area
//       ),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // For bottom sheet
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Center(
//               //   child: Stack(
//               //     children: [
//               //       // Rectangular container for image
//               //       Container(
//               //         width: double.infinity,
//               //         height: 120,
//               //         decoration: BoxDecoration(
//               //           color: const Color(0xFFECEBFC),
//               //           borderRadius: BorderRadius.circular(8), // rectangular with smooth corners
//               //           image: _selectedImage != null
//               //               ? DecorationImage(
//               //                   image: FileImage(_selectedImage!),
//               //                   fit: BoxFit.cover,
//               //                 )
//               //               : null,
//               //         ),
//               //         child: _selectedImage == null
//               //             ? const Icon(
//               //                 Icons.image,
//               //                 size: 40,
//               //                 color: Colors.grey,
//               //               )
//               //             : null,
//               //       ),
//               //       // Button at top-left
//               //       Positioned(
//               //         top: 4,
//               //         left: 4,
//               //         child: ElevatedButton(
//               //           onPressed: _pickImage,
//               //           style: ElevatedButton.styleFrom(
//               //             backgroundColor: Colors.white,
//               //             shape: RoundedRectangleBorder(
//               //               borderRadius: BorderRadius.circular(
//               //                 6,
//               //               ), // square shape
//               //             ),
//               //             elevation: 1,
//               //             padding: const EdgeInsets.all(6),
//               //           ),
//               //           child: const Icon(
//               //             Icons.add_a_photo_outlined,
//               //             size: 16,
//               //             color: Colors.black54,
//               //           ),
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               MultiImagePickerWidget(),
//               const SizedBox(height: 20),
//
//               // 🔽 Vendor dropdown with search
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
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//                   // Expanded(child: _buildDropdownField(label: 'Category')),
//                   // const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Material',
//                       items: AppLists.materials,
//                       value: _selectedMaterial,
//                       onChanged: (val) => setState(() => _selectedMaterial = val),
//                     ),
//                   ),
//                   TextButton.icon(
//                     onPressed: () {
//                       _showAddMaterialDialog(context);
//                     },
//                     icon: const Icon(Icons.add),
//                     label: const Text("Add Material"),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Colour',
//                       items: AppLists.colors,
//                       value: _selectedColor,
//                       onChanged: (val) => setState(() => _selectedColor = val),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildDropdownField(
//                       label: 'Size',
//                       items: AppLists.sizes,
//                       value: _selectedSize,
//                       onChanged: (val) => setState(() => _selectedSize = val),
//                     ),
//                   ),
//                   // Row(
//                   //   children: [
//                   //     Expanded(
//                   //       child: _buildDropdownField(
//                   //         label: 'Material',
//                   //         items: AppLists.materials,
//                   //         value: _selectedMaterial,
//                   //         onChanged: (val) =>
//                   //             setState(() => _selectedMaterial = val),
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                 ],
//               ),
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
//                     itemController.addProduct(
//                       _selectedVendorId!,
//                       _selectedColor!,
//                       _selectedSize!,
//                       _selectedMaterial!,
//                     );
//                     // Example: use dashboardController.selectedVendorId.value
//                     // in your API payload
//                     // print('Submitting with vendor: ${dashboardController.selectedVendorId.value}');
//                     Get.back(); // Close bottom sheet
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
//       // live react to loading / data from VendorController
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
//                 // border: Border.all(color: Colors.grey),
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
//   void _showAddMaterialDialog(BuildContext context) {
//     final TextEditingController controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Add New Material"),
//           content: TextField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintText: "Enter material name",
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text("Cancel"),
//             ),
//             ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF1A1A4F),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     )
//                 ),
//                 onPressed: () {
//                   if (controller.text.trim().isNotEmpty) {
//                     AppLists.addMaterial(controller.text.trim()); // ✅ save to storage
//                     // refresh UI by forcing rebuild
//                     _selectedMaterial = controller.text.trim();
//                     (context as Element).markNeedsBuild(); // simple trick for refresh
//                   }
//                   Get.back();
//                 },
//                 child: const Text("Add", style: TextStyle(color: Colors.white,),)
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
//
