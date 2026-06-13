import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'app_gradient _button.dart';

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

  String _getImageUrl(dynamic imageItem) {
    String raw = '';
    if (imageItem is String) raw = imageItem;

    if (raw.isEmpty) return "https://via.placeholder.com/150";
    final resolved = AppUrl.mediaUrl(raw);
    return resolved.isEmpty ? "https://via.placeholder.com/150" : resolved;
  }

  @override
  Widget build(BuildContext context) {
    final itemController = Get.find<ItemController>();
    final imageList = product.productImageVariants;
    final stockController = Get.find<StockController>();

    int inventoryCount = 0;
    final stockModel = stockController.inventoryList.firstWhereOrNull(
      (i) => i.product == product.id,
    );
    inventoryCount = stockModel?.quantity ?? 0;

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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageList.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _showImageDialog(context, imageList),
                          child: Image.network(
                            _getImageUrl(imageList.first),
                            width: 88,
                            height: 108,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 88,
                              height: 108,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          width: 88,
                          height: 108,
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Text("No Image",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                ),

                const SizedBox(width: 12),

                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontSize: 15.5, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      Text(
                        "SKU: ${product.baseSku}",
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 6),

                      // Material + Size & Color
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.material,
                              style: TextStyle(
                                  fontSize: 11.5, color: Colors.grey.shade700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "• ${product.size} • ${product.color}",
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A4F),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // HSN + Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (product.hsnId != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A4F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFF1A1A4F), width: 1),
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
                          Row(
                            children: [
                              AppGradientButton(
                                onPressed: onShare,
                                width: 38,
                                height: 38,
                                icon: FontAwesomeIcons.image,
                              ),
                              const SizedBox(width: 8),
                              AppGradientButton(
                                onPressed: onView,
                                width: 38,
                                height: 38,
                                icon: FontAwesomeIcons.barcode,
                              ),
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

          // Bottom Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.green.shade300, width: 1),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 18, color: Colors.green.shade700),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Current Stock",
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          inventoryCount.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
                AppGradientButton(
                  width: 92,
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

  void _showImageDialog(BuildContext context, List<String> images) {
    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No images available")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: images.length,
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  child: Image.network(
                    _getImageUrl(images[index]),
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
