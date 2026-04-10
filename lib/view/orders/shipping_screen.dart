import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../model/order_models/order_with_shipment_model.dart';
import '../../model/order_models/shipment_model.dart';
import '../../res/components/widgets/custom_text_field.dart';
import '../../view_models/controller/order_controller.dart';

class ShippingScreen extends StatelessWidget {
  ShippingScreen({super.key});
  final TextEditingController searchController = TextEditingController();
  final OrderController controller = Get.find<OrderController>();

  final List<String> categories = ["All", "Pending", "Shipped", "Delivered"];
  final RxString selectedCategory = "All".obs;
  final RxString searchQuery = "".obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "See shipping orders here",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ── Refresh Button ──
                      IconButton(
                        onPressed: () => controller.getOrdersWithShipments(),
                        icon: const Icon(Icons.refresh_rounded),
                        tooltip: "Refresh",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: searchController,
                    hintText: "Search by order ID or customer...",
                    prefixIcon: Icons.search,
                    isSearch: true,
                    onSuffixTap: () {
                      searchController.clear();
                      searchQuery.value = "";
                    },
                    onChanged: (value) => searchQuery.value = value,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            _buildFilterChips(),
            const SizedBox(height: 15),

            // ── List ──
            // shipping_screen.dart — Expanded ke andar ye replace karo
            Expanded(
              child: Obx(() {
                // ✅ Explicitly dono observe karo pehle line mein hi
                final query = searchQuery.value;
                final category = selectedCategory.value;
                final allOrders = controller.ordersWithShipments.toList();

                if (controller.isLoadingShipmentsList.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (allOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No Shipments Found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => controller.getOrdersWithShipments(),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  );
                }

                final filtered = allOrders.where((order) {
                  final matchesSearch =
                      query.isEmpty ||
                      order.customerName.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      order.orderId.toString().contains(query);

                  final matchesCategory =
                      category == "All" ||
                      (category == "Shipped" && order.shipments.isNotEmpty) ||
                      (category == "Pending" && order.shipments.isEmpty);

                  return matchesSearch && matchesCategory;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      "No results for \"$query\"",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.getOrdersWithShipments(),
                  color: const Color(0xFF2E2E8A),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildOrderShipmentBlock(filtered[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── One order can have multiple shipments — show each separately ──
  Widget _buildOrderShipmentBlock(OrderWithShipmentModel order) {
    if (order.shipments.isEmpty) {
      return _buildShippingCard(
        orderId: "#ORD${order.orderId}",
        customer: order.customerName,
        totalAmount: order.totalAmount,
        shipment: null,
      );
    }

    return Column(
      children: order.shipments
          .map(
            (shipment) => _buildShippingCard(
              orderId: "#ORD${order.orderId}",
              customer: order.customerName,
              totalAmount: order.totalAmount,
              shipment: shipment,
            ),
          )
          .toList(),
    );
  }

  Widget _buildShippingCard({
    required String orderId,
    required String customer,
    required double totalAmount,
    required ShipmentModel? shipment,
  }) {
    // ── Derive display values from ShipmentModel ──
    final trackingId = (shipment?.trackingId.isNotEmpty ?? false)
        ? shipment!.trackingId
        : "—";
    final shippingDate = shipment?.shippingDate ?? "—";
    final notes = shipment?.notes ?? "";
    final shippingExpense =
        double.tryParse(shipment?.shippingExpense ?? "0") ?? 0.0;
    final otherExpense = double.tryParse(shipment?.otherExpense ?? "0") ?? 0.0;
    final totalExpense = shippingExpense + otherExpense;

    // ── Status chip (extend when API provides status) ──
    const String status = "Shipped";
    const Color statusBg = Color(0xFFE8F5E9);
    const Color statusText = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    orderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customer,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  status,
                  style: TextStyle(
                    color: statusText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // ── Info Grid ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardInfoItem("Tracking ID", trackingId),
              _cardInfoItem("Ship Date", shippingDate),
              _cardInfoItem("Amount", "₹${totalAmount.toStringAsFixed(0)}"),
              _cardInfoItem("Expense", "₹${totalExpense.toStringAsFixed(0)}"),
            ],
          ),

          // ── Tracking URL ──
          if (shipment?.trackingUrl.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.link_rounded, size: 14, color: Colors.blue.shade400),
                const SizedBox(width: 6),

                /// URL Text
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: shipment!.trackingUrl ?? ""),
                      );

                      Get.snackbar(
                        "Copied",
                        "Tracking URL copied",
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: Text(
                      shipment!.trackingUrl ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                /// Copy Icon Button
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: shipment!.trackingUrl ?? ""),
                    );

                    Get.snackbar(
                      "Copied",
                      "Tracking URL copied",
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 2),
                    );
                  },
                ),
              ],
            ),
          ],

          // ── Notes ──
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.note_outlined,
                  size: 14,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notes,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = selectedCategory.value == categories[index];
            return GestureDetector(
              onTap: () => selectedCategory.value = categories[index],
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2E2E8A) : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.grey.shade400,
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

  Widget _cardInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
