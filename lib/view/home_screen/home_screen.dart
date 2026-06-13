import 'package:dmj_stock_manager/res/components/barcode_dialog.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/res/components/widgets/product_list_card_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/statCard.dart';
import 'package:dmj_stock_manager/res/components/widgets/stock_button_row.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view/home_screen/low_stock_screen.dart';
import 'package:dmj_stock_manager/view/home_screen/total_stock_screen.dart';
import 'package:dmj_stock_manager/view/orders/order_screen.dart';
import 'package:dmj_stock_manager/view/orders/return_order_screen.dart';
import 'package:dmj_stock_manager/view/orders/shipping_screen.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_screen.dart';
import 'package:dmj_stock_manager/view/settings/settings_screen.dart';
import 'package:dmj_stock_manager/view/stock/stock_screen.dart';
import 'package:dmj_stock_manager/view/users/users_screen.dart';
import 'package:dmj_stock_manager/view/vendors/vendor_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/auth/auth_controller.dart';
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
  final AuthController authController = Get.find<AuthController>();
  final ItemController itemController = Get.find<ItemController>();
  final StockController stockController = Get.find<StockController>();

  String _money(double value) {
    if (value >= 10000000) return "₹${(value / 10000000).toStringAsFixed(1)}Cr";
    if (value >= 100000) return "₹${(value / 100000).toStringAsFixed(1)}L";
    if (value >= 1000) return "₹${(value / 1000).toStringAsFixed(1)}K";
    return "₹${value.toStringAsFixed(0)}";
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A1A4F)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF11123A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(String label, String value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF11123A),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showMainInfoDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A4F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF1A1A4F),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Main Info",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1A4F),
                            ),
                          ),
                          Text(
                            "Monthly sales, purchase and stock overview",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _infoPill("Stock", homeController.totalStock.toString()),
                    _infoPill("Low Stock", homeController.lowStock.toString()),
                    _infoPill(
                      "Products",
                      homeController.productsCount.toString(),
                    ),
                    _infoPill("Orders", homeController.ordersCount.toString()),
                    _infoPill(
                      "Vendors",
                      homeController.vendorsCount.toString(),
                    ),
                    _infoPill("Users", homeController.usersCount.toString()),
                    _infoPill(
                      "Purchase",
                      _money(homeController.totalPurchase.value),
                    ),
                    _infoPill("Sales", _money(homeController.totalSales.value)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => homeController.refreshAllData(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Refresh"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A4F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xFF1A1A4F),
          onRefresh: () async {
            await homeController.refreshAllData();
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
                      if (authController.canAction("orders", "add"))
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
                        child: _sectionTitle(
                          icon: Icons.analytics_outlined,
                          title: "Quick Stats",
                          subtitle: "Live from dashboard API",
                        ),
                      ),
                      Obx(() {
                        return SizedBox(
                          height: 170,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            children: [
                              if (authController.canView("inventory"))
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
                              if (authController.canView("inventory"))
                                const SizedBox(width: 14),
                              if (authController.canView("inventory"))
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
                              if (authController.canView("inventory"))
                                const SizedBox(width: 14),
                              if (authController.canView("inventory"))
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
                              if (authController.canView("orders"))
                                const SizedBox(width: 14),
                              if (authController.canView("orders"))
                                SizedBox(
                                  width: 190,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => OrderScreen());
                                    },
                                    child: StatCard(
                                      title: "Orders",
                                      value: homeController.ordersCount.value
                                          .toString(),
                                      subtitle: "This period",
                                      icon: Icons.shopping_cart_checkout,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade700,
                                          Colors.indigo.shade500,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (authController.canView("purchase"))
                                const SizedBox(width: 14),
                              if (authController.canView("purchase"))
                                SizedBox(
                                  width: 190,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => PurchaseScreen());
                                    },
                                    child: StatCard(
                                      title: "Purchase",
                                      value: _money(
                                        homeController.totalPurchase.value,
                                      ),
                                      subtitle: "Purchase amount",
                                      icon: Icons.add_shopping_cart_rounded,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.purple.shade600,
                                          Colors.deepPurple.shade400,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              if (authController.canView("billing"))
                                const SizedBox(width: 14),
                              if (authController.canView("billing"))
                                SizedBox(
                                  width: 190,
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => BillingScreen());
                                    },
                                    child: StatCard(
                                      title: "Sales",
                                      value: _money(
                                        homeController.totalSales.value,
                                      ),
                                      subtitle: "Sales amount",
                                      icon: Icons.receipt_long_rounded,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.cyan.shade700,
                                          Colors.blue.shade400,
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

                _sectionTitle(
                  icon: Icons.apps_rounded,
                  title: "Modules",
                  subtitle: "Open every project area from here",
                ),
                Obx(() {
                  return GridView.count(
                    crossAxisCount: Get.width > 700 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: Get.width > 700 ? 1.55 : 1.35,
                    children: [
                      if (authController.canView("main_info"))
                        _moduleTile(
                          icon: Icons.info_outline_rounded,
                          title: "Main Info",
                          value: "Open",
                          color: const Color(0xFF1A1A4F),
                          onTap: _showMainInfoDialog,
                        ),
                      if (authController.canView("items"))
                        _moduleTile(
                          icon: Icons.inventory_2_rounded,
                          title: "Items",
                          value: homeController.productsCount.value.toString(),
                          color: const Color(0xFF4338CA),
                          onTap: () => Get.to(() => ItemsScreen()),
                        ),
                      if (authController.canView("inventory"))
                        _moduleTile(
                          icon: Icons.warehouse_rounded,
                          title: "Inventory",
                          value: homeController.totalStock.value.toString(),
                          color: Colors.teal.shade700,
                          onTap: () => Get.to(() => StockScreen()),
                        ),
                      if (authController.canView("vendors"))
                        _moduleTile(
                          icon: Icons.people_alt_rounded,
                          title: "Vendors",
                          value: homeController.vendorsCount.value.toString(),
                          color: Colors.orange.shade700,
                          onTap: () => Get.to(() => VendorScreen()),
                        ),
                      if (authController.canView("orders"))
                        _moduleTile(
                          icon: Icons.shopping_cart_rounded,
                          title: "Orders",
                          value: homeController.ordersCount.value.toString(),
                          color: Colors.blue.shade700,
                          onTap: () => Get.to(() => OrderScreen()),
                        ),
                      if (authController.canView("orders"))
                        _moduleTile(
                          icon: Icons.local_shipping_rounded,
                          title: "Shipping",
                          value:
                              homeController.recentOrdersCount.value.toString(),
                          color: Colors.indigo.shade600,
                          onTap: () => Get.to(() => ShippingScreen()),
                        ),
                      if (authController.canView("billing"))
                        _moduleTile(
                          icon: Icons.receipt_rounded,
                          title: "Billing",
                          value: homeController.purchaseBillsCount.value
                              .toString(),
                          color: Colors.green.shade700,
                          onTap: () => Get.to(() => BillingScreen()),
                        ),
                      if (authController.canView("purchase"))
                        _moduleTile(
                          icon: Icons.playlist_add_check_rounded,
                          title: "Purchase",
                          value: _money(homeController.totalPurchase.value),
                          color: Colors.purple.shade600,
                          onTap: () => Get.to(() => PurchaseScreen()),
                        ),
                      if (authController.canView("orders"))
                        _moduleTile(
                          icon: Icons.assignment_return_rounded,
                          title: "Returns",
                          value: "Open",
                          color: Colors.red.shade600,
                          onTap: () => Get.to(() => ReturnOrderHistoryScreen()),
                        ),
                      if (authController.canAction("orders", "add"))
                        _moduleTile(
                          icon: Icons.hub_rounded,
                          title: "Channels",
                          value: homeController.channelsCount.value.toString(),
                          color: Colors.cyan.shade700,
                          onTap: () => Get.dialog(ChannelDialogWidget()),
                        ),
                      if (authController.canView("users"))
                        _moduleTile(
                          icon: Icons.manage_accounts_rounded,
                          title: "Users",
                          value: homeController.usersCount.value.toString(),
                          color: Colors.brown.shade600,
                          onTap: () => Get.to(() => UsersScreen()),
                        ),
                      _moduleTile(
                        icon: Icons.settings_rounded,
                        title: "Settings",
                        value: "Open",
                        color: Colors.grey.shade700,
                        onTap: () => Get.to(() => SettingsScreen()),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 28),

                // 📋 Recent Activity Section
                Container(
                  padding: EdgeInsets.only(left: 4, bottom: 12),
                  child: _sectionTitle(
                    icon: Icons.access_time,
                    title: "Recent Added Products",
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
                            // product.id,
                            product.barcode,
                            product.name,
                            // product.barcodeImage,
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
