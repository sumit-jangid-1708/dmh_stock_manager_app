class ProductModel {
  final int id;
  final int vendor;
  final String prefixCode;
  final String name;
  final String size;
  final String color;
  final String material;
  final int serial;
  final String sku;
  final String barcode;
  final String barcodeImage;
  final List<String> productImageVariants;
  final String unitPurchasePrice;
  final String? hsnCode; // ✅ nullable because API sends null

  // Convenience getter (fine to keep)
  String get purchasePrice => unitPurchasePrice;

  ProductModel({
    required this.id,
    required this.vendor,
    required this.prefixCode,
    required this.name,
    required this.size,
    required this.color,
    required this.material,
    required this.serial,
    required this.sku,
    required this.barcode,
    required this.barcodeImage,
    required this.productImageVariants,
    required this.unitPurchasePrice,
    this.hsnCode,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      vendor: json['vendor'],
      prefixCode: json['prefix_code'],
      name: json['name'],
      size: json['size'],
      color: json['color'],
      material: json['material'],
      serial: json['serial'],
      sku: json['sku'],
      barcode: json['barcode'],
      barcodeImage: json['barcode_image'],
      // productImageVariants: json["product_image_variants"] ?? [],
      productImageVariants:
      (json['product_image_variants'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      unitPurchasePrice: json['unit_purchase_price']?.toString() ?? '0.00',
      hsnCode: json['hsn'].toString(), // ✅ null-safe
    );
  }
}



// class ProductModel {
//   int id;
//   String prefixCode;
//   String name;
//   String size;
//   String color;
//   String material;
//   int serial;
//   String sku;
//   String barcode;
//   String barcodeImage;
//   int vendor;
//
//   ProductModel({
//     required this.id,
//     required this.prefixCode,
//     required this.name,
//     required this.size,
//     required this.color,
//     required this.material,
//     required this.serial,
//     required this.sku,
//     required this.barcode,
//     required this.barcodeImage,
//     required this.vendor
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json){
//     return ProductModel(
//       id: json["id"],
//       prefixCode: json["prefix_code"],
//       name: json["name"],
//       size: json["size"],
//       color: json["color"],
//       material: json["material"],
//       serial: json["serial"],
//       sku: json["sku"],
//       barcode: json["barcode"],
//       barcodeImage: json["barcode_image"],
//       vendor: json["vendor"],
//       );
//   }
//
//   get purchasePrice => null;
// }
