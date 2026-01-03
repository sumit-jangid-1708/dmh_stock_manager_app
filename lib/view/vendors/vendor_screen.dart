import 'package:dmj_stock_manager/res/components/widgets/add_vendor_form.dart';
import 'package:dmj_stock_manager/res/components/widgets/vedor_card.dart';
import 'package:dmj_stock_manager/view/vendors/vendor_detail_screen.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorScreen extends StatelessWidget {
  final VendorController vendorController = Get.put(VendorController());

  VendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          color: Color(0xFF1A1A4F),
          onRefresh: () async {
            await vendorController.getVendors();
          },
          child: Column(
            children: [
              // 🎨 Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Vendors",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A4F),
                              ),
                            ),
                            SizedBox(height: 4),
                            Obx(() => Text(
                              "${vendorController.vendors.length} vendors registered",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            )),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1A1A4F).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  elevation: 10,
                                  context: context,
                                  isScrollControlled: true,
                                  // backgroundColor: Colors.transparent,
                                  builder: (context) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.8,
                                      child: AddVendorFormBottomSheet(),
                                    );
                                  },
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Add Vendor",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // 🔍 Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: vendorController.searchBar,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search, color: Color(0xFF1A1A4F)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              vendorController.searchBar.clear();
                              vendorController.filteredVendors.assignAll(
                                vendorController.vendors,
                              );
                            },
                            icon: Icon(Icons.close, color: Colors.grey),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          hintText: "Search vendors...",
                          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4),

              // 📊 Stats Bar
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Container(
              //     padding: EdgeInsets.all(16),
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           Color(0xFF1A1A4F).withOpacity(0.1),
              //           Color(0xFF2D2D7F).withOpacity(0.05),
              //         ],
              //       ),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Color(0xFF1A1A4F).withOpacity(0.2)),
              //     ),
              //     child: Row(
              //       children: [
              //         Container(
              //           padding: EdgeInsets.all(10),
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(
              //               colors: [Color(0xFF1A1A4F), Color(0xFF2D2D7F)],
              //             ),
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           child: Icon(Icons.people, color: Colors.white, size: 20),
              //         ),
              //         SizedBox(width: 12),
              //         Expanded(
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 "Total Vendors",
              //                 style: TextStyle(
              //                   fontSize: 12,
              //                   color: Colors.grey.shade600,
              //                 ),
              //               ),
              //               SizedBox(height: 2),
              //               Obx(() => Text(
              //                 "${vendorController.vendors.length} Active",
              //                 style: TextStyle(
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                   color: Color(0xFF1A1A4F),
              //                 ),
              //               )),
              //             ],
              //           ),
              //         ),
              //         Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              //       ],
              //     ),
              //   ),
              // ),

              SizedBox(height: 16),

              // 📋 Vendor List
              Expanded(
                child: Obx(() {
                  final vendors = vendorController.filteredVendors;

                  if (vendors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No vendors found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Add your first vendor to get started",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return InkWell(
                        onTap: () {
                          Get.to(() => VendorDetailScreen(vendorId: vendor.id));
                        },
                        child: VendorCard(
                          initials: vendor.vendorName.isNotEmpty
                              ? vendor.vendorName.substring(0, 2).toUpperCase()
                              : "NA",
                          vendorName: vendor.vendorName,
                          phoneNumber: vendor.phoneNumber,
                          countryCode: vendor.countryCode,
                          email: vendor.email,
                          address: vendor.address,
                          city: vendor.city,
                          state: vendor.state,
                          country: vendor.country.isNotEmpty ? vendor.country : "N/A",
                          pinCode: vendor.pinCode,
                          firmName: vendor.firmName,
                          gstNumber: vendor.gstNumber,
                          isExpanded: vendorController.expandedList[index],
                          onToggle: () => vendorController.toggleVendor(index),
                          onDelete: () {},
                          onEdit: () {},
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// import 'package:dmj_stock_manager/res/components/widgets/add_vendor_form.dart';
// import 'package:dmj_stock_manager/res/components/widgets/vedor_card.dart';
// import 'package:dmj_stock_manager/res/routes/routes_names.dart';
// import 'package:dmj_stock_manager/view/vendors/vendor_detail_screen.dart';
// import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class VendorScreen extends StatelessWidget {
//   final VendorController vendorController = Get.put(VendorController());
//
//   VendorScreen({super.key}) {}
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: RefreshIndicator(
//           onRefresh: ()async {
//            await vendorController.getVendors();
//           },
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Vendors",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF1A1A4F),
//                         foregroundColor: Colors.white,
//                         fixedSize: Size(140, 40),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         showModalBottomSheet(
//                             elevation: 10,
//                           context: context,
//                           isScrollControlled: true,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(20),
//                             ),
//                           ),
//                           builder: (context) {
//                             return SizedBox(
//                               height: MediaQuery
//                                   .of(context)
//                                   .size
//                                   .height * 0.8, // 👈 fix height 60%
//                               child: AddVendorFormBottomSheet(),
//                             );
//                           }
//                         );
//                       },
//
//                       child: Text("+ Add Vendor"),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: TextFormField(
//                   controller: vendorController.searchBar,
//                   decoration: InputDecoration(
//
//                     prefixIcon: const Icon(Icons.search),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         vendorController.searchBar.clear();
//                         vendorController.filteredVendors.assignAll(
//                           vendorController.vendors,
//                         );
//                       },
//                       icon: const Icon(Icons.close),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey.withOpacity(0.1),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none
//                     ),
//                     hintText: "Search",
//                   ),
//                 ),
//               ),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Container(
//                   padding: EdgeInsets.all(10),
//                   width: double.infinity,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text("Vendors", style: TextStyle(fontSize: 15)),
//                       Obx(()=>Text("${vendorController.vendors.length} Vendors Listed", style: TextStyle(fontSize: 15)),)
//                     ],
//                   ),
//                 ),
//               ),
//
//               //Vendor Lists
//               Expanded(
//                 child: Obx(() {
//                   final vendors = vendorController.filteredVendors;
//                   return ListView.builder(
//                     itemCount: vendors.length,
//                     itemBuilder: (context, index) {
//                       final vendor = vendors[index];
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 10),
//                         child: InkWell(
//                           onTap: (){
//                             // Get.toNamed(RouteName.vendorDetailScreen);
//                             Get.to(() => VendorDetailScreen(vendorId: vendor.id));
//                           },
//                           child: VendorCard(
//                             initials: vendor.vendorName.isNotEmpty
//                                 ? vendor.vendorName.substring(0, 2).toUpperCase()
//                                 : "NA",
//                             vendorName: vendor.vendorName,
//                             phoneNumber: vendor.phoneNumber,
//                             countryCode: vendor.countryCode,
//                             email: vendor.email,
//                             address: vendor.address,
//                             city: vendor.city,
//                             state: vendor.state,
//                             country:vendor.country.isNotEmpty ? vendor.country: "N/A",
//                             pinCode: vendor.pinCode,
//                             firmName: vendor.firmName,
//                             gstNumber: vendor.gstNumber,
//                             isExpanded: vendorController.expandedList[index],
//                             onToggle: () => vendorController.toggleVendor(index),
//                             onDelete: () {},
//                             onEdit: () {},
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
