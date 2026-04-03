// lib/res/components/widgets/edit_item_form_bottom_sheet.dart

import 'dart:io';
import 'package:dmj_stock_manager/model/vendor_model/vendor_model.dart';
import 'package:dmj_stock_manager/model/product_models/product_model.dart';
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

class EditItemFormBottomSheet extends StatefulWidget {
  final ProductModel product;
  const EditItemFormBottomSheet({super.key, required this.product});

  @override
  State<EditItemFormBottomSheet> createState() => _EditItemFormBottomSheetState();
}

class _EditItemFormBottomSheetState extends State<EditItemFormBottomSheet> {
  List<File> _selectedImages = [];

  final Rx<String?> _selectedColor = Rx<String?>(null);
  final Rx<String?> _selectedSize = Rx<String?>(null);
  final Rx<String?> _selectedMaterial = Rx<String?>(null);
  final Rx<String?> _selectedHsnCode = Rx<String?>(null);
  final Rx<VendorModel?> _selectedVendor = Rx<VendorModel?>(null);
  final Rx<dynamic> _selectedHsn = Rx<dynamic>(null);

  // ✅ Size mode
  final RxBool _isMultiLabelSize = false.obs;
  final Rx<String?> _selectedUnit = Rx<String?>(null);
  final TextEditingController _lengthCtrl = TextEditingController();
  final TextEditingController _widthCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();

  int? _selectedHsnId;
  int? _vendorId;

  static const String _baseUrl = "https://traders.testwebs.in";
  static const List<String> _units = ['CM', 'MM', 'INCH', 'M', 'FT'];

  final VendorController vendorController = Get.find<VendorController>();
  final DashboardController dashboardController = Get.find<DashboardController>();
  final ItemController itemController = Get.find<ItemController>();

  @override
  void initState() {
    super.initState();
    itemController.selectedImage.clear();
    itemController.uploadedImagePaths.clear();
    itemController.uploadingIndices.clear();
    _loadExistingData();
  }

  @override
  void dispose() {
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final p = widget.product;

    itemController.productName.value.text = p.name;
    itemController.skuCode.value.text = p.prefixCode ?? '';
    itemController.purchasePrice.value.text = p.unitPurchasePrice.toString();
    itemController.description.value.text = p.description ?? '';
    itemController.weightBefore.value.text = p.weightBefore ?? '';
    itemController.weightAfter.value.text = p.weightAfter ?? '';

    _selectedColor.value = p.color;
    _selectedMaterial.value = p.material;
    _vendorId = p.vendor;

    // Vendor
    final vendor = vendorController.vendors.firstWhereOrNull((v) => v.id == p.vendor);
    if (vendor != null) {
      _selectedVendor.value = vendor;
      dashboardController.setSelectedVendor(vendor.id.toString(), vendor.vendorName ?? "");
    }

    // HSN
    if (p.hsnId != null) {
      final hsn = itemController.hsnList.firstWhereOrNull((h) => h.id == p.hsnId);
      if (hsn != null) { _selectedHsn.value = hsn; _selectedHsnCode.value = hsn.hsnCode; _selectedHsnId = hsn.id; }
    }

    // ✅ Detect size mode from existing data
    final hasMultiLabel = (p.length != null && p.length!.isNotEmpty) ||
        (p.width != null && p.width!.isNotEmpty) ||
        (p.height != null && p.height!.isNotEmpty);

    if (hasMultiLabel) {
      _isMultiLabelSize.value = true;
      _lengthCtrl.text = p.length ?? '';
      _widthCtrl.text = p.width ?? '';
      _heightCtrl.text = p.height ?? '';
      // Match unit
      if (p.unit != null && _units.contains(p.unit!.toUpperCase())) {
        _selectedUnit.value = p.unit!.toUpperCase();
      }
    } else {
      _isMultiLabelSize.value = false;
      _selectedSize.value = p.size.isNotEmpty ? p.size : null;
    }

    // ✅ Existing images
    itemController.setExistingImages(p.productImageVariants);
  }

  String _getImageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '$_baseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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

