import 'package:dmj_stock_manager/model/channel_model.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/item_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../model/product_model.dart';

class OrderCreateBottomSheet extends StatelessWidget {
  OrderCreateBottomSheet({super.key});

  final HomeController homeController = Get.find<HomeController>();
  final OrderController orderController = Get.find<OrderController>();
  final ItemController itemController = Get.find<ItemController>();

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) itemAsString,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text("Select $label"),
              isExpanded: true,
              items: items.map((e) {
                return DropdownMenuItem<T>(
                  value: e,
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          itemAsString(e),
                          // maxLines: null,
                          // overflow: TextOverflow.visible,
                          // softWrap: true,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        // controller: scrollController,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Order",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Channel dropdown
            Obx(() {
              return _buildDropdown<ChannelModel>(
                label: "Channel",
                items: homeController.channels,
                value: orderController.selectedChannel.value,
                itemAsString: (channel) => channel.name,
                onChanged: (val) => orderController.selectedChannel.value = val,
              );
            }),

            TextField(
              controller: orderController.channelOrderId,
              decoration: InputDecoration(
                hintText: "Channel Order Id",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Customer name
            TextField(
              controller: orderController.customerNameController,
              decoration: InputDecoration(
                hintText: "Customer Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            IntlPhoneField(
              decoration: InputDecoration(
                hintText: "Phone number",
                // filled: true,
                // fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              initialCountryCode: 'IN',
              onChanged: (phone) {
                orderController.countryCode.value = phone.countryCode;
                orderController.phoneNumber.value = phone.number;
              },
            ),
            const SizedBox(height: 12),
            // Remarks
            TextField(
              controller: orderController.remarkController,
              decoration: InputDecoration(
                hintText: "Remarks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Items",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Items List
            Obx(() {
              return Column(
                children: orderController.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Dropdown
                        // Product Dropdown + SKU Text
                        Obx(() {
                          final product =
                              (item["product"] as Rx<ProductModel?>).value;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show SKU text if product is selected
                              if (product != null) ...[
                                Text(
                                  "SKU: ${product.sku ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],

                              _buildDropdown<ProductModel>(
                                label: "Product",
                                items: itemController.products,
                                value: product,
                                itemAsString: (p) =>
                                    "${p.name} - ${p.size} - ${p.color} - ${p.material}",
                                onChanged: (val) {
                                  (item["product"] as Rx<ProductModel?>).value =
                                      val;
                                  if (val != null) {
                                    item["purchasePrice"] =
                                        TextEditingController(
                                          text:
                                              val.purchasePrice?.toString() ??
                                              "",
                                        );
                                    item["skuId"] = TextEditingController(
                                      text: val.sku ?? "",
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 8),

                        // SKU + Purchase Price Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: item["purchasePrice"],
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: "Purchase Price",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: item["quantity"],
                                decoration: InputDecoration(
                                  labelText: "Qty",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: item["unitPrice"],
                                decoration: InputDecoration(
                                  labelText: "Sale Price",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A4F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  orderController.removeItemRow(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: orderController.addItemRow,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add Item",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      orderController.clearForm();
                    },
                    child: const Text(
                      "Clear Form",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    orderController.createOrder();
                    Get.back();
                  },
                  child: const Text(
                    "Submit Order",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// Widget _buildDropdown<T>({
//   required String label,
//   required List<T> items,
//   required T? value,
//   required String Function(T) itemAsString,
//   required void Function(T?) onChanged,
// }) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label),
//       const SizedBox(height: 6),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           border: Border.all(width: 1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<T>(
//             value: value,
//             hint: Text("Select $label"),
//             isExpanded: true,
//             items: items
//                 .map(
//                   (e) => DropdownMenuItem(
//                     value: e,
//                     child: Text(itemAsString(e)),
//                   ),
//                 )
//                 .toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//       const SizedBox(height: 12),
//     ],
//   );
// }
