import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PurchaseDetails extends StatelessWidget {
  const PurchaseDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
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
                        "Invoice Detail",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  // Invisible right side spacer for symmetry
                  const SizedBox(width: 50,), // same approx width as icon+padding
                ],
              ),
              SizedBox(height: 20),

              Container(
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
                  children: [
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
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Vendor Name", // Hardcoded text
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        Text(
                          "Anil Sharma", // Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Contact No.", // Hardcoded text
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        Text(
                          "+91 9876567835", // Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Bill Amount", // Hardcoded text
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        Text(
                          "₹ 8900.00", // Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Paid Amount", // Hardcoded text
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        Text(
                          "₹ 0.00",// Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Outstanding", // Hardcoded text
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        Text(
                            "₹ 8900.00", // Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Paid Date\n10/11/2025", // Hardcoded text
                          style: TextStyle(color: Colors.black87,fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        Text(
                          "Due Date\n10/11/2025", // Hardcoded text
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Text(
                "Items", // Hardcoded text
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),

              ListView.builder(
                  shrinkWrap: true, // 👈 Important: let it take only needed height
                  physics: const NeverScrollableScrollPhysics(), // 👈 disables nested scrolling
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  itemCount: 4,
                  itemBuilder: (context, index){
                    return const PurchaseItemCardStatic();
                  } )
            ],
          ),
        ),
      )),
    );
  }
}


class PurchaseItemCardStatic extends StatelessWidget {
  const PurchaseItemCardStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // The design from the "Wooden Box" screenshot (image_6e93ca.png)
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey.shade200,
              // Replace with your actual Image.network() or Image.asset()
              child: const Center(child: Text("IMG", style: TextStyle(color: Colors.grey))),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                const Text(
                  "Wooden Box",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                // SKU
                const Text(
                  "SKU1236747493987983",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                // Color | Material
                const Text(
                  "M | Red | Wooden",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                // Item Price
                const Text(
                  "Item Price: ₹ 8,900",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Quantity and Total Price
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quantity: 2",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Total Price: ₹ 8,900",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}