                  // ── Images ─────────────────────────────────────────
                  _buildSectionTitle("Product Media", Icons.image_outlined),
                  const SizedBox(height: 12),
                  _buildExistingImagesSection(),
                  const SizedBox(height: 12),
                  _buildNewImagePickerSection(),
                  const SizedBox(height: 24),

                  // ── Basic Info ─────────────────────────────────────
                  _buildSectionTitle("Basic Information", Icons.info_outline),
                  const SizedBox(height: 12),

                  CustomSearchableDropdown<VendorModel>(
                    items: vendorController.vendors, selectedItem: _selectedVendor,
                    itemAsString: (vendor) => vendor.vendorName ?? "Unknown",
                    hintText: "Select Vendor*", prefixIcon: Icons.business_outlined,
                    searchHint: "Search vendors...", enabled: false,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: itemController.productName.value, hintText: "Item Name", prefixIcon: Icons.inventory_2_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: itemController.skuCode.value, hintText: "SKU Code", prefixIcon: Icons.qr_code_scanner, enabled: false),
                  const SizedBox(height: 24),

                  // ── Pricing ────────────────────────────────────────
                  _buildSectionTitle("Pricing & Stock", Icons.account_balance_wallet_outlined),
                  const SizedBox(height: 12),
                  AppTextField(controller: itemController.purchasePrice.value, hintText: "Purchase Price", prefixIcon: Icons.payments_outlined),
                  const SizedBox(height: 24),

                  // ── Weight ─────────────────────────────────────────
                  _buildSectionTitle("Weight Information (grams)", Icons.scale_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: AppTextField(controller: itemController.weightBefore.value, hintText: "Weight Before (g)", prefixIcon: Icons.inventory_outlined, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: AppTextField(controller: itemController.weightAfter.value, hintText: "Weight After (g)", prefixIcon: Icons.local_shipping_outlined, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Attributes ─────────────────────────────────────
                  _buildSectionTitle("Attributes & Tax", Icons.style_outlined),
                  const SizedBox(height: 12),

                  _buildSearchableDropdownWithAdd(
                    label: 'Material', items: AppLists.materials, selectedItem: _selectedMaterial, icon: Icons.layers_outlined,
                    onAdd: () => _showAddDialog("Material", (v) => AppLists.addMaterial(v), (v) => _selectedMaterial.value = v),
                  ),
                  const SizedBox(height: 12),

                  _buildSearchableDropdownWithAdd(
                    label: 'Colour', items: AppLists.colors, selectedItem: _selectedColor, icon: Icons.palette_outlined,
                    onAdd: () => _showAddDialog("Color", (v) => AppLists.addColor(v), (v) => _selectedColor.value = v),
                  ),
                  const SizedBox(height: 16),

                  // ── ✅ Size Section ────────────────────────────────
                  _buildSizeSection(),
                  const SizedBox(height: 12),

                  _buildHsnDropdown(),
                  const SizedBox(height: 12),
                  AppTextField(controller: itemController.description.value, hintText: "Description", prefixIcon: Icons.description, maxLines: 3),
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Size Section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.straighten_outlined, size: 18, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text("Size", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            const Spacer(),
            Obx(() => _buildSizeToggle()),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => _isMultiLabelSize.value ? _buildMultiLabelSizeFields() : _buildSingleLabelSizeDropdown()),
      ],
    );
  }

  Widget _buildSizeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleOption("Single Label", !_isMultiLabelSize.value, () {
            _isMultiLabelSize.value = false;
            _selectedUnit.value = null;
            _lengthCtrl.clear();
            _widthCtrl.clear();
            _heightCtrl.clear();
          }),
          _toggleOption("Multi Label", _isMultiLabelSize.value, () {
            _isMultiLabelSize.value = true;
            _selectedSize.value = null;
          }),
        ],
      ),
    );
  }

  Widget _toggleOption(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A1A4F) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSingleLabelSizeDropdown() {
    return _buildSearchableDropdownWithAdd(
      label: 'Size', items: AppLists.sizes, selectedItem: _selectedSize, icon: Icons.straighten_outlined,
      onAdd: () => _showAddDialog("Size", (v) => AppLists.addSize(v), (v) => _selectedSize.value = v),
    );
  }

  Widget _buildMultiLabelSizeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomSearchableDropdown<String>(
                items: _units, selectedItem: _selectedUnit, itemAsString: (u) => u,
                hintText: "Select Unit (CM, MM...)", prefixIcon: Icons.square_foot_outlined, searchHint: "Search unit...",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _lengthCtrl, hintText: "Length", prefixIcon: Icons.swap_horiz, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: AppTextField(controller: _widthCtrl, hintText: "Width", prefixIcon: Icons.swap_vert, keyboardType: TextInputType.number)),
            const SizedBox(width: 8),
            Expanded(child: AppTextField(controller: _heightCtrl, hintText: "Height", prefixIcon: Icons.height, keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() {
          final l = _lengthCtrl.text;
          final w = _widthCtrl.text;
          final h = _heightCtrl.text;
          final u = _selectedUnit.value ?? '';
          if (l.isEmpty && w.isEmpty && h.isEmpty) return const SizedBox.shrink();
          final parts = [l, w, h].where((v) => v.isNotEmpty).join('X');
          return Text("Size: $parts$u", style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic));
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ Existing images grid
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildExistingImagesSection() {
    return Obx(() {
      if (itemController.existingImageUrls.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current Images", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: itemController.existingImageUrls.length,
            itemBuilder: (context, index) {
              final url = _getImageUrl(itemController.existingImageUrls[index]);
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1A1A4F).withOpacity(0.15))),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(url, fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(color: Colors.grey.shade100, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: () => itemController.removeExistingImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.red.shade600, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)]),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4, left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
                      child: Text("${index + 1}", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Text("Tap ✕ to remove an existing image", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
    });
  }

  Widget _buildNewImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add New Images (optional)", style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        MultiImagePickerWidget(onImagesSelected: (files) => setState(() => _selectedImages = files)),
        Obx(() {
          if (itemController.selectedImage.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text("⚠️ Selecting new images will replace ALL existing images", style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontWeight: FontWeight.w500)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 54,
      child: Obx(() {
        final bool busy = itemController.isLoading.value || itemController.isAnyImageUploading;
        return AppGradientButton(
          text: itemController.isAnyImageUploading ? "Uploading images..." : "Update Product",
          isLoading: busy,
          onPressed: busy ? null : _onSubmit,
        );
      }),
    );
  }

  void _onSubmit() {
    final color = _selectedColor.value;
    final material = _selectedMaterial.value;

    if (itemController.productName.value.text.trim().isEmpty) { Get.snackbar("Required Fields", "Please enter product name", backgroundColor: Colors.red, colorText: Colors.white); return; }
    if (itemController.purchasePrice.value.text.trim().isEmpty) { Get.snackbar("Required Fields", "Please enter purchase price", backgroundColor: Colors.red, colorText: Colors.white); return; }
    if (color == null || material == null) { Get.snackbar("Required Fields", "Please select color and material", backgroundColor: Colors.red, colorText: Colors.white); return; }
    if (_vendorId == null) { Get.snackbar("Error", "Vendor information is missing", backgroundColor: Colors.red, colorText: Colors.white); return; }

    if (_isMultiLabelSize.value) {
      if (_lengthCtrl.text.trim().isEmpty || _widthCtrl.text.trim().isEmpty || _heightCtrl.text.trim().isEmpty) {
        Get.snackbar("Required Fields", "Please enter length, width and height", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      if (_selectedUnit.value == null) {
        Get.snackbar("Required Fields", "Please select a unit", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    } else {
      if (_selectedSize.value == null) {
        Get.snackbar("Required Fields", "Please select a size", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    final descriptionText = itemController.description.value.text.trim();

    itemController.editProduct(
      productId: widget.product.id,
      vendorId: _vendorId!,
      prefixCode: widget.product.prefixCode ?? '',
      color: color,
      size: _selectedSize.value ?? '',
      material: material,
      purchasePrice: itemController.purchasePrice.value.text,
      hsnId: _selectedHsnId,
      description: descriptionText.isEmpty ? null : descriptionText,
      isMultiLabelSize: _isMultiLabelSize.value,
      unit: _selectedUnit.value,
      length: _lengthCtrl.text.trim(),
      width: _widthCtrl.text.trim(),
      height: _heightCtrl.text.trim(),
    ).then((_) {
      if (!itemController.isLoading.value && mounted) Navigator.of(context).pop();
    });
  }

  // ── UI Helpers ──────────────────────────────────────────────────────────────

  Widget _buildDragHandle() {
    return Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))));
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A1A4F).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.edit_outlined, color: Color(0xFF1A1A4F))),
        const SizedBox(width: 16),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Edit Product", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Update product details", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ]),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(children: [
      Icon(icon, size: 18, color: Colors.grey.shade700), const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
    ]);
  }

  Widget _buildSearchableDropdownWithAdd({required String label, required List<String> items, required Rx<String?> selectedItem, required IconData icon, required VoidCallback onAdd}) {
    return Row(
      children: [
        Expanded(child: CustomSearchableDropdown<String>(items: items, selectedItem: selectedItem, itemAsString: (item) => item, hintText: "Select $label", prefixIcon: icon, searchHint: "Search $label...")),
        const SizedBox(width: 10),
        Container(decoration: BoxDecoration(color: const Color(0xFF1A1A4F).withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: IconButton(onPressed: onAdd, icon: const Icon(Icons.add, color: Color(0xFF1A1A4F)))),
      ],
    );
  }

  Widget _buildHsnDropdown() {
    return Obx(() {
      final hsnList = itemController.hsnList;
      return Row(
        children: [
          Expanded(child: CustomSearchableDropdown<dynamic>(items: hsnList.toList(), selectedItem: _selectedHsn, itemAsString: (hsn) => hsn.hsnCode ?? "Unknown", hintText: "Select HSN/SAC", prefixIcon: Icons.description, searchHint: "Search HSN codes...",
            onChanged: (selectedHsnItem) { if (selectedHsnItem != null) { _selectedHsn.value = selectedHsnItem; _selectedHsnCode.value = selectedHsnItem.hsnCode; _selectedHsnId = selectedHsnItem.id; } },
          )),
          const SizedBox(width: 10),
          Container(decoration: BoxDecoration(color: const Color(0xFF1A1A4F).withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: IconButton(onPressed: () => _showAddHsnDialog(context), icon: const Icon(Icons.add, color: Color(0xFF1A1A4F)))),
        ],
      );
    });
  }

  void _showAddDialog(String name, Function(String) addToList, Function(String) updateSelected) {
    final controller = TextEditingController();
    Get.defaultDialog(
      backgroundColor: Colors.white, title: "Add $name",
      content: AppTextField(controller: controller, hintText: "Enter $name", prefixIcon: Icons.edit),
      confirm: AppGradientButton(onPressed: () { if (controller.text.isNotEmpty) { addToList(controller.text); updateSelected(controller.text); } Get.back(); }, text: "Add"),
    );
  }

  void _showAddHsnDialog(BuildContext context) {
    final hsnController = TextEditingController();
    final gstController = TextEditingController();
    Get.defaultDialog(
      title: "New HSN Code", backgroundColor: Colors.white, radius: 16,
      content: Column(children: [AppTextField(controller: hsnController, hintText: "HSN Code", prefixIcon: Icons.pin), const SizedBox(height: 10), AppTextField(controller: gstController, hintText: "GST %", prefixIcon: Icons.percent, keyboardType: TextInputType.number)]),
      confirm: Container(
        width: 100, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)]), borderRadius: BorderRadius.circular(10)),
        child: AppGradientButton(text: "Save", onPressed: () async {
          final code = hsnController.text.trim(); final gstText = gstController.text.trim();
          if (code.isEmpty || gstText.isEmpty) { Get.snackbar("Required", "All fields are mandatory", backgroundColor: Colors.red, colorText: Colors.white); return; }
          final gst = double.tryParse(gstText) ?? 0.0;
          await itemController.addHsn(code, gst);
          final newHsn = itemController.hsnList.firstWhereOrNull((e) => e.hsnCode == code);
          if (newHsn != null) { _selectedHsn.value = newHsn; _selectedHsnCode.value = newHsn.hsnCode; _selectedHsnId = newHsn.id; if (context.mounted) Navigator.of(context).pop(); }
        }),
      ),
      cancel: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel", style: TextStyle(color: Color(0xFF1A1A4F)))),
    );
  }
}