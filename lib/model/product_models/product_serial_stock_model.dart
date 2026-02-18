

class ProductSerialStockModel {
  final int productId;
  final String productName;
  final String productSku;
  final int totalAvailable;
  final int returnedCount;
  final int remainingStock;
  final List<ProductSerialModel> serials;

  ProductSerialStockModel({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.totalAvailable,
    required this.returnedCount,
    required this.remainingStock,
    required this.serials,
  });

  factory ProductSerialStockModel.fromJson(Map<String, dynamic> json) {
    return ProductSerialStockModel(
      productId: json['product_id'],
      productName: json['product_name'],
      productSku: json['product_sku'] ?? '',
      totalAvailable: json['total_available'] ?? 0,
      returnedCount: json['returned_count'] ?? 0,
      remainingStock: json['remaining_stock'] ?? 0,
      serials: List<ProductSerialModel>.from(
        (json['serials'] ?? []).map((x) => ProductSerialModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'total_available': totalAvailable,
      'returned_count': returnedCount,
      'remaining_stock': remainingStock,
      'serials': serials.map((x) => x.toJson()).toList(),
    };
  }
}

class ProductSerialModel {
  final String serialNumber;
  final String barcodeImage;

  ProductSerialModel({
    required this.serialNumber,
    required this.barcodeImage,
  });

  factory ProductSerialModel.fromJson(Map<String, dynamic> json) {
    return ProductSerialModel(
      serialNumber: json['serial_number'],
      barcodeImage: json['barcode_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial_number': serialNumber,
      'barcode_image': barcodeImage,
    };
  }
}