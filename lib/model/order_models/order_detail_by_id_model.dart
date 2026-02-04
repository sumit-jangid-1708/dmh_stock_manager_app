class OrderDetailByIdModel {
  final int orderId;
  final String customerName;
  final String? customerEmail;
  final DateTime createdAt;
  final List<OrderDetailItem> items;

  OrderDetailByIdModel({
    required this.orderId,
    required this.customerName,
    this.customerEmail,
    required this.createdAt,
    required this.items,
  });

  factory OrderDetailByIdModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailByIdModel(
      orderId: json['order_id'],
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((e) => OrderDetailItem.fromJson(e))
          .toList(),
    );
  }
}

class OrderDetailItem {
  final int productId;
  final String productName;
  final String sku;
  final int orderedQuantity;
  final double unitPrice;
  final int stockLeft;
  final List<OrderBarcode> barcodes;

  OrderDetailItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.stockLeft,
    required this.barcodes,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      productId: json['product_id'],
      productName: json['product_name'],
      sku: json['sku'],
      orderedQuantity: json['ordered_quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      stockLeft: json['stock_left'],
      barcodes: (json['barcodes'] as List)
          .map((e) => OrderBarcode.fromJson(e))
          .toList(),
    );
  }
}

class OrderBarcode {
  final String barcode;
  final String image;

  OrderBarcode({required this.barcode, required this.image});

  factory OrderBarcode.fromJson(Map<String, dynamic> json) {
    return OrderBarcode(barcode: json['barcode'], image: json['image']);
  }
}
