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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async{
            await stockController.fetchInventoryList();
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          // fixedSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showAddInventorySheet(context);
                        },
                        child: const Text(
                          "Add Inventory",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          "Inventory",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    // if (stockController.isLoading.value) {
                    //   return const Center(child: CircularProgressIndicator());
                    // }
                    return ListView.builder(
                      shrinkWrap: true, // 👈 Important
                      physics:
                          NeverScrollableScrollPhysics(), // 👈 disable inner scroll
                      itemCount: stockController.inventoryList.length,
                      itemBuilder: (context, index) {
                        final item = stockController.inventoryList[index];
                        final product = stockController.getProductById(
                          item.product,
                        );

                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 Left side (Title + Subtitle)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${product?.name ?? "Unknown"} | ${product?.size ?? "-"} | ${product?.color ?? "-"} | ${product?.material ?? "-"}",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Product ID: ${item.product}"),
                                      if (product?.sku != null)
                                        Text(
                                          "SKU: ${product!.sku}",
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),

                                /// 🔹 Right side (Qty + Adjust button)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Qty: ${item.quantity}",
                                      style: TextStyle(
                                        color: item.quantity == 0 ? Colors.red : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (product?.sku != null) {
                                          showAdjustSheet(Get.context!, product!.sku!);
                                        } else {
                                          Get.snackbar("Error", "SKU not available for this product");
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1A1A4F),
                                        minimumSize: const Size(70, 28),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        "Adjust",
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );

                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showAddInventorySheet(BuildContext context) {
  final qtyController = TextEditingController(text: "1");
  int? selectedProduct;

  final itemController = Get.find<ItemController>(); // products list ke liye

  Get.bottomSheet(
    DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Inventory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // Product dropdown
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Select Product",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: itemController.products.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text("${p.name} | ${p.size} | ${p.color}"),
                    );
                  }).toList(),
                  onChanged: (val) => selectedProduct = val,
                ),

                const SizedBox(height: 12),

                // Quantity input
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    final qty = int.tryParse(qtyController.text) ?? 1;
                    if (selectedProduct == null) {
                      Get.snackbar("Error", "Please select a product");
                      return;
                    }

                    Get.find<StockController>().addInventory(
                      productId: selectedProduct!,
                      quantity: qty,
                    );

                    Get.back();
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.45,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Adjust Inventory ($sku)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Delta input
                TextField(
                  controller: deltaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Delta (+ for add, - for reduce)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Reason dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Reason",
                    border: OutlineInputBorder(),
                  ),
                  items: reasons
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => selectedReason = val,
                ),
                const SizedBox(height: 12),

                // Note field
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: "Note",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    final delta = int.tryParse(deltaController.text) ?? 0;
                    if (selectedReason == null) {
                      Get.snackbar("Error", "Please select reason");
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
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
