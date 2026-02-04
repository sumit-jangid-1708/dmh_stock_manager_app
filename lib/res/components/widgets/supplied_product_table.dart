import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/vendor_model/vender_overview_model.dart';

class SuppliedProductTable extends StatelessWidget {
  final List<SuppliedProductModel> suppliedProducts;

  const SuppliedProductTable({
    super.key,
    required this.suppliedProducts,
  });

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final height = Get.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Supplied Products",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: height * 0.015),

        // Show message if no products
        if (suppliedProducts.isEmpty)
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
                "No supplied products yet",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
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
                      Expanded(flex: 4, child: Text("SKU", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13, color: Colors.white))),
                      Expanded(flex: 2, child: Text("Product", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.white))),
                      Expanded(flex: 1, child: Text("Qty", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13,color: Colors.white), textAlign: TextAlign.center,)),
                      Expanded(flex: 2, child: Text("Remainder", style: TextStyle(fontWeight: FontWeight.w600,fontSize: 13, color: Colors.white), textAlign: TextAlign.center)),
                    ],
                  ),
                ),

                // Data Rows
                ...suppliedProducts.map((product) {
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
                          flex: 4,
                          child: Text(
                            product.sku,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            product.productName,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            product.suppliedQty.toString(),
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            product.remainderQty.toString(),
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
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


// import 'package:flutter/material.dart';
//
// class SuppliedProductTable extends StatelessWidget {
//   final List<Map<String, String>> suppliedProducts;
//
//   const SuppliedProductTable({super.key, required this.suppliedProducts});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(top: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color:  Color(0xfff8f8f8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(width: 1, color: Colors.grey.shade300),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             "Supplied Products",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black,
//             ),
//           ),
//           const SizedBox(height: 12,),
//            // Table Header
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
//             decoration: BoxDecoration(
//             color: const Color(0xFF1A1A4F),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Row(
//               children: [
//                 Expanded(flex: 3, child: Text("SKU", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
//                 Expanded(flex: 5, child: Text("Product", style:TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
//                 Expanded(flex: 2, child: Text("QTY", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
//                 Expanded(flex: 3, child: Text("Remainders", style:TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white))),
//               ],
//             ),
//           ),
//           const SizedBox(height: 6),
//
//           // Table Rows
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: suppliedProducts.length,
//             itemBuilder: (context, index) {
//               final product = suppliedProducts[index];
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
//                 child: Row(
//                   children: [
//                     Expanded(flex: 3, child: Text(product["sku"] ?? "" ,style: TextStyle(fontSize: 10))),
//                     Expanded(flex: 5, child: Text(product["product"] ?? "",style: TextStyle(fontSize: 10))),
//                     Expanded(flex: 2, child: Text(product["qty"] ?? "",style: TextStyle(fontSize: 10))),
//                     Expanded(flex: 3, child: Text(product["remainders"] ?? "",style: TextStyle(fontSize: 10))),
//                   ],
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
