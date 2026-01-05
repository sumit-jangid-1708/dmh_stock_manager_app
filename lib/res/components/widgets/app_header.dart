import 'package:dmj_stock_manager/res/components/scanner/qr_scanner_widget.dart';
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
              child: const Icon(Icons.menu_rounded, color: Color(0xFF1A1A4F), size: 28),
            ),
          ),

          Row(
            children: [
              // --- Low Stock Notification Badge ---
              Obx(() {
                final count = controller.lowStockItems.length;
                if (count == 0) return const SizedBox.shrink();

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                        // shape: BoxShape.circle,

                      ),
                      child: IconButton(
                        icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                        onPressed: () {
                          controller.openLowStockDialog();
                        }, // Handled by controller logic elsewhere
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2), // Pop effect
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

              // --- Gradient QR Scanner Button ---
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(() => const QrScannerWidget());
                  if (result != null) {
                    final orderController = Get.find<OrderController>();
                    orderController.setScannedSku(result);
                    Get.bottomSheet(
                      OrderCreateBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                    );
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1A4F).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}