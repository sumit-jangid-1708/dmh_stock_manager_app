import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/components/widgets/custom_text_field.dart';

class ShippingScreen extends StatelessWidget {
  ShippingScreen({super.key});
  final TextEditingController searchController = TextEditingController();

  // Dummy status list for filters
  final List<String> categories = ["All", "Pending", "Shipped", "Delivered"];
  final RxString selectedCategory = "All".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column( // SingleChildScrollView se hta kar Column kiya taaki list manage ho sake
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () => Get.back(),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Shipping",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "See shipping orders here",
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: searchController,
                    hintText: "Search products...",
                    prefixIcon: Icons.search,
                    isSearch: true,
                    onSuffixTap: () {},
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),

            // 1. Filter Chips Section
            const SizedBox(height: 10),
            _buildFilterChips(),

            // 2. Shipping Orders List
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5, // Dummy count
                itemBuilder: (context, index) {
                  return _buildShippingCard(
                    orderId: "#ORD1234",
                    customer: "Rajesh Kumar",
                    items: "3",
                    date: "24/3/2024",
                    amount: "6,497",
                    status: index == 0 ? "Pending" : "Delivered",
                    showWarning: index == 2, // Example warning on 3rd card
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            bool isSelected = selectedCategory.value == categories[index];
            return GestureDetector(
              onTap: () => selectedCategory.value = categories[index],
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2E2E8A) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade400,
                  ),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildShippingCard({
    required String orderId,
    required String customer,
    required String items,
    required String date,
    required String amount,
    required String status,
    bool showWarning = false,
  }) {
    Color statusColor = status == "Pending" ? Colors.amber.shade100 : Colors.green.shade100;
    Color textColor = status == "Pending" ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(customer, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardInfoItem("Items", items),
              _cardInfoItem("Ship. Date", date),
              _cardInfoItem("Exp. Delivery", date),
              _cardInfoItem("Amount", "₹$amount"),
            ],
          ),
          if (showWarning) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Low Stock Warning: External SSD Only 1 item left",
                      style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 30),
          const Text("Notes:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const Text("\"Handle with care - electronics\"", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _cardInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}