import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/statCard.dart';
import 'package:dmj_stock_manager/res/components/widgets/stock_button_row.dart';
import 'package:dmj_stock_manager/view/home_screen/low_stock_screen.dart';
import 'package:dmj_stock_manager/view/home_screen/total_stock_screen.dart';
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
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xFF1A1A4F),
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
                // 🎨 Enhanced Header
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dashboard",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Welcome back! Here's your overview",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      AppGradientButton(
                        onPressed: () {
                          Get.dialog(ChannelDialogWidget());
                        },
                        icon: Icons.add_circle_outline,
                        text: "Add Channel",
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                StockButtonRow(),
                SizedBox(height: 20),

                // 📊 Stats Cards Section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A4F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.analytics_outlined,
                                size: 18,
                                color: Color(0xFF1A1A4F),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Quick Stats",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Obx(() {
                        return SizedBox(
                          height: 170,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            children: [
                              SizedBox(
                                width: 190,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(TotalStockScreen());
                                  },
                                  child: StatCard(
                                    title: "Total Stock",
                                    value: homeController.totalStock.value
                                        .toString(),
                                    subtitle: "Active inventory items",
                                    icon: Icons.inventory_2_rounded,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF1A1A4F),
                                        Color(0xFF2D2D7F),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 190,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(LowStockScreen());
                                  },
                                  child: StatCard(
                                    title: "Low Stock",
                                    value: homeController.lowStock.value
                                        .toString(),
                                    subtitle: "Need restocking",
                                    icon: Icons.show_chart_rounded,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade600,
                                        Colors.deepOrange.shade500,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              SizedBox(
                                width: 190,
                                child: InkWell(
                                  onTap: () {},
                                  child: StatCard(
                                    title: "Total Value",
                                    value:
                                        "₹${homeController.totalStockValue.value.toStringAsFixed(0)}",
                                    subtitle: "Total stock worth",
                                    icon: Icons.currency_rupee,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.green.shade600,
                                        Colors.teal.shade500,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // 📋 Recent Activity Section
                Container(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1A4F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          size: 18,
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recent Added Products",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          // Text(
                          //   "These are the recently ",
                          //   style: TextStyle(
                          //     fontSize: 12,
                          //     color: Colors.grey.shade600,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Obx(() {
                  if (itemController.isLoading.value) {
                    return Container(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A1A4F),
                        ),
                      ),
                    );
                  }

                  if (itemController.products.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No products found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final displayCount = itemController.products.length > 5
                      ? 5
                      : itemController.products.length;

                  return ListView.builder(
                    itemCount: displayCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = itemController.products[index];

                      return ProductCard(
                        count: index + 1,
                        product: product,
                        onShare: () {
                          showDialog(
                            context: context,
                            builder: (_) => ImageShareDialog(product: product),
                          );
                        },
                        onView: () {
                          showBarcodeDialog(
                            context,
                            product.id,
                            product.barcode,
                            product.barcodeImage,
                          );
                        },
                        onAdd: () {
                          handleInventoryAction(product);
                        },
                      );
                    },
                  );
                }),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
// import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
// import 'package:dmj_stock_manager/res/components/widgets/statCard.dart';
// import 'package:dmj_stock_manager/res/components/widgets/stock_button_row.dart';
// import 'package:dmj_stock_manager/view/home_screen/low_stock_screen.dart';
// import 'package:dmj_stock_manager/view/home_screen/total_stock_screen.dart';
// import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
// import 'package:dmj_stock_manager/view_models/controller/home_controller.dart';
// import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../res/components/widgets/channel_dialog_widget.dart';
// import '../../res/components/widgets/iamge_share_dialog.dart';
// import '../../view_models/controller/item_controller.dart';
// import '../items/items_screen.dart';
//
// class HomeScreen extends StatelessWidget {
//   HomeScreen({super.key});
//   final HomeController homeController = Get.put(HomeController());
//   final ItemController itemController = Get.find<ItemController>();
//   final StockController stockController = Get.find<StockController>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: () async {
//             homeController.fetchStats();
//             homeController.getChannels();
//             homeController.getStockDetail();
//             itemController.getProducts();
//           },
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Dashboard",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     TextButton(
//                       style: TextButton.styleFrom(
//                         fixedSize: Size(130, 40),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(
//                             width: 1.0,
//                             color: Color(0xFF1A1A4F),
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         Get.dialog(ChannelDialogWidget());
//                       },
//                       child: Text(
//                         "Add Channels",
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1A1A4F),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 StockButtonRow(),
//                 SizedBox(height: 10),
//
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10),
//                   child: Obx(() {
//                     return SizedBox(
//                       height: 160, // card की height
//                       child: ListView(
//                         scrollDirection: Axis.horizontal,
//                         children: [
//                           SizedBox(
//                             width: 180,
//                             child: InkWell(
//                               onTap: () {
//                                 // 👇 Yahan baad me tum ek page banaoge jahan total stock dikhana hai
//                                 Get.to(TotalStockScreen());
//                               },
//                               child: StatCard(
//                                 title: "Total Stock",
//                                 value: homeController.totalStock.value
//                                     .toString(),
//                                 subtitle: "Active inventory items",
//                                 icon: Icons.inventory_2_rounded,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           SizedBox(
//                             width: 180,
//                             child: InkWell(
//                               onTap: () {
//                                 Get.to(LowStockScreen());
//                               },
//                               child: StatCard(
//                                 title: "Low Stock",
//                                 value: homeController.lowStock.value.toString(),
//                                 subtitle: "Need restocking",
//                                 icon: Icons.show_chart_rounded,
//                               ),
//                             ),
//                           ),
//                           // const SizedBox(width: 12),
//                           // SizedBox(
//                           //   width: 180,
//                           //   child: InkWell(
//                           //     onTap: () {
//                           //
//                           //     },
//                           //     child: StatCard(
//                           //       title: "Out of Stock",
//                           //       value: homeController.outOfStock.value.toString(),
//                           //       subtitle: "Urgent restock needed",
//                           //       icon: Icons.inventory_outlined,
//                           //     ),
//                           //   ),
//                           // ),
//                           const SizedBox(width: 12),
//                           SizedBox(
//                             width: 180,
//                             child: InkWell(
//                               onTap: () {
//                                 // Get.to(() => PlaceholderScreen(title: "Total Stock Value"));
//                               },
//                               child: StatCard(
//                                 title: "Total Stock Value",
//                                 value: homeController.totalStockValue.value
//                                     .toString(),
//                                 subtitle: "Total stock worth",
//                                 icon: Icons.currency_rupee,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Recent Activity",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 const Text(
//                   "Items requiring attention",
//                   style: TextStyle(fontSize: 12),
//                 ),
//                 const SizedBox(height: 15),
//                 Obx(() {
//                   if (itemController.isLoading.value) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//
//                   if (itemController.products.isEmpty) {
//                     return const Center(child: Text("No products found"));
//                   }
//
//                   final displayCount = itemController.products.length > 5
//                       ? 5
//                       : itemController.products.length;
//                   return ListView.builder(
//                     itemCount: displayCount,
//                     shrinkWrap: true, // 👈 yeh important hai
//                     physics:
//                         const NeverScrollableScrollPhysics(), // scroll ka clash avoid karega
//                     // padding: const EdgeInsets.symmetric(horizontal: 12),
//                     itemBuilder: (context, index) {
//                       final product = itemController.products[index];
//
//                       return InkWell(
//                         onTap: (){
//                           handleInventoryAction(product);
//                           // showAddInventoryDialog(product, (qty){
//                           //   stockController.addInventory(productId: product.id, quantity: qty);
//                           // });
//                         },
//                         child: ProductCard(
//                           count: index + 1,
//                           product: product, // 👈 pass full ProductModel
//                           onShare: () {
//                             showDialog(
//                               context: context,
//                               builder: (_)=> ImageShareDialog( product: product,),
//                             );
//                           },
//                           onView: () {
//                             showBarcodeDialog(
//                               context,
//                               product.barcode,
//                               product.barcodeImage,
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
