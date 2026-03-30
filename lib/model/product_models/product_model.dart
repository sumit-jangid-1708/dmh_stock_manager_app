
// lib/model/product_models/product_model.dart

class ProductModel {
  final int id;
  final int vendor;
  final String prefixCode;
  final String name;
  final String size;
  final String color;
  final String material;
  final int? serial; // ✅ Null safe
  final String sku;
  final String barcode;
  final String barcodeImage;
  final String? productImage;
  final List<ProductImageVariant> productImageVariants;
  final String unitPurchasePrice;
  final int? hsnId;
  final String? description;
  final String? weightBefore;
  final String? weightAfter;

  String get purchasePrice => unitPurchasePrice;

  /// Base SKU without serial part
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
    this.serial,
    required this.sku,
    required this.barcode,
    required this.barcodeImage,
    this.productImage,
    required this.productImageVariants,
    required this.unitPurchasePrice,
    this.hsnId,
    this.description,
    this.weightBefore,
    this.weightAfter,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      vendor: json['vendor'] is int
          ? json['vendor']
          : int.tryParse(json['vendor']?.toString() ?? '0') ?? 0,

      prefixCode: json['prefix_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      material: json['material']?.toString() ?? '',

      serial: json['serial'] == null
          ? null
          : (json['serial'] is int
          ? json['serial']
          : int.tryParse(json['serial'].toString())),

      sku: json['sku']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      barcodeImage: json['barcode_image']?.toString() ?? '',

      productImage: json['product_image']?.toString(),

      productImageVariants:
      (json['product_image_variants'] as List<dynamic>?)
          ?.map((e) =>
          ProductImageVariant.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],

      unitPurchasePrice:
      json['unit_purchase_price']?.toString() ?? '0.00',

      hsnId: json['hsn'] is int
          ? json['hsn']
          : int.tryParse(json['hsn']?.toString() ?? ''),

      description: json['desc']?.toString(),

      weightBefore: json['weight_before']?.toString(),
      weightAfter: json['weight_after']?.toString(),
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
      'product_image': productImage,
      'product_image_variants':
      productImageVariants.map((e) => e.toJson()).toList(),
      'unit_purchase_price': unitPurchasePrice,
      'hsn': hsnId,
      'desc': description,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
    };
  }
}

class ProductImageVariant {
  final int index;
  final String url;

  ProductImageVariant({
    required this.index,
    required this.url,
  });

  factory ProductImageVariant.fromJson(Map<String, dynamic> json) {
    return ProductImageVariant(
      index: json['index'] is int
          ? json['index']
          : int.tryParse(json['index']?.toString() ?? '0') ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "index": index,
      "url": url,
    };
  }
}

// class ProductModel {
//   final int id;
//   final int vendor;
//   final String prefixCode;
//   final String name;
//   final String size;
//   final String color;
//   final String material;
//   final int? serial; // ✅ NULL SAFE
//   final String sku;
//   final String barcode;
//   final String barcodeImage;
//   final List<String> productImageVariants;
//   final String unitPurchasePrice;
//   final int? hsnId;
//   final String? description;
//   final String? weightBefore;
//   final String? weightAfter;
//
//   String get purchasePrice => unitPurchasePrice;
//
//   String get baseSku {
//     final parts = sku.split('-');
//     if (parts.length > 4) {
//       return parts.sublist(0, parts.length - 4).join('-');
//     }
//     return sku;
//   }
//
//   ProductModel({
//     required this.id,
//     required this.vendor,
//     required this.prefixCode,
//     required this.name,
//     required this.size,
//     required this.color,
//     required this.material,
//     this.serial, // ✅ nullable
//     required this.sku,
//     required this.barcode,
//     required this.barcodeImage,
//     required this.productImageVariants,
//     required this.unitPurchasePrice,
//     this.hsnId,
//     this.description,
//     this.weightBefore,
//     this.weightAfter,
//   });
//
//   factory ProductModel.fromJson(Map<String, dynamic> json) {
//     return ProductModel(
//       id: json['id'] ?? 0,
//       vendor: json['vendor'] ?? 0,
//       prefixCode: json['prefix_code'] ?? '',
//       name: json['name'] ?? '',
//       size: json['size'] ?? '',
//       color: json['color'] ?? '',
//       material: json['material'] ?? '',
//       serial: json['serial'], // ✅ safe
//       sku: json['sku'] ?? '',
//       barcode: json['barcode'] ?? '',
//       barcodeImage: json['barcode_image'] ?? '',
//       productImageVariants:
//           (json['product_image_variants'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [],
//       unitPurchasePrice: json['unit_purchase_price']?.toString() ?? '0.00',
//       hsnId: json['hsn'],
//       description: json['desc'],
//       weightBefore: json['weight_before']?.toString(),
//       weightAfter: json['weight_after']?.toString(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'vendor': vendor,
//       'prefix_code': prefixCode,
//       'name': name,
//       'size': size,
//       'color': color,
//       'material': material,
//       'serial': serial,
//       'sku': sku,
//       'barcode': barcode,
//       'barcode_image': barcodeImage,
//       'product_image_variants': productImageVariants,
//       'unit_purchase_price': unitPurchasePrice,
//       'hsn': hsnId,
//       'desc': description,
//       'weight_before': weightBefore, // ✅ Added
//       'weight_after': weightAfter, // ✅ Added
//     };
//   }
// }
