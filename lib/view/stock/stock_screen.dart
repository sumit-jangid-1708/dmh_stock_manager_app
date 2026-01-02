import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/item_controller.dart';

class StockScreen extends StatelessWidget {
  StockScreen({super.key});
  final StockController stockController = Get.put(StockController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // 🎨 Gradient Header
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
                    child: Row(
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
                                "Inventory Management",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Track and manage stock levels",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => showAddInventorySheet(context),
                          icon: Icon(Icons.add, size: 18),
                          label: Text("Add", style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF1A1A4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 📊 Stats Section
                  Obx(() {
                    final totalItems = stockController.inventoryList.length;
                    final lowStock = stockController.inventoryList
                        .where((item) => item.quantity < 10)
                        .length;
                    final outOfStock = stockController.inventoryList
                        .where((item) => item.quantity == 0)
                        .length;

                    return Container(
                      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem("Total", totalItems.toString(), Icons.inventory_2),
                          _buildDivider(),
                          _buildStatItem("Low Stock", lowStock.toString(), Icons.warning_amber, Colors.orange.shade300),
                          _buildDivider(),
                          _buildStatItem("Out", outOfStock.toString(), Icons.error_outline, Colors.red.shade300),
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
                onRefresh: () async {
                  await stockController.fetchInventoryList();
                },
                child: Obx(() {
                  if (stockController.isLoading.value && stockController.inventoryList.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (stockController.inventoryList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                          SizedBox(height: 16),
                          Text(
                            "No inventory items yet",
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => showAddInventorySheet(context),
                            icon: Icon(Icons.add),
                            label: Text("Add First Item"),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: stockController.inventoryList.length,
                    itemBuilder: (context, index) {
                      final item = stockController.inventoryList[index];
                      final product = stockController.getProductById(item.product);

                      return _buildInventoryCard(item, product, context);
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

  Widget _buildStatItem(String label, String value, IconData icon, [Color? iconColor]) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.white70, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  Widget _buildInventoryCard(dynamic item, dynamic product, BuildContext context) {
    final isLowStock = item.quantity < 10 && item.quantity > 0;
    final isOutOfStock = item.quantity == 0;

    Color statusColor = isOutOfStock
        ? Colors.red
        : isLowStock
        ? Colors.orange
        : Colors.green;

    String statusText = isOutOfStock
        ? "OUT OF STOCK"
        : isLowStock
        ? "LOW STOCK"
        : "IN STOCK";

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock ? Colors.red.shade100 : Colors.grey.shade200,
          width: isOutOfStock ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? "Unknown Product",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (product?.sku != null)
                            Row(
                              children: [
                                Icon(Icons.qr_code, size: 12, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  "SKU: ${product!.sku}",
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor, width: 1),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Attributes Row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (product?.size != null && product!.size.isNotEmpty)
                      _buildAttributeChip(product.size, Icons.straighten, Colors.blue),
                    if (product?.color != null && product!.color.isNotEmpty)
                      _buildAttributeChip(product.color, Icons.palette, Colors.red),
                    if (product?.material != null && product!.material.isNotEmpty)
                      _buildAttributeChip(product.material, Icons.category, Colors.brown),
                  ],
                ),

                SizedBox(height: 12),

                // Quantity & Adjust Section
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Available Quantity",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.quantity.toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (product?.sku != null) {
                            showAdjustSheet(context, product!.sku!);
                          } else {
                            Get.snackbar("Error", "SKU not available");
                          }
                        },
                        icon: Icon(Icons.tune, size: 16),
                        label: Text("Adjust"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A1A4F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
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

  Widget _buildAttributeChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
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
                      prefixIcon: Icon(Icons.inventory_2, color: Color(0xFF1A1A4F)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      prefixIcon: Icon(Icons.shopping_cart, color: Color(0xFF1A1A4F)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: "Enter quantity",
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A1A4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Add to Inventory",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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
  final reasons = ["ORDER", "DAMAGED", "RETURN", "OTHER"];

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
                      prefixIcon: Icon(Icons.add_circle_outline, color: Colors.green),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      prefixIcon: Icon(Icons.info_outline, color: Color(0xFF1A1A4F)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: Text("Select reason"),
                    items: reasons.map((r) {
                      return DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      );
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
                        child: Icon(Icons.note_alt_outlined, color: Colors.grey),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      hintText: "Add any additional details...",
                    ),
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A1A4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Confirm Adjustment",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
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