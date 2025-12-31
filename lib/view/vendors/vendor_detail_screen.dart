import 'package:dmj_stock_manager/res/components/widgets/past_products_table.dart';
import 'package:dmj_stock_manager/res/components/widgets/supplied_product_table.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorDetailScreen extends StatefulWidget {
  final int vendorId;

  const VendorDetailScreen({
    super.key,
    required this.vendorId,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  final VendorController vendorController = Get.find<VendorController>();

  @override
  void initState() {
    super.initState();
    // Fetch vendor details when screen loads
    vendorController.getVendorDetails(widget.vendorId);
  }

  // Helper to get vendor initials
  String getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return 'V';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final isLoading = vendorController.isLoading.value;
          final overview = vendorController.vendorOverview.value;

          // Show loading indicator
          if (isLoading && overview == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if no data
          if (overview == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load vendor details'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      vendorController.getVendorDetails(widget.vendorId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final vendor = overview.vendor;
          final performance = overview.performance;
          final suppliedProducts = overview.suppliedProducts;
          final pastOrders = overview.pastOrders;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 20),
                      onPressed: () => Get.back(closeOverlays: false),
                      padding: EdgeInsets.zero,
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
                            // Vendor Logo or Initials
                            Container(
                              width: width * 0.12,
                              height: width * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                                image: vendor.vendorLogo != null
                                    ? DecorationImage(
                                  image: NetworkImage(vendor.vendorLogo!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: vendor.vendorLogo == null
                                  ? Center(
                                child: Text(
                                  getInitials(vendor.name),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : null,
                            ),
                            SizedBox(width: width * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendor.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${vendor.city}, ${vendor.state} • ${vendor.categories.join(', ')}",
                                    style: const TextStyle(
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
                          child: Center(
                            child: Text(
                              "GSTIN: ${vendor.gstin}",
                              style: const TextStyle(
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
                            border: Border.all(
                                width: 1, color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("On-time delivery",
                                    style: TextStyle(fontSize: 16)),
                                const Spacer(),
                                Text(
                                  "${performance.onTimeDelivery}%",
                                  style: const TextStyle(
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
                            border: Border.all(
                                width: 1, color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Quality rating",
                                    style: TextStyle(fontSize: 16)),
                                const Spacer(),
                                Text(
                                  "${performance.qualityRating.toStringAsFixed(1)}/5",
                                  style: const TextStyle(
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

                  // Supplied Products Table
                  SuppliedProductTable(suppliedProducts: suppliedProducts),

                  // Past Orders Table
                  PastProductsTable(pastProducts: pastOrders),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}



// import 'package:dmj_stock_manager/res/components/widgets/past_products_table.dart';
// import 'package:dmj_stock_manager/res/components/widgets/supplied_product_table.dart';
// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class VendorDetailScreen extends StatefulWidget {
//   final int vendorId;
//
//   const VendorDetailScreen({
//     super.key,
//     required this.vendorId,
//   });
//
//   @override
//   State<VendorDetailScreen> createState() => _VendorDetailScreenState();
// }
//
// class _VendorDetailScreenState extends State<VendorDetailScreen> {
//   final VendorController vendorController = Get.find<VendorController>();
//
//   @override
//   void initState() {
//     super.initState();
//     // Fetch vendor details when screen loads
//     vendorController.getVendorDetails(widget.vendorId);
//   }
//
//   // Helper to get vendor initials
//   String getInitials(String name) {
//     final words = name.split(' ');
//     if (words.isEmpty) return 'V';
//     if (words.length == 1) return words[0][0].toUpperCase();
//     return '${words[0][0]}${words[1][0]}'.toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final width = Get.width;
//     final height = Get.height;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Obx(() {
//           final isLoading = vendorController.isLoading.value;
//           final overview = vendorController.vendorOverview.value;
//
//           // Show loading indicator
//           if (isLoading && overview == null) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           // Show error if no data
//           if (overview == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 60, color: Colors.red),
//                   const SizedBox(height: 16),
//                   const Text('Failed to load vendor details'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () {
//                       vendorController.getVendorDetails(widget.vendorId);
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final vendor = overview.vendor;
//           final performance = overview.performance;
//           final suppliedProducts = overview.suppliedProducts;
//           final pastOrders = overview.pastOrders;
//
//           return SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: width * 0.05),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Back Button
//                   Container(
//                     width: width * 0.1,
//                     height: width * 0.1,
//                     margin: EdgeInsets.only(top: height * 0.02),
//                     decoration: BoxDecoration(
//                       border: Border.all(width: 1, color: Colors.grey.shade500),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.arrow_back),
//                       onPressed: () {
//                         Get.back();
//                       },
//                     ),
//                   ),
//                   SizedBox(height: height * 0.02),
//
//                   // Vendor card
//                   Container(
//                     width: double.infinity,
//                     padding: EdgeInsets.all(width * 0.04),
//                     decoration: BoxDecoration(
//                       color: const Color(0xfff8f8f8),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(width: 1, color: Colors.grey.shade300),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             // Vendor Logo or Initials
//                             Container(
//                               width: width * 0.12,
//                               height: width * 0.12,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(10),
//                                 image: vendor.vendorLogo != null
//                                     ? DecorationImage(
//                                   image: NetworkImage(vendor.vendorLogo!),
//                                   fit: BoxFit.cover,
//                                 )
//                                     : null,
//                               ),
//                               child: vendor.vendorLogo == null
//                                   ? Center(
//                                 child: Text(
//                                   getInitials(vendor.name),
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               )
//                                   : null,
//                             ),
//                             SizedBox(width: width * 0.03),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     vendor.name,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "${vendor.city}, ${vendor.state} • ${vendor.categories.join(', ')}",
//                                     style: const TextStyle(
//                                       fontSize: 13,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.02),
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(
//                             vertical: height * 0.012,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "GSTIN: ${vendor.gstin}",
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   SizedBox(height: height * 0.02),
//
//                   // Stats Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: height * 0.15,
//                           decoration: BoxDecoration(
//                             color: const Color(0xfff8f8f8),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                                 width: 1, color: Colors.grey.shade300),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(width * 0.04),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text("On-time delivery",
//                                     style: TextStyle(fontSize: 16)),
//                                 const Spacer(),
//                                 Text(
//                                   "${performance.onTimeDelivery}%",
//                                   style: const TextStyle(
//                                     fontSize: 32,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: width * 0.04),
//                       Expanded(
//                         child: Container(
//                           height: height * 0.15,
//                           decoration: BoxDecoration(
//                             color: const Color(0xfff8f8f8),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                                 width: 1, color: Colors.grey.shade300),
//                           ),
//                           child: Padding(
//                             padding: EdgeInsets.all(width * 0.04),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text("Quality rating",
//                                     style: TextStyle(fontSize: 16)),
//                                 const Spacer(),
//                                 Text(
//                                   "${performance.qualityRating.toStringAsFixed(1)}/5",
//                                   style: const TextStyle(
//                                     fontSize: 32,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: height * 0.02),
//
//                   // Supplied Products Table
//                   SuppliedProductTable(suppliedProducts: suppliedProducts),
//
//                   // Past Orders Table
//                   PastProductsTable(pastProducts: pastOrders),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }