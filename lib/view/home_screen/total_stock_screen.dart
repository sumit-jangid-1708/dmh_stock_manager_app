import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../view_models/controller/home_controller.dart';

class TotalStockScreen extends StatelessWidget {
  const TotalStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔙 Back button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Total Stock",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // 🔄 Stock List
              Expanded(
                child: Obx(() {
                  if (homeController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (homeController.stockDetails.isEmpty) {
                    return const Center(child: Text("No stock available"));
                  }

                  return ListView.builder(
                    itemCount: homeController.stockDetails.length,
                    itemBuilder: (context, index) {
                      final stock = homeController.stockDetails[index];
                      return _buildStockCard(
                        name: stock.name ?? "N/A",
                        sku: stock.sku ?? "N/A",
                        size: stock.size ?? "-",
                        price: stock.unitPurchasePrice ?? "0.00",
                        quantity: stock.inventoryQuantity ?? 0,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🟢 Inline widget for Stock Card
  Widget _buildStockCard({
    required String name,
    required String sku,
    required String size,
    required String price,
    required int quantity,
  }) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("SKU: $sku", style: const TextStyle(fontSize: 13)),
            Text("Size: $size", style: const TextStyle(fontSize: 13)),
            Text("Price: ₹$price", style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Available Quantity:",
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(
                  quantity.toString(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: quantity > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
