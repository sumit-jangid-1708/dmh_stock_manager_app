// import 'package:dmj_stock_manager/view_models/controller/stock_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class AddStockForm extends StatelessWidget {
//    AddStockForm({super.key});
//  final controller = Get.put(StockController());
//
//   final _fieldBorder = OutlineInputBorder(
//     borderRadius: BorderRadius.circular(8),
//     borderSide: const BorderSide(color: Colors.grey),
//   );
//
//   InputDecoration _inputDecoration() {
//     return InputDecoration(
//       // labelText: label,
//       border: _fieldBorder,
//       enabledBorder: _fieldBorder,
//       focusedBorder: _fieldBorder.copyWith(
//         borderSide: const BorderSide(color: Color(0xFF1A1A4F), width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Add Stock",
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Form(
//                   key: controller.formKey,
//                   child: Column(
//                     children: [
//                       // Row 1: SKU & Size
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("SKU", style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.skuController,
//                                   decoration: _inputDecoration().copyWith(
//                                     hintText: "e.g. DF-001",
//                                   ),
//                                   validator: (value) => value!.isEmpty ? "Required" : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Size", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 Obx(
//                                   () => DropdownButtonFormField<String>(
//                                     value: controller.size.value,
//                                     decoration: _inputDecoration(),
//                                     items: controller.sizeList
//                                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                                         .toList(),
//                                     onChanged: (value) => controller.size.value = value,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Row 2: Total Stock Count & Reminder Limit
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Total Stock Count", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.totalStockController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Reminder Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.reminderLimitController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Row 3: Material & Shape
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Material", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 Obx(
//                                   () => DropdownButtonFormField<String>(
//                                     value: controller.material.value,
//                                     decoration: _inputDecoration(),
//                                     items: controller.materialList
//                                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                                         .toList(),
//                                     onChanged: (value) => controller.material.value = value,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Shape", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 Obx(
//                                   () => DropdownButtonFormField<String>(
//                                     value: controller.shape.value,
//                                     decoration: _inputDecoration(),
//                                     items: controller.shapeList
//                                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                                         .toList(),
//                                     onChanged: (value) => controller.shape.value = value,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Row 4: Color & Quantity
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Color", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.colorController,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Quantity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.quantityController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                   validator: (value) => value!.isEmpty ? "Required" : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Row 5: Unit & Purchase Price
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Unit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 Obx(
//                                   () => DropdownButtonFormField<String>(
//                                     value: controller.unit.value,
//                                     decoration: _inputDecoration(),
//                                     items: controller.unitList
//                                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                                         .toList(),
//                                     onChanged: (value) => controller.unit.value = value,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Purchase Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.purchasePriceController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Row 6: Selling Price & Reminder Limit
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                                crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Selling Price", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.sellingPriceController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Reminder Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                                 SizedBox(height: 6,),
//                                 TextFormField(
//                                   controller: controller.reminderLimitController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: _inputDecoration(),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Image Upload
//                       Column(
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Image", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                           SizedBox(height: 6,),
//                           Container(
//                             height: 120,
//                             width: double.infinity,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             alignment: Alignment.center,
//                             child: const Icon(Icons.cloud_upload, size: 40, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Save Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF1A1A4F),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           onPressed: controller.saveStock,
//                           child: const Text(
//                             "Save",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }