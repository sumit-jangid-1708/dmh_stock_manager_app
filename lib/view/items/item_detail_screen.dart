import 'package:dmj_stock_manager/model/product_models/product_model.dart';
import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
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

  String _getImageUrl(dynamic imageItem) {
    String raw = '';
    if (imageItem is String) {
      raw = imageItem;
    } else {
      return "https://via.placeholder.com/150";
    }
    if (raw.isEmpty) return "https://via.placeholder.com/150";
    return AppUrl.mediaUrl(raw);
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
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A4F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "SKU: ${product.baseSku}",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Material(
                              color: const Color(0xFF1A1A4F).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: _editSku,
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 16,
                                    color: Color(0xFF1A1A4F),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 💰 Pricing Section
                        _buildSectionHeader("Pricing Details"),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildPriceRow(
                                "Purchase Price",
                                product.unitPurchasePrice,
                                const Color(0xFF1A1A4F),
                                Icons.payments_outlined,
                              ),
                              if (product.wholesalePrice != null) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFF5F5F5),
                                  ),
                                ),
                                _buildPriceRow(
                                  "Wholesale Price",
                                  product.wholesalePrice!,
                                  Colors.blue.shade700,
                                  Icons.storefront_outlined,
                                ),
                              ],
                              if (product.retailerPrice != null) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    height: 1,
                                    color: Color(0xFFF5F5F5),
                                  ),
                                ),
                                _buildPriceRow(
                                  "Retailer Price",
                                  product.retailerPrice!,
                                  Colors.green.shade700,
                                  Icons.shopping_bag_outlined,
                                ),
                              ],
                            ],
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
                              if (hasMultiLabel) ...[
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
                                if (product.size.isNotEmpty)
                                  _buildGridItem(
                                    "Size",
                                    product.size,
                                    Icons.straighten_outlined,
                                  ),
                              ] else ...[
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
                          onTap: () => showBarcodeDialog(
                            context,
                            product.sku,
                            product.name,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1A1A4F).withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                SkuQrWidget(
                                  sku: product.sku,
                                  size: 130,
                                  showLabel: false,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Tap to view or print",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  Future<void> _editSku() async {
    final updated = await Get.dialog<bool>(
      _SkuEditDialog(product: product),
      barrierDismissible: false,
    );
    if (updated != true) return;

    final refreshed = itemController.products.firstWhereOrNull(
      (item) => item.id == product.id,
    );
    if (refreshed != null) {
      Get.off(() => ItemDetailScreen(product: refreshed));
    }
  }

  Widget _buildPriceRow(
    String label,
    double price,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const Spacer(),
        Text(
          "₹${price.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

class _SkuEditDialog extends StatefulWidget {
  const _SkuEditDialog({required this.product});

  final ProductModel product;

  @override
  State<_SkuEditDialog> createState() => _SkuEditDialogState();
}

class _SkuEditDialogState extends State<_SkuEditDialog> {
  final ItemController _controller = Get.find<ItemController>();
  late final TextEditingController _skuController;

  @override
  void initState() {
    super.initState();
    _skuController = TextEditingController(text: widget.product.sku);
  }

  @override
  void dispose() {
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.isUpdatingSku.value) return;
    final updated = await _controller.updateProductSku(
      widget.product.id,
      _skuController.text,
    );
    if (updated && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A1A4F);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Edit Product SKU",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Use a unique code for this product",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Current SKU: ${widget.product.sku}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _skuController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: "New SKU",
                        hintText: "NEW-SKU-001",
                        prefixIcon: const Icon(Icons.tag_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF7F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text("CANCEL"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(
                            () => AppGradientButton(
                              height: 50,
                              text: _controller.isUpdatingSku.value
                                  ? "UPDATING..."
                                  : "UPDATE SKU",
                              onPressed: _controller.isUpdatingSku.value
                                  ? null
                                  : _submit,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
