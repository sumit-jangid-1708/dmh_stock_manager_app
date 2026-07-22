import 'package:dmj_stock_manager/res/app_url/app_url.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient _button.dart';
import 'package:dmj_stock_manager/res/components/widgets/custom_text_field.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/product_models/product_model.dart';
import '../../model/stock_inventory_models/inventory_model.dart';
import '../../view_models/controller/item_controller.dart';

class StockScreen extends StatelessWidget {
  StockScreen({super.key});
  final StockController stockController = Get.put(StockController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 Gradient Header with Filters & Search
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF1A1A4F).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, size: 20, color: Colors.white),
                                onPressed: () => Get.back(),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Inventory",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Manage your stock levels",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            // 🔃 Sorting Menu
                            Obx(() => PopupMenuButton<String>(
                                  icon: Icon(
                                    stockController.sortOrder.value == 'NONE' 
                                        ? Icons.sort 
                                        : Icons.filter_list_alt,
                                    color: Colors.white,
                                  ),
                                  tooltip: "Sort Stock",
                                  onSelected: (value) => stockController.setSortOrder(value),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'NONE',
                                      child: Row(
                                        children: [
                                          Icon(Icons.history, size: 20, color: Colors.grey),
                                          SizedBox(width: 8),
                                          Text('Default Order'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'LOW_TO_HIGH',
                                      child: Row(
                                        children: [
                                          Icon(Icons.trending_up, size: 20, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Low to High'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'HIGH_TO_LOW',
                                      child: Row(
                                        children: [
                                          Icon(Icons.trending_down, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('High to Low'),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => showAddInventorySheet(context),
                              icon: Icon(Icons.add, size: 18),
                              label: Text("Add"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF1A1A4F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 🔍 Workable Search Bar
                        AppTextField(
                          controller: stockController.searchController,
                          hintText: "Search by name or SKU...",
                          prefixIcon: Icons.search,
                          isSearch: true,
                        ),
                      ],
                    ),
                  ),

                  // 📊 Interactive Stats Section (Filters)
                  Obx(() {
                    final totalItems = stockController.inventoryList.length;
                    final lowStock = stockController.inventoryList
                        .where((item) => item.quantity < 10 && item.quantity > 0)
                        .length;
                    final outOfStock = stockController.inventoryList
                        .where((item) => item.quantity == 0)
                        .length;

                    return Container(
                      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          _buildFilterItem(
                            "Total",
                            totalItems.toString(),
                            Icons.inventory_2,
                            'ALL',
                            Colors.blue.shade300,
                          ),
                          _buildFilterItem(
                            "Low Stock",
                            lowStock.toString(),
                            Icons.warning_amber,
                            'LOW',
                            Colors.orange.shade300,
                          ),
                          _buildFilterItem(
                            "Out",
                            outOfStock.toString(),
                            Icons.error_outline,
                            'OUT',
                            Colors.red.shade300,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // 📦 Inventory List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => await stockController.fetchInventoryList(),
                child: Obx(() {
                  if (stockController.isLoading.value && stockController.inventoryList.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final list = stockController.filteredInventory;

                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                          SizedBox(height: 16),
                          Text(
                            stockController.searchQuery.value.isNotEmpty 
                              ? "No results found for '${stockController.searchQuery.value}'"
                              : "No items found for this filter",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final product = stockController.getProductById(item.product);
                      return _buildMinimalInventoryCard(item, product, context);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterItem(String label, String value, IconData icon, String filter, Color activeColor) {
    return Expanded(
      child: Obx(() {
        bool isActive = stockController.selectedFilter.value == filter;
        return GestureDetector(
          onTap: () => stockController.setFilter(filter),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(icon, color: isActive ? activeColor : Colors.white60, size: 22),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white60,
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 3,
                    width: 20,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMinimalInventoryCard(InventoryModel item, ProductModel? product, BuildContext context) {
    final isLowStock = item.quantity < 10 && item.quantity > 0;
    final isOutOfStock = item.quantity == 0;
    Color statusColor = isOutOfStock ? Colors.red : isLowStock ? Colors.orange : Colors.green;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🔝 Top Section: Quantity and Adjust
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Quantity",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      item.quantity.toString(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                AppGradientButton(
                  onPressed: () {
                    if (product?.sku != null) {
                      showAdjustSheet(context, product!.sku);
                    } else {
                      Get.snackbar("Error", "SKU not available");
                    }
                  },
                  icon: Icons.tune,
                  text: "Adjust",
                  height: 40,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade100, thickness: 1),
          ),

          // 🔽 Bottom Section: Product Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (product?.productImageVariants.isNotEmpty ?? false)
                      ? Image.network(
                          AppUrl.mediaUrl(product!.productImageVariants.first),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product?.name ?? "Unknown Product",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isOutOfStock ? "Out" : isLowStock ? "Low" : "In Stock",
                              style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "SKU: ${product?.baseSku ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                      SizedBox(height: 8),
                      // Attributes
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          if (product?.size != null && product!.size.isNotEmpty)
                            _minimalChip(product.size, Colors.blue),
                          if (product?.color != null && product!.color.isNotEmpty)
                            _minimalChip(product.color, Colors.red),
                          if (product?.material != null && product!.material.isNotEmpty)
                            _minimalChip(product.material, Colors.brown),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _minimalChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 20),
      );
}

void showAddInventorySheet(BuildContext context) {
  final qtyController = TextEditingController(text: "1");
  int? selectedProduct;
  final itemController = Get.find<ItemController>();

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.add_box, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Inventory",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Increase stock for a product",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Product Selection
                Text(
                  "Select Product",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.inventory_2,
                        color: Color(0xFF1A1A4F),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: Text("Choose a product"),
                    items: itemController.products.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text(
                          "${p.name} | ${p.size} | ${p.color}",
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => selectedProduct = val,
                  ),
                ),

                SizedBox(height: 20),

                // Quantity Input
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF1A1A4F),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: "Enter quantity",
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
                AppGradientButton(
                  width: double.infinity,
                  height: 50,
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    if (selectedProduct == null) {
                      Get.snackbar(
                        "Error",
                        "Please select a product",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Get.find<StockController>().addInventory(
                      productId: selectedProduct!,
                      quantity: qty,
                    );
                    Get.back();
                  },
                  icon: Icons.check_circle,
                  text: "Add to Inventory",
                ),
              ],
            ),
          );
        },
      ),
    ),
    isScrollControlled: true,
  );
}

void showAdjustSheet(BuildContext context, String sku) {
  final deltaController = TextEditingController(text: "0");
  final noteController = TextEditingController();
  String? selectedReason;
  final reasons = ["ORDER", "PURCHASE", "RETURN", "WPS", "ADJUST", "OTHER"];

  Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Adjust Inventory",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "SKU: $sku",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // Delta Input
                Text(
                  "Adjustment Amount",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: deltaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: "+ to add, - to reduce",
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Reason Selection
                Text(
                  "Reason for Adjustment",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: Color(0xFF1A1A4F),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    hint: Text("Select reason"),
                    items: reasons.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) => selectedReason = val,
                  ),
                ),

                SizedBox(height: 20),

                // Note Field
                Text(
                  "Additional Notes (Optional)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 50),
                        child: Icon(
                          Icons.note_alt_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: "Add any additional details...",
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
                AppGradientButton(
                  onPressed: () {
                    final delta = int.tryParse(deltaController.text) ?? 0;
                    if (selectedReason == null) {
                      Get.snackbar(
                        "Error",
                        "Please select a reason",
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Get.find<StockController>().adjustInventoryStock(
                      sku: sku,
                      delta: delta,
                      reason: selectedReason!,
                      note: noteController.text,
                    );
                    Get.back();
                  },
                  width: double.infinity,
                  height: 50,
                  icon: Icons.check_circle,
                  text: "Confirm Adjustment",
                ),
              ],
            ),
          );
        },
      ),
    ),
    isScrollControlled: true,
  );
}
