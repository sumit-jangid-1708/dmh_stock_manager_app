import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../model/vendor_model/vender_overview_model.dart';
class PastProductsTable extends StatelessWidget {
  final List<PastOrderModel> pastProducts;

  const PastProductsTable({super.key, required this.pastProducts});

  // Helper to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Past Orders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: height * 0.015),

        // Show message if no orders
        if (pastProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(width * 0.04),
            decoration: BoxDecoration(
              color: const Color(0xfff8f8f8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1, color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                "No past orders yet",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(width: 1, color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.012,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text(
                          "PO",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Date",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Items",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Total",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Data Rows
                ...pastProducts.map((order) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.015,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.poNumber,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.date,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.items.toString(),
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            "₹${order.totalAmount.toStringAsFixed(0)}",
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(
                                order.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: getStatusColor(order.status),
                              ),
                              textAlign: TextAlign.center,
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
        SizedBox(height: height * 0.02),
      ],
    );
  }
}
