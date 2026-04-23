import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view/items/items_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../res/components/barcode_dialog.dart';
import '../../res/components/sku_qr_widget.dart';
import '../../res/components/widgets/iamge_share_dialog.dart';
import '../../view_models/services/other_services/product_share_service.dart';

class ItemDetailScreen extends StatelessWidget {
  final ProductModel product;

  ItemDetailScreen({super.key, required this.product});

  final ItemController itemController = Get.find<ItemController>();
  final StockController stockController = Get.find<StockController>();
  final PageController _pageController = PageController();

  static const String _baseUrl = "https://traders.testwebs.in";

  String _getImageUrl(dynamic imageItem) {
    String raw = '';
    if (imageItem is String) {
      raw = imageItem;
    } else {
      return "https://via.placeholder.com/150";
    }
    if (raw.isEmpty) return "https://via.placeholder.com/150";
    if (raw.startsWith('http')) return raw;
    return '$_baseUrl$raw';
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final imageList = product.productImageVariants.toList();

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

    // ✅ Detect if this product has multi-label size
    final bool hasMultiLabel =
        (product.length != null && product.length!.isNotEmpty) ||
        (product.width != null && product.width!.isNotEmpty) ||
        (product.height != null && product.height!.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A4F),
            size: 20,
          ),
        ),
        title: const Text(
          "Product Details",
          style: TextStyle(
            color: Color(0xFF1A1A4F),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── IMAGE SECTION ─────────────────────────────────────────
                  Stack(
                    children: [
                      Container(
                        height: width * 0.9,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: imageList.isEmpty ? 1 : imageList.length,
                            itemBuilder: (_, index) {
                              if (imageList.isEmpty) {
                                return Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                );
                              }
                              return InteractiveViewer(
                                child: Image.network(
                                  _getImageUrl(imageList[index]),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Stock Badge
                      Positioned(
                        top: 15,
                        left: 35,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A4F),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4),
                            ],
                          ),
                          child: Text(
                            "In Stock: $inventoryCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Share Button
                      Positioned(
                        top: 15,
                        right: 35,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          child: IconButton(
                            icon: const Icon(
                              Icons.share_rounded,
                              color: Color(0xFF1A1A4F),
                              size: 20,
                            ),
                            onPressed: () =>
                                ProductShareService.shareProductsAsWhatsappCatalogue(
                                  context,
                                  [product],
                                  () {},
                                ),
                          ),
                        ),
                      ),

                      if (imageList.length > 1)
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _pageController,
                              count: imageList.length,
                              effect: const ExpandingDotsEffect(
                                dotWidth: 8,
                                dotHeight: 8,
                                activeDotColor: Color(0xFF1A1A4F),
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── PRODUCT INFO ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A4F),
                                ),
                              ),
                            ),
                            Text(
                              "₹${product.unitPurchasePrice.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A1A4F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SKU: ${product.baseSku}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _buildSectionHeader("Technical Specs"),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Wrap(
                            runSpacing: 20,
                            children: [
                              _buildGridItem(
                                "Material",
                                product.material,
                                Icons.layers_outlined,
                              ),

                              // ✅ Size — single or multi label
                              if (hasMultiLabel) ...[
                                // Multi-label: show dimensions separately
                                if (product.length != null &&
                                    product.length!.isNotEmpty)
                                  _buildGridItem(
                                    "Length",
                                    "${product.length}${product.unit ?? ''}",
                                    Icons.swap_horiz,
                                  ),
                                if (product.width != null &&
                                    product.width!.isNotEmpty)
                                  _buildGridItem(
                                    "Width",
                                    "${product.width}${product.unit ?? ''}",
                                    Icons.swap_vert,
                                  ),
                                if (product.height != null &&
                                    product.height!.isNotEmpty)
                                  _buildGridItem(
                                    "Height",
                                    "${product.height}${product.unit ?? ''}",
                                    Icons.height,
                                  ),
                                if (product.unit != null &&
                                    product.unit!.isNotEmpty)
                                  _buildGridItem(
                                    "Unit",
                                    product.unit!,
                                    Icons.square_foot_outlined,
                                  ),
                                // Also show computed size string
                                if (product.size.isNotEmpty)
                                  _buildGridItem(
                                    "Size",
                                    product.size,
                                    Icons.straighten_outlined,
                                  ),
                              ] else ...[
                                // Single label
                                _buildGridItem(
                                  "Size",
                                  product.size,
                                  Icons.straighten_outlined,
                                ),
                              ],

                              _buildGridItem(
                                "Color",
                                product.color,
                                Icons.palette_outlined,
                              ),
                              _buildGridItem(
                                "HSN Code",
                                hsnDisplay,
                                Icons.description_outlined,
                              ),
                              _buildGridItem(
                                "Serial",
                                product.serial?.toString() ?? "N/A",
                                Icons.tag,
                              ),

                              if (product.weightBefore != null &&
                                  product.weightBefore!.isNotEmpty)
                                _buildGridItem(
                                  "Weight Before Packaging",
                                  "${product.weightBefore}g",
                                  Icons.inventory_outlined,
                                ),
                              if (product.weightAfter != null &&
                                  product.weightAfter!.isNotEmpty)
                                _buildGridItem(
                                  "Weight After Packaging",
                                  "${product.weightAfter}g",
                                  Icons.local_shipping_outlined,
                                ),
                            ],
                          ),
                        ),

                        if (product.description != null &&
                            product.description!.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildSectionHeader("Description"),
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        _buildSectionHeader("Identification"),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: () => showBarcodeDialog(context, product.id, product.sku, product.barcodeImage),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF1A1A4F).withOpacity(0.1)),
                            ),
                            child: Column(
                              children: [
                                // ✅ QR from SKU — crisp, no network
                                SkuQrWidget(
                                  sku: product.sku,
                                  size: 130,
                                  showLabel: false,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Tap to view or print",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () => showBarcodeDialog(
                        //     context,
                        //     product.id,
                        //     product.barcode,
                        //     product.barcodeImage,
                        //   ),
                        //   child: Container(
                        //     width: double.infinity,
                        //     padding: const EdgeInsets.all(20),
                        //     decoration: BoxDecoration(
                        //       color: Colors.white,
                        //       borderRadius: BorderRadius.circular(20),
                        //       border: Border.all(
                        //         color: const Color(0xFF1A1A4F).withOpacity(0.1),
                        //       ),
                        //     ),
                        //     child: Column(
                        //       children: [
                        //         Image.network(
                        //           product.barcodeImage.startsWith('http')
                        //               ? product.barcodeImage
                        //               : '$_baseUrl${product.barcodeImage}',
                        //           height: 60,
                        //           errorBuilder: (_, __, ___) => const Icon(
                        //             Icons.barcode_reader,
                        //             size: 40,
                        //             color: Colors.grey,
                        //           ),
                        //         ),
                        //         const SizedBox(height: 10),
                        //         const Text(
                        //           "Tap to view or print barcode",
                        //           style: TextStyle(
                        //             color: Colors.grey,
                        //             fontSize: 12,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── STICKY ACTION BUTTON ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: AppGradientButton(
              onPressed: () => handleInventoryAction(product),
              icon: Icons.add_rounded,
              text: "ADD TO INVENTORY",
              width: double.infinity,
              height: 55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A4F),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGridItem(String label, String value, IconData icon) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo.shade300),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
