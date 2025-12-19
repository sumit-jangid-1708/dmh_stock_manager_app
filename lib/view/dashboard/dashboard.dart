import 'package:dmj_stock_manager/res/components/side_bar/side_bar.dart';
import 'package:dmj_stock_manager/res/components/widgets/add_item_form_bottom_sheet.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_header.dart';
import 'package:dmj_stock_manager/view/home_screen/home_screen.dart';
import 'package:dmj_stock_manager/view/items/items_screen.dart';
import 'package:dmj_stock_manager/view/vendors/vendor_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/auth_screen.dart';
import '../orders/order_screen.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardController dashboardController = Get.put(
    DashboardController(),
    permanent: true,
  );
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final List<IconData> icons = [
    Icons.home_filled,
    Icons.shopping_bag,
    // Icons.inventory_2_outlined,
    Icons.person,
    Icons.shopping_cart_rounded,
  ];

  final List<String> labels = ["Home", "Item", "Vendor", "Order"];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      ItemsScreen( ),
      // StockScreen(),
      VendorScreen(),
      OrderScreen(),
    ];

    return Obx(() {
      return Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          child:Sidebar(
            onItemTap: (key) {
              if (key == "logout") {
                // User logout → वापस AuthScreen
                Get.offAll(() => AuthScreen());
              } else if (key == "setting") {
                // Setting logic
                // Get.toNamed(RouteName.settingsScreen);
              }
            },
          ),
        ),
        backgroundColor: Colors.white,
        bottomNavigationBar: customBottomBar(),
        body: Stack(
          children: [
            // Active Screen Content (with padding so it's not hidden under header)
            Padding(
              padding: const EdgeInsets.only(
                top: 70,
              ), // adjust to header height
              child: screens[dashboardController.currentIndex.value],
            ),

            // Fixed App Header on top
            Positioned(
              top: 25,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  AppHeader(scaffoldKey: scaffoldKey),
                   const Divider(height: 2, color: Color.fromARGB(255, 188, 188, 188)),
                ],
              ),
            ),

            // Floating Add Button -> only on item screen
            if(dashboardController.currentIndex.value == 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) =>  AddItemFormBottomSheet(),
                  );
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A1A4F),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget customBottomBar() {
    return Container(
      height: 88,
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = dashboardController.currentIndex.value == index;

          return GestureDetector(
            onTap: () => dashboardController.changeTab(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
                    border: isSelected
                        ? Border.all(color:const Color(0xFF1A1A4F), width: 2)
                        : null,
                  ),
                  child: Icon(
                    icons[index],
                    size: 28,
                    color: isSelected ? const Color(0xFF1A1A4F) : Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1A1A4F): Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      )),
    );
  }

}
