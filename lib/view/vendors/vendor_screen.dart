import 'package:dmj_stock_manager/res/components/widgets/add_vendor_form.dart';
import 'package:dmj_stock_manager/res/components/widgets/vedor_card.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/view_models/controller/vendor_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorScreen extends StatelessWidget {
  final VendorController vendorController = Get.put(VendorController());

  VendorScreen({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: ()async {
           await vendorController.getVendors();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Vendors",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A4F),
                        foregroundColor: Colors.white,
                        fixedSize: Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                            elevation: 10,
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.8, // 👈 fix height 60%
                              child: AddVendorFormBottomSheet(),
                            );
                          }
                        );
                      },

                      child: Text("+ Add Vendor"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextFormField(
                  controller: vendorController.searchBar,
                  decoration: InputDecoration(

                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        vendorController.searchBar.clear();
                        vendorController.filteredVendors.assignAll(
                          vendorController.vendors,
                        );
                      },
                      icon: const Icon(Icons.close),
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none
                    ),
                    hintText: "Search",
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vendors", style: TextStyle(fontSize: 15)),
                      Obx(()=>Text("${vendorController.vendors.length} Vendors Listed", style: TextStyle(fontSize: 15)),)
                    ],
                  ),
                ),
              ),

              //Vendor Lists
              Expanded(
                child: Obx(() {
                  final vendors = vendorController.filteredVendors;
                  return ListView.builder(
                    itemCount: vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = vendors[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          onTap: (){
                            Get.toNamed(RouteName.vendorDetailScreen);
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
                            country:vendor.country.isNotEmpty ? vendor.country: "N/A",
                            pinCode: vendor.pinCode,
                            firmName: vendor.firmName,
                            gstNumber: vendor.gstNumber,
                            isExpanded: vendorController.expandedList[index],
                            onToggle: () => vendorController.toggleVendor(index),
                            onDelete: () {},
                            onEdit: () {},
                          ),
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
