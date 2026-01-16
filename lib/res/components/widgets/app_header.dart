import 'package:dmj_stock_manager/res/components/scanner/qr_scanner_widget.dart';
import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:dmj_stock_manager/view_models/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../view/orders/order_create_bottom_sheet.dart';
import '../../../view_models/controller/order_controller.dart';

class AppHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  AppHeader({super.key, required this.scaffoldKey});
  final DashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // --- Custom Menu Button ---
          GestureDetector(
            onTap: () => scaffoldKey.currentState?.openDrawer(),
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF1A1A4F),
                size: 28,
              ),
            ),
          ),

          Row(
            children: [
              // --- Low Stock Notification Badge ---
              Obx(() {
                final count = controller.lowStockItems.length;
                // if (count == 0) return const SizedBox.shrink();
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    AppGradientButton(
                      onPressed: () {
                        controller.openLowStockDialog();
                      },
                      icon: Icons.inventory_2_outlined,
                      width: 50,
                      height: 50,
                    ),
                    if(count > 0)
                    Positioned(
                      right: 7,
                      top: 3,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(width: 10),
              // --- Gradient QR Scanner Button ---
              AppGradientButton(
                onPressed: () async {
                  final orderController = Get.find<OrderController>();

                  // ✅ Scanner se product model milega (not SKU string)
                  final scannedProduct = await Get.to(() => const QrScannerWidget());

                  if (scannedProduct != null) {
                    // ✅ Product add karo order items mein
                    orderController.addScannedProduct(scannedProduct);

                    // ✅ Check if bottom sheet already open hai
                    bool isBottomSheetOpen = Get.isBottomSheetOpen ?? false;

                    if (!isBottomSheetOpen) {
                      // ✅ Bottom sheet open karo agar pehle se open nahi hai
                      Get.bottomSheet(
                        OrderCreateBottomSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                      );
                    }
                  }
                },
                icon: Icons.qr_code_scanner_rounded,
                width: 50,
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}