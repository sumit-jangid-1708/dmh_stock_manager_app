import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final int count;
  final ProductModel product;
  final VoidCallback onShare;
  final VoidCallback onView;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.count,
    required this.product,
    required this.onShare,
    required this.onView,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final itemController = Get.find<ItemController>();
    final imageList = product.productImageVariants;
    final stockController = Get.find<StockController>();

    // finding stock count
    int? inventoryCount = 0;
    final stockModel = stockController.inventoryList.firstWhereOrNull(
      (i) => i.product == product.id,
    );
    inventoryCount = stockModel?.quantity ?? 0;

    // finding HSN code with the ID
    String hsnDisplay = "N/A";
    if (product.hsnId != null) {
      final hsnModel = itemController.hsnList.firstWhereOrNull(
        (h) => h.id == product.hsnId,
      );
      hsnDisplay = hsnModel?.hsnCode ?? "HSN ID: ${product.hsnId}";
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Main Card Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageList.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _showImageDialog(context, imageList),
                          child: Image.network(
                            _getImageUrl(imageList.first),
                            width: 90,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 90,
                              height: 110,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 90,
                          height: 110,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Text(
                            "No Image",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                ),

                const SizedBox(width: 14),

                // 📝 Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // SKU
                      Text(
                        "SKU: ${product.sku}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Material | Size | Color
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.material,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            " • ${product.size} • ${product.color}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // HSN + Action Buttons (Proper Spacing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // HSN Chip
                          if (product.hsnId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A4F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF1A1A4F),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                hsnDisplay,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A4F),
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          // Action Buttons (Share & Barcode)
                          Row(
                            children: [
                              AppGradientButton(
                                onPressed: onShare,
                                width: 40,
                                height: 40,
                                icon: FontAwesomeIcons.image,
                              ),
                              const SizedBox(width: 10),
                              AppGradientButton(
                                onPressed: onView,
                                width: 40,
                                height: 40,
                                icon: FontAwesomeIcons.barcode,
                              ),
                              // // _buildActionButton(
                              // //   icon: FontAwesomeIcons.image,
                              // //   onTap: onShare,
                              // // ),
                              //
                              // _buildActionButton(
                              //   icon: FontAwesomeIcons.barcode,
                              //   onTap: onView,
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ NEW: Bottom Section with Stock & ADD Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current Stock Display
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Stock",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          inventoryCount.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ADD Button
                AppGradientButton(
                  width: 90,
                  height: 40,
                  text: "Add",
                  onPressed: onAdd ?? () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Functions
  String _getImageUrl(dynamic imageItem) {
    if (imageItem is String) {
      return "https://traders.testwebs.in$imageItem";
    } else if (imageItem is Map<String, dynamic> &&
        imageItem.containsKey('image')) {
      return "https://traders.testwebs.in${imageItem['image']}";
    }
    return "https://via.placeholder.com/150"; // Fallback
  }

  // Widget _buildActionButton({
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(10),
  //     child: Container(
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF1A1A4F),
  //         borderRadius: BorderRadius.circular(10),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 4,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: FaIcon(icon, size: 16, color: Colors.white),
  //     ),
  //   );
  // }

  void _showImageDialog(BuildContext context, List<dynamic> images) {
    final validImages = images
        .where(
          (item) =>
              item is String || (item is Map && item.containsKey('image')),
        )
        .toList();

    if (validImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No images available")));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: validImages.length,
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  child: Image.network(
                    _getImageUrl(validImages[index]),
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.error, color: Colors.white),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
