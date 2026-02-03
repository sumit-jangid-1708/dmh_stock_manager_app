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
  final Color primaryColor = const Color(0xFF1A1A4F);

  @override
  void initState() {
    super.initState();
    vendorController.getVendorDetails(widget.vendorId);
  }

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
      backgroundColor: const Color(0xFFF9FAFB), // Softer background
      body: SafeArea(
        child: Obx(() {
          final isLoading = vendorController.isLoading.value;
          final overview = vendorController.vendorOverview.value;

          if (isLoading && overview == null) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

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
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: () => vendorController.getVendorDetails(widget.vendorId),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final vendor = overview.vendor;
          final stats = overview.stats;
          final suppliedProducts = overview.suppliedProducts;
          final pastOrders = overview.pastOrders;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button (Premium Style)
                  GestureDetector(
                    onTap: () => Get.back(closeOverlays: false),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: primaryColor),
                    ),
                  ),
                  SizedBox(height: height * 0.025),

                  // ✨ Enhanced Vendor Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(width * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: primaryColor.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                image: vendor.vendorLogo != null
                                    ? DecorationImage(image: NetworkImage(vendor.vendorLogo!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: vendor.vendorLogo == null
                                  ? Center(
                                child: Text(getInitials(vendor.name),
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                              )
                                  : null,
                            ),
                            SizedBox(width: width * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vendor.name,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.business, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(vendor.firm,
                                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.02),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              "GSTIN: ${vendor.gstin}",
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              // Phone
                              if (vendor.mobile.isNotEmpty)
                                _buildInfoRow(
                                  Icons.phone,
                                  vendor.mobile,
                                  Colors.blue,
                                ),

                              // Email
                              if (vendor.email.isNotEmpty) ...[
                                SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.email,
                                  vendor.email,
                                  Colors.orange,
                                ),
                              ],

                              // Address
                              if (vendor.address.isNotEmpty ) ...[
                                SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.location_on,
                                  vendor.address,
                                  Colors.red,
                                ),
                              ],

                              // City/State/Country
                              if (vendor.city.isNotEmpty && vendor.state.isNotEmpty && vendor.country.isNotEmpty) ...[
                                SizedBox(height: 10),
                                _buildInfoRow(
                                  Icons.public,
                                  "${vendor.city}, ${vendor.state}, ${vendor.country}",
                                  Colors.purple,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: height * 0.03),

                  // ✨ NEW: Attractive Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      _buildStatItem("Bills", "${stats.totalBillsGenerated}", Icons.receipt_long_outlined, Colors.blue),
                      _buildStatItem("Purchases", "${stats.totalProductsPurchased}", Icons.shopping_bag_outlined, Colors.orange),
                      _buildStatItem("Business", "₹${stats.totalBusinessAmount}", Icons.auto_graph_rounded, Colors.green),
                    ],
                  ),

                  SizedBox(height: height * 0.03),

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

  // ✨ Helper Widget for Grid Stat Items
  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F))),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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