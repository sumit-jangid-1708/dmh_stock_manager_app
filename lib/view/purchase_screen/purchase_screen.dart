import 'package:dmj_stock_manager/view/purchase_screen/add_purchase_bottom_sheet.dart';
import 'package:dmj_stock_manager/view/purchase_screen/purchase_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  // Back button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 22),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),

                  // Space between icon and title
                  const SizedBox(width: 10),
                  // Title centered vertically
                  Expanded(
                    child: Center(
                      child: Text(
                        "Purchase",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  // Invisible right side spacer for symmetry
                  const SizedBox(
                    width: 50,
                  ), // same approx width as icon+padding
                ],
              ),
              SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    // 🔍 Search Bar
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            onPressed: () {},

                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: "Search products...",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 🖨 Filter Button (Square)
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            elevation: 10,
                            context: context,
                            isScrollControlled:
                            true, // for full screen height support
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              return AddPurchaseBottomSheet();
                            },
                          );

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A4F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  shrinkWrap: true, // 👈 Important: let it take only needed height
                  physics: const NeverScrollableScrollPhysics(), // 👈 disables nested scrolling
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: 4,
                  itemBuilder: (context, index){
                    return PurchaseList();
                  } )
            ],
          ) ,
          ),
      )),
    );
  }
}


class PurchaseList extends StatelessWidget {
  const PurchaseList({super.key});

  @override
  Widget build(BuildContext context) {
    // The main container card
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Row 1: Initials, Supplier Info, Quantity ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials Box ("RC")
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "RC", // Hardcoded text
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Supplier Info and Quantity (Main Content)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Supplier Name (Hardcoded text)
                        const Text(
                          "Rajast Crafts Suppliers",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        // Quantity (Hardcoded text)
                        const Text(
                          "QTY: 22",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Invoice ID (Hardcoded text)
                    const Text(
                      "INV-2025-006",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // --- Contact Person and Contact No. Details ---

          // Vendor Name/Contact Person Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Vendor Name:", // Hardcoded text
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              Text(
                "Anil Sharma", // Hardcoded text
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contact No. Row
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Contact No.", // Hardcoded text
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              Text(
                "+91 9856743892", // Hardcoded text
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 25, thickness: 1, color: Colors.grey),
          const SizedBox(height: 10),

          // --- View Details Button ---
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // Implement navigation to the detail screen
                Get.to(PurchaseDetails());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100, // Light grey background
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
              label: const Text(
                "View Details", // Hardcoded text
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
