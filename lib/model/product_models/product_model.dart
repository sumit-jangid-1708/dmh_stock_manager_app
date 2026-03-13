// lib/model/product_models/product_model.dart

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
  final int? hsnId;
  final String? description;
  final String? weightBefore; // ✅ Added
  final String? weightAfter;  // ✅ Added

  String get purchasePrice => unitPurchasePrice;

  /// This returns only the SKU entered at product creation time
  String get baseSku {
    final parts = sku.split('-');
    if (parts.length > 4) {
      return parts.sublist(0, parts.length - 4).join('-');
    }
    return sku;
  }

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
    this.hsnId,
    this.description,
    this.weightBefore, // ✅ Added
    this.weightAfter,  // ✅ Added
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
      productImageVariants:
      (json['product_image_variants'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      unitPurchasePrice: json['unit_purchase_price']?.toString() ?? '0.00',
      hsnId: json['hsn'],
      description: json['desc'],
      weightBefore: json['weight_before']?.toString(), // ✅ Added
      weightAfter: json['weight_after']?.toString(),   // ✅ Added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor': vendor,
      'prefix_code': prefixCode,
      'name': name,
      'size': size,
      'color': color,
      'material': material,
      'serial': serial,
      'sku': sku,
      'barcode': barcode,
      'barcode_image': barcodeImage,
      'product_image_variants': productImageVariants,
      'unit_purchase_price': unitPurchasePrice,
      'hsn': hsnId,
      'desc': description,
      'weight_before': weightBefore, // ✅ Added
      'weight_after': weightAfter,   // ✅ Added
    };
  }
}
