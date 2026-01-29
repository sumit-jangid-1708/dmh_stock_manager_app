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
  final DashboardController dashboardController = Get.find<DashboardController>();
  final AuthController authController = Get.find<AuthController>();

  Sidebar({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1A1A4F);

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(25), bottomRight: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✨ Logo Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              alignment: Alignment.center,
              child: Image.asset(
                ImageAssets.dmhLogo,
                height: 70,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 50, color: primaryColor),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(thickness: 1, color: Color(0xFFF0F0F0)),
            ),

            const SizedBox(height: 10),

            // ✨ Menu Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.dashboard_outlined,
                      title: "Dashboard",
                      onTap: () {
                        dashboardController.changeTab(0);
                        Get.back();
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.inventory_2_outlined,
                      title: "Inventory",
                      onTap: () => Get.toNamed(RouteName.stockScreen),
                    ),
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: "Billings",
                      onTap: () => Get.to( BillingScreen()),
                    ),
                    _buildMenuItem(
                      icon: Icons.add_shopping_cart_rounded,
                      title: "Purchase",
                      onTap: () => Get.to(()=> PurchaseScreen()),
                    ),

                    // 🔒 History Button is now hidden (Commented out/Removed)
                    /*
                    _buildMenuItem(
                      icon: Icons.history,
                      title: "History",
                      onTap: () => Get.toNamed(RouteName.historyScreen),
                    ),
                    */

                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: "Setting",
                      onTap: () => Get.toNamed(RouteName.settings),
                    ),
                  ],
                ),
              ),
            ),

            // ✨ Logout Section
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_rounded,
                  title: "Logout",
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  onTap: () => authController.logout(),
                ),
              ),
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
    Color? iconColor,
    Color? textColor,
  }) {
    const Color primaryColor = Color(0xFF1A1A4F);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            // You can add logic here to highlight the active tab if needed
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? primaryColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}