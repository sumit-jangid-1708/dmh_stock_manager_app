class InventoryModel{
  final int id;
  final int quantity;
  final int product;

  InventoryModel({
    required this.id,
    required this.quantity,
    required this.product,
});

  factory InventoryModel.formJson(Map<String, dynamic> json){
    return InventoryModel(
        id: json["id"],
        quantity: json["quantity"],
        product: json["product"],
    );
  }
}