class ProductModel {
  final int id;
  final int vendor;
  final String prefixCode;
  final String name;
  final String size;
  final String color;
  final String material;
  final int? serial;
  final String sku;
  final String barcode;
  final String barcodeImage;
  final String? productImage;
  final List<String> productImageVariants;
  final double unitPurchasePrice;
  final int? hsnId;
  final String? description;
  final String? weightBefore;
  final String? weightAfter;

  // Extra fields from API (future use ke liye)
  final String? length;
  final String? width;
  final String? height;
  final String? unit;

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
    this.length,
    this.width,
    this.height,
    this.unit,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      vendor: int.tryParse(json['vendor'].toString()) ?? 0,

      prefixCode: json['prefix_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      material: json['material']?.toString() ?? '',

      serial: json['serial'] == null
          ? null
          : int.tryParse(json['serial'].toString()),

      sku: json['sku']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      barcodeImage: json['barcode_image']?.toString() ?? '',

      productImage: json['product_image']?.toString(),

      productImageVariants:
      (json['product_image_variants'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      unitPurchasePrice:
      double.tryParse(json['unit_purchase_price'].toString()) ?? 0.0,

      hsnId: json['hsn'] == null
          ? null
          : int.tryParse(json['hsn'].toString()),

      description: json['desc']?.toString(),
      weightBefore: json['weight_before']?.toString(),
      weightAfter: json['weight_after']?.toString(),

      // Extra fields added from API
      length: json['length']?.toString(),
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      unit: json['unit']?.toString(),
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
      'product_image_variants': productImageVariants,
      'unit_purchase_price': unitPurchasePrice.toStringAsFixed(2),
      'hsn': hsnId,
      'desc': description,
      'weight_before': weightBefore,
      'weight_after': weightAfter,
      'length': length,
      'width': width,
      'height': height,
      'unit': unit,
    };
  }
}

