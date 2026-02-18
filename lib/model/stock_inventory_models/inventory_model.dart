// class InventoryModel{
//   final int id;
//   final int quantity;
//   final int product;
//
//   InventoryModel({
//     required this.id,
//     required this.quantity,
//     required this.product,
// });
//
//   factory InventoryModel.formJson(Map<String, dynamic> json){
//     return InventoryModel(
//         id: json["id"],
//         quantity: json["quantity"],
//         product: json["product"],
//     );
//   }
// }



class InventoryModel {
  final int? id;   // optional bana diya
  final int quantity;
  final int product;
  final String? serialsFrom;
  final String? serialsTo;
  final List<String> serials;

  InventoryModel({
    this.id,
    required this.quantity,
    required this.product,
    this.serialsFrom,
    this.serialsTo,
    required this.serials,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json["id"],
      quantity: json["quantity"] ?? 0,
      product: json["product"] ?? 0,
      serialsFrom: json["serials_from"],
      serialsTo: json["serials_to"],
      serials: json["serials"] != null
          ? List<String>.from(json["serials"])
          : [],
    );
  }
}
