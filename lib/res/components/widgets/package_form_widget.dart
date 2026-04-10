// lib/res/components/widgets/pack_order_bottom_sheet.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dmj_stock_manager/res/components/widgets/multi_image_picker_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';

import 'app_gradient _button.dart';

class PackOrderBottomSheet extends StatelessWidget {
  final int orderId;
  final VoidCallback? onPackageSaved;

  final _heightCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _isLoading = false.obs;
  final _selectedImages = <File>[].obs;

  PackOrderBottomSheet({
    super.key,
    required this.orderId,
    this.onPackageSaved,
  });

  static void show(BuildContext context, {required int orderId, VoidCallback? onPackageSaved}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PackOrderBottomSheet(orderId: orderId, onPackageSaved: onPackageSaved),
    );
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _isLoading.value = true;

    // ✅ Apna API call yahan lagao:
    // await orderController.savePackageDetails(
    //   orderId: orderId,
    //   height: double.parse(_heightCtrl.text),
    //   width: double.parse(_widthCtrl.text),
    //   length: double.parse(_lengthCtrl.text),
    //   weight: double.parse(_weightCtrl.text),
    //   images: _selectedImages,
    // );

    _isLoading.value = false;
    Get.back();
    onPackageSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ── Handle ──────────────────────────
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Header ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A4F).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1A1A4F), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pack the Order",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                          ),
                          Text("Order #$orderId",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),

                // ── Form ────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Dimensions ──────────────
                        _sectionTitle(Icons.straighten, "Dimensions"),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _heightCtrl,
                                hintText: "0.0",
                                labelText: "Height (cm)",
                                prefixIcon: Icons.height,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _widthCtrl,
                                hintText: "0.0",
                                labelText: "Width (cm)",
                                prefixIcon: Icons.width_normal,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _lengthCtrl,
                                hintText: "0.0",
                                labelText: "Length (cm)",
                                prefixIcon: Icons.swap_horiz,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppTextField(
                                controller: _weightCtrl,
                                hintText: "0.0",
                                labelText: "Weight (kg)",
                                prefixIcon: Icons.monitor_weight_outlined,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) => v == null || v.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Images ──────────────────
                        _sectionTitle(Icons.add_photo_alternate_outlined, "Product Images"),
                        const SizedBox(height: 12),

                        MultiImagePickerWidget(
                          onImagesSelected: (images) => _selectedImages.value = images,
                        ),

                        const SizedBox(height: 24),

                        // ── Save Button ─────────────
                        Obx(() => AppGradientButton(
                          text: "Save Package",
                          icon: Icons.save_alt_rounded,
                          onPressed: _handleSave,
                          isLoading: _isLoading.value,
                          width: double.infinity,
                          height: 52,
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A1A4F)),
        const SizedBox(width: 8),
        Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A4F)),
        ),
      ],
    );
  }
}