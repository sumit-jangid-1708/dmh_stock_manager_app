import 'package:dmj_stock_manager/res/components/widgets/past_products_table.dart';
import 'package:dmj_stock_manager/res/components/widgets/supplied_product_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailScreen extends StatelessWidget {
  const VendorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    final suppliedProducts = List.generate(
      6,
          (index) => {
        "sku": "SKU-101",
        "product": "Carved wooden-Box",
        "qty": "3",
        "remainders": "1",
      },
    );

    final pastProducts = List.generate(
      10,
          (index) => {
        "po": "PO-101",
        "date": "21-08-2025",
        "items": "3",
        "total": "₹29345",
        "status": "Delivered",
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Container(
                  width: width * 0.1,
                  height: width * 0.1,
                  margin: EdgeInsets.only(top: height * 0.02),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(height: height * 0.02),

                // Vendor card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(width * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f8f8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 1, color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: width * 0.12,
                            height: width * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                "RC",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Rajasth Crafts Suppliers",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Udaipur, RJ • Handicrafts, Home Decor",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.02),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.012,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "GSTIN: 08ARTPK5689V8FT",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.02),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: height * 0.15,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8f8f8),
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(width: 1, color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("On-time delivery",
                                  style: TextStyle(fontSize: 16)),
                              Spacer(),
                              Text(
                                "92%",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.04),
                    Expanded(
                      child: Container(
                        height: height * 0.15,
                        decoration: BoxDecoration(
                          color: const Color(0xfff8f8f8),
                          borderRadius: BorderRadius.circular(20),
                          border:
                          Border.all(width: 1, color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Quality rating",
                                  style: TextStyle(fontSize: 16)),
                              Spacer(),
                              Text(
                                "4.5/5",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: height * 0.02),

                SuppliedProductTable(suppliedProducts: suppliedProducts),
                PastProductsTable(pastProducts: pastProducts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
