import 'package:dmj_stock_manager/res/assets/images_assets.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/view/billings/billing_screen.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view_models/controller/auth/auth_controller.dart';

class Sidebar extends StatelessWidget {
  final Function(String) onItemTap;
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();
  Sidebar({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Image.asset(
                    ImageAssets.dmhLogo, // Replace with your actual path
                    height: 60,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Menu items
            _buildMenuItem(
              icon: Icons.home,
              title: "Dashboard",
              // onTap: () => Get.toNamed(RouteName.homeScreen),
              onTap: () {
                dashboardController.changeTab(0);
                Get.back();
              },
            ),
            // const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            // _buildMenuItem(
            //   icon: Icons.shopping_bag,
            //   title: "Item",
            //   onTap: () {
            //     dashboardController.changeTab(1);
            //     Get.back();
            //   },
            // ),
            const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            _buildMenuItem(
              icon: Icons.inventory,
              title: "Inventory",
              onTap: () => Get.toNamed(RouteName.stockScreen),
            ),
            // const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            // _buildMenuItem(
            //   icon: Icons.shopping_cart_rounded,
            //   title: "Orders",
            //   onTap: () {
            //     dashboardController.changeTab(3);
            //     Get.back();
            //   },
            // ),
            const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            _buildMenuItem(
              icon: Icons.receipt_long,
              title: "Billings",
              onTap: () {
                Get.to(BillingScreen());
              },
            ),
            const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            _buildMenuItem(
              icon: Icons.add_shopping_cart,
              title: "Purchase",
              onTap: () {
                Get.to(PurchaseScreen());
              },
            ),
            const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            _buildMenuItem(
              icon: Icons.history,
              title: "History",
              onTap: () {
                Get.toNamed(RouteName.historyScreen);
              },
            ),
            const Divider(thickness: 0.3, indent: 30, endIndent: 30),
            _buildMenuItem(
              icon: Icons.settings,
              title: "Setting",
              onTap: () => onItemTap("setting"),
            ),

            const Spacer(),

            // Logout
            _buildMenuItem(
              icon: Icons.logout,
              title: "Logout",
              onTap: () => authController.logout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF1A1A4F), size: 30),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }
}
