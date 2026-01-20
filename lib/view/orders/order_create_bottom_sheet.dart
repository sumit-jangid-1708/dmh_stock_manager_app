import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../model/product_model.dart';
import '../../res/components/widgets/custom_searchable_dropdown.dart';

class OrderCreateBottomSheet extends StatelessWidget {
  OrderCreateBottomSheet({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final OrderController orderController = Get.find<OrderController>();
  final ItemController itemController = Get.find<ItemController>();

  // --- Reusable Input Decoration to Match Theme ---
  InputDecoration _getInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1A1A4F), size: 20),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1A1A4F), width: 1.5),
      ),
    );
  }

  // // ✅ NEW: Open Scanner and Add Scanned Product
  // Future<void> _openScannerAndAddProduct() async {
  //   final ProductModel? scannedProduct = await Get.to(() => const QrScannerWidget());
  //
  //   if (scannedProduct != null) {
  //     orderController.addScannedProduct(scannedProduct);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // SECTION: CUSTOMER INFO
                  _buildSectionTitle(
                    "Order Details",
                    Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 12),

                  // Channel Dropdown with Search
                  CustomSearchableDropdown<ChannelModel>(
                    items: homeController.channels,
                    selectedItem: orderController.selectedChannel,
                    itemAsString: (channel) => channel.name,
                    hintText: "Select Channel",
                    prefixIcon: Icons.store_outlined,
                    enableSearch: true,
                    searchHint: "Search channels...",
                    onChanged: (val) {
                      orderController.selectedChannel.value = val;
                    },
                  ),

                  const SizedBox(height: 12),
                  TextField(
                    controller: orderController.channelOrderId,
                    decoration: _getInputDecoration(
                      "Channel Order ID",
                      Icons.tag,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: orderController.customerNameController,
                    decoration: _getInputDecoration(
                      "Customer Name",
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => TextField(
                    controller: orderController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _getInputDecoration(
                      "Email",
                      Icons.email,
                    ).copyWith(
                      errorText: orderController.emailError.value.isEmpty
                          ? null
                          : orderController.emailError.value,
                    ),
                    onChanged: orderController.validateEmail,
                  )),
                  const SizedBox(height: 12),
                  _buildPhoneField(),
                  const SizedBox(height: 12),
                  TextField(
                    controller: orderController.remarkController,
                    decoration: _getInputDecoration(
                      "Remarks / Notes",
                      Icons.notes,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // SECTION: ITEMS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(
                        "Product Items",
                        Icons.shopping_bag_outlined,
                      ),
                      TextButton.icon(
                        onPressed: orderController.addItemRow,
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        label: const Text("Add Item"),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A4F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildItemsList(),

                  const SizedBox(height: 32),

                  // ACTION BUTTONS
                  _buildFooterButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A4F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.create_new_folder_outlined,
            color: Color(0xFF1A1A4F),
          ),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Order",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Enter transaction and customer info",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      decoration: _getInputDecoration(
        "Phone Number",
        Icons.phone_android_outlined,
      ),
      initialCountryCode: 'IN',
      onChanged: (phone) {
        orderController.countryCode.value = phone.countryCode;
        orderController.phoneNumber.value = phone.number;
      },
    );
  }

  Widget _buildItemsList() {
    return Obx(() {
      return Column(
        children: orderController.items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final product = (item["product"] as Rx<ProductModel?>).value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Product Info Header (SKU & Purchase Price) ---
                      if (product != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              _buildInfoTag(
                                "SKU: ${product.sku ?? 'N/A'}",
                                Icons.qr_code,
                                Colors.blueGrey,
                              ),
                              const SizedBox(height: 2),
                              _buildInfoTag(
                                "Cost: ₹${product.purchasePrice ?? '0'}",
                                Icons.account_balance_wallet,
                                Colors.green,
                              ),
                            ],
                          ),
                        ),

                      // --- Product Dropdown with Search ---
                      CustomSearchableDropdown<ProductModel>(
                        items: itemController.products,
                        selectedItem: item["product"] as Rx<ProductModel?>,
                        itemAsString: (product) =>
                            "${product.name} | ${product.size} | ${product.color}",
                        hintText: "Choose Product",
                        prefixIcon: Icons.inventory_2_outlined,
                        enableSearch: true,
                        searchHint: "Search products...",
                        customItemBuilder: (product) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${product.size} | ${product.color} | SKU: ${product.sku ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        onChanged: (val) {
                          (item["product"] as Rx<ProductModel?>).value = val;
                          if (val == null) return;
                          final priceController =
                              item["purchasePrice"] as TextEditingController?;
                          final skuController =
                              item["skuId"] as TextEditingController?;
                          if (priceController != null) {
                            priceController.text = val.purchasePrice.toString();
                          }
                          if (skuController != null) {
                            skuController.text = val.sku ?? "";
                          }
                        },
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),

                // --- Quantity and Sale Price Inputs ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSmallField(item["quantity"], "Qty", Icons.numbers),
                    const SizedBox(height: 8),
                    _buildSmallField(
                      item["unitPrice"],
                      "Sale Price",
                      Icons.payments_outlined,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () => orderController.removeItemRow(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  // Helper widget to build the SKU and Purchase Price tags
  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => orderController.clearForm(),
            child: const Text("Clear", style: TextStyle(color: Colors.black54)),
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: AppGradientButton(
            onPressed: () {
              orderController.createOrder();
              Get.back();
            },
            height: 50,
            text: "Submit Order",
          ),
        ),
      ],
    );
  }
}
