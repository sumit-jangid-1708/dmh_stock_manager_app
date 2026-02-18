class OrderDetailsModel {
  final int orderId;
  final String channel;
  final String channelOrderId;
  final String customerName;
  final String customerEmail;
  final String mobile;
  final String countryCode;
  final String remarks;
  final DateTime createdAt;
  final String paidStatus;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? transactionId;
  final int totalItems;
  final List<OrderItemModel> items;

  OrderDetailsModel({
    required this.orderId,
    required this.channel,
    required this.channelOrderId,
    required this.customerName,
    required this.customerEmail,
    required this.mobile,
    required this.countryCode,
    required this.remarks,
    required this.createdAt,
    required this.paidStatus,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
    required this.totalItems,
    required this.items,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      orderId: json['order_id'],
      channel: json['channel'],
      channelOrderId: json['channel_order_id'],
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      mobile: json['mobile'],
      countryCode: json['country_code'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      paidStatus: json['paid_status'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      transactionId: json['transaction_id'],
      totalItems: json['total_items'],
      items: List<OrderItemModel>.from(
        json['items'].map((x) => OrderItemModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'channel': channel,
      'channel_order_id': channelOrderId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'mobile': mobile,
      'country_code': countryCode,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'paid_status': paidStatus,
      'payment_method': paymentMethod,
      'payment_date': paymentDate?.toIso8601String(),
      'transaction_id': transactionId,
      'total_items': totalItems,
      'items': items.map((x) => x.toJson()).toList(),
    };
  }
}
class OrderItemModel {
  final int productId;
  final String productName;
  final String productSku;
  final String productBarcode;
  final String productBarcodeImage;
  final int orderedQuantity;
  final double unitPrice;
  final double totalPrice;
  final int stockLeft;
  final List<SerialModel> serials;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productBarcode,
    required this.productBarcodeImage,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.stockLeft,
    required this.serials,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'],
      productName: json['product_name'],
      productSku: json['product_sku'],
      productBarcode: json['product_barcode'],
      productBarcodeImage: json['product_barcode_image'],
      orderedQuantity: json['ordered_quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      stockLeft: json['stock_left'],
      serials: List<SerialModel>.from(
        json['serials'].map((x) => SerialModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_barcode': productBarcode,
      'product_barcode_image': productBarcodeImage,
      'ordered_quantity': orderedQuantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'stock_left': stockLeft,
      'serials': serials.map((x) => x.toJson()).toList(),
    };
  }
}
class SerialModel {
  final String serialNumber;
  final String barcodeImage;

  SerialModel({
    required this.serialNumber,
    required this.barcodeImage,
  });

  factory SerialModel.fromJson(Map<String, dynamic> json) {
    return SerialModel(
      serialNumber: json['serial_number'],
      barcodeImage: json['barcode_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial_number': serialNumber,
      'barcode_image': barcodeImage,
    };
  }
}
