import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/statCard.dart';
import 'package:dmj_stock_manager/res/components/widgets/stock_button_row.dart';
import 'package:dmj_stock_manager/view/home_screen/low_stock_screen.dart';
import 'package:dmj_stock_manager/view/home_screen/total_stock_screen.dart';
import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../res/components/widgets/channel_dialog_widget.dart';
import '../../res/components/widgets/iamge_share_dialog.dart';
import '../../view_models/controller/item_controller.dart';
import '../items/items_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController homeController = Get.put(HomeController());
  final ItemController itemController = Get.find<ItemController>();
  final StockController stockController = Get.find<StockController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            homeController.fetchStats();
            homeController.getChannels();
            homeController.getStockDetail();
            itemController.getProducts();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        fixedSize: Size(130, 40),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1.0,
                            color: Color(0xFF1A1A4F),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.dialog(ChannelDialogWidget());
                      },
                      child: Text(
                        "Add Channels",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                StockButtonRow(),
                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Obx(() {
                    return SizedBox(
                      height: 160, // card की height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 180,
                            child: InkWell(
                              onTap: () {
                                // 👇 Yahan baad me tum ek page banaoge jahan total stock dikhana hai
                                Get.to(TotalStockScreen());
                              },
                              child: StatCard(
                                title: "Total Stock",
                                value: homeController.totalStock.value
                                    .toString(),
                                subtitle: "Active inventory items",
                                icon: Icons.inventory_2_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 180,
                            child: InkWell(
                              onTap: () {
                                Get.to(LowStockScreen());
                              },
                              child: StatCard(
                                title: "Low Stock",
                                value: homeController.lowStock.value.toString(),
                                subtitle: "Need restocking",
                                icon: Icons.show_chart_rounded,
                              ),
                            ),
                          ),
                          // const SizedBox(width: 12),
                          // SizedBox(
                          //   width: 180,
                          //   child: InkWell(
                          //     onTap: () {
                          //
                          //     },
                          //     child: StatCard(
                          //       title: "Out of Stock",
                          //       value: homeController.outOfStock.value.toString(),
                          //       subtitle: "Urgent restock needed",
                          //       icon: Icons.inventory_outlined,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 180,
                            child: InkWell(
                              onTap: () {
                                // Get.to(() => PlaceholderScreen(title: "Total Stock Value"));
                              },
                              child: StatCard(
                                title: "Total Stock Value",
                                value: homeController.totalStockValue.value
                                    .toString(),
                                subtitle: "Total stock worth",
                                icon: Icons.currency_rupee,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 15),
                const Text(
                  "Recent Activity",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Items requiring attention",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 15),
                Obx(() {
                  if (itemController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (itemController.products.isEmpty) {
                    return const Center(child: Text("No products found"));
                  }

                  return ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true, // 👈 yeh important hai
                    physics:
                        const NeverScrollableScrollPhysics(), // scroll ka clash avoid karega
                    // padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final product = itemController.products[index];

                      return InkWell(
                        onTap: (){
                          handleInventoryAction(product);
                          // showAddInventoryDialog(product, (qty){
                          //   stockController.addInventory(productId: product.id, quantity: qty);
                          // });
                        },
                        child: ProductCard(
                          count: index + 1,
                          product: product, // 👈 pass full ProductModel
                          onShare: () {
                            showDialog(
                              context: context,
                              builder: (_)=> ImageShareDialog( product: product,),
                            );
                          },
                          onView: () {
                            showBarcodeDialog(
                              context,
                              product.barcode,
                              product.barcodeImage,
                            );
                          },
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
    );
  }
}
