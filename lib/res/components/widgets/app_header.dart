import 'package:dmj_stock_manager/res/components/scanner/qr_scanner_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../view/orders/order_create_bottom_sheet.dart';
import '../../../view_models/controller/order_controller.dart';

class AppHeader extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const AppHeader({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
            child: IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
              icon: Icon(Icons.menu, size: 30),
            ),
          ),
          Row(
            children: [
              // ElevatedButton(
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Color(0xFF1A1A4F),
              //     fixedSize: Size(110, 50),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //   ),
              //
              //   onPressed: () {},
              //   child: Text(
              //     "Channels",
              //     style: TextStyle(color: Colors.white, fontSize: 12),
              //   ),
              // ),
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A4F),
                  borderRadius: BorderRadius.circular(15),
                  // shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () async {
                    final result = await Get.to(() => const QrScannerWidget());

                    if (result != null) {
                      debugPrint('👍👍 Scanned result: $result');
                      // You can handle the scanned data here
                      final orderController = Get.find<OrderController>();
                      orderController.setScannedSku(result);
                      Get.bottomSheet(
                        OrderCreateBottomSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.white
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
