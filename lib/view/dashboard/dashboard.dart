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
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.people_rounded,
    Icons.shopping_cart_rounded,
  ];

  final List<String> labels = ["Home", "Items", "Vendors", "Orders"];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      ItemsScreen(),
      VendorScreen(),
      OrderScreen(),
    ];

    return Obx(() {
      return Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          child: Sidebar(
            onItemTap: (key) {
              if (key == "logout") {
                Get.offAll(() => AuthScreen());
              } else if (key == "setting") {
                // Setting logic
              }
            },
          ),
        ),
        backgroundColor: Colors.grey.shade50,
        bottomNavigationBar: _buildModernBottomBar(),
        body: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: screens[dashboardController.currentIndex.value],
            ),

            // Top Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: AppHeader(scaffoldKey: scaffoldKey),
                      ),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Action Button (Only on Items tab)
            if (dashboardController.currentIndex.value == 1)
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddItemFormBottomSheet(),
                    );
                  },
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF1A1A4F).withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildModernBottomBar() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = dashboardController.currentIndex.value == index;
            return GestureDetector(
              onTap: () => dashboardController.changeTab(index),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            Color(0xFF1A1A4F).withOpacity(0.15),
                            Color(0xFF2D2D7F).withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                              )
                            : null,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icons[index],
                        size: 24,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: TextStyle(
                        color: isSelected
                            ? Color(0xFF1A1A4F)
                            : Colors.grey.shade600,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// import 'package:dmj_stock_manager/res/components/side_bar/side_bar.dart';
// import 'package:dmj_stock_manager/res/components/widgets/add_item_form_bottom_sheet.dart';
// import 'package:dmj_stock_manager/res/components/widgets/app_header.dart';
// import 'package:dmj_stock_manager/view/home_screen/home_screen.dart';
// import 'package:dmj_stock_manager/view/items/items_screen.dart';
// import 'package:dmj_stock_manager/view/vendors/vendor_screen.dart';
// import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../auth/auth_screen.dart';
// import '../orders/order_screen.dart';
//
// class DashboardScreen extends StatelessWidget {
//   final DashboardController dashboardController = Get.find<DashboardController>(); // पहले से put है
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   final List<IconData> icons = [
//     Icons.home_filled,
//     Icons.shopping_bag,
//     Icons.person,
//     Icons.shopping_cart_rounded,
//   ];
//
//   final List<String> labels = ["Home", "Item", "Vendor", "Order"];
//
//   DashboardScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> screens = [
//       HomeScreen(),
//       ItemsScreen(),
//       VendorScreen(),
//       OrderScreen(),
//     ];
//
//     return Obx(() {
//       return Scaffold(
//         key: scaffoldKey,
//         drawer: Drawer(
//           child: Sidebar(
//             onItemTap: (key) {
//               if (key == "logout") {
//                 Get.offAll(() => AuthScreen());
//               } else if (key == "setting") {
//                 // Setting logic
//               }
//             },
//           ),
//         ),
//         backgroundColor: Colors.white,
//         bottomNavigationBar: customBottomBar(),
//         body: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 70),
//               child: screens[dashboardController.currentIndex.value],
//             ),
//             Positioned(
//               top: 25,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   AppHeader(scaffoldKey: scaffoldKey),
//                   const Divider(height: 2, color: Color.fromARGB(255, 188, 188, 188)),
//                 ],
//               ),
//             ),
//             if (dashboardController.currentIndex.value == 1)
//               Positioned(
//                 bottom: 20,
//                 right: 20,
//                 child: GestureDetector(
//                   onTap: () {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                       ),
//                       builder: (_) => AddItemFormBottomSheet(),
//                     );
//                   },
//                   child: Container(
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: const Color(0xFF1A1A4F),
//                       boxShadow: [
//                         BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
//                       ],
//                     ),
//                     child: const Icon(Icons.add, color: Colors.white, size: 32),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }
//
//   Widget customBottomBar() {
//     return Container(
//       height: 88,
//       padding: const EdgeInsets.only(top: 10),
//       decoration: const BoxDecoration(
//         color: Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(0)),
//       ),
//       child: Obx(() => Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(icons.length, (index) {
//           final isSelected = dashboardController.currentIndex.value == index;
//           return GestureDetector(
//             onTap: () => dashboardController.changeTab(index),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
//                     border: isSelected ? Border.all(color: const Color(0xFF1A1A4F), width: 2) : null,
//                   ),
//                   child: Icon(
//                     icons[index],
//                     size: 28,
//                     color: isSelected ? const Color(0xFF1A1A4F) : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   labels[index],
//                   style: TextStyle(
//                     color: isSelected ? const Color(0xFF1A1A4F) : Colors.black,
//                     fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       )),
//     );
//   }
// }
