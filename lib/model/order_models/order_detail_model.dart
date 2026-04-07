// lib/model/order_models/order_details_model.dart

class OrderDetailsModel {
  final int orderId;
  final String channel;
  final String channelOrderId;
  final String customerName;
  final String customerEmail;
  final String mobile;
  final String countryCode;

  // ✅ Changed: String -> List<dynamic>
  final List<OrderRemark> remarks;

  final DateTime createdAt;
  final String paidStatus;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? transactionId;
  final int totalItems;
  final List<OrderItemModel> items;

  const OrderDetailsModel({
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
      orderId: json['order_id'] is int
          ? json['order_id']
          : int.tryParse('${json['order_id']}') ?? 0,

      channel: json['channel'] ?? '',
      channelOrderId: json['channel_order_id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      mobile: json['mobile'] ?? '',
      countryCode: json['country_code'] ?? '',

      // ✅ FIXED HERE
      remarks: (json['remarks'] as List? ?? [])
          .map((e) => OrderRemark.fromJson(e))
          .toList(),

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),

      paidStatus: json['paid_status'] ?? '',
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'])
          : null,
      transactionId: json['transaction_id'],

      totalItems: json['total_items'] is int
          ? json['total_items']
          : int.tryParse('${json['total_items']}') ?? 0,

      items: json['items'] is List
          ? List<OrderItemModel>.from(
              json['items'].map((x) => OrderItemModel.fromJson(x)),
            )
          : [],
    );
  }
}

// ==================== Order Item Model ====================
class OrderItemModel {
  final int productId;
  final String productName;
  final String productSku;
  final String productBarcode;
  final String? productBarcodeImage;
  final String? productImage;
  final List<String> productImageVariants;
  final int vendorId;
  final String vendorName;
  final int orderedQuantity;
  final double unitPrice;
  final double totalPrice;
  final int stockLeft;
  final List<SerialModel> serials;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productBarcode,
    this.productBarcodeImage,
    this.productImage,
    required this.productImageVariants,
    required this.vendorId,
    required this.vendorName,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.stockLeft,
    required this.serials,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse('${json['product_id']}') ?? 0,

      productName: json['product_name'] ?? '',
      productSku: json['product_sku'] ?? '',
      productBarcode: json['product_barcode'] ?? '',
      productBarcodeImage: json['product_barcode_image'],
      productImage: json['product_image'],

      productImageVariants: json['product_image_variants'] is List
          ? List<String>.from(json['product_image_variants'])
          : [],

      vendorId: json['vendor_id'] is int
          ? json['vendor_id']
          : int.tryParse('${json['vendor_id']}') ?? 0,

      vendorName: json['vendor_name'] ?? '',

      orderedQuantity: json['ordered_quantity'] is int
          ? json['ordered_quantity']
          : int.tryParse('${json['ordered_quantity']}') ?? 0,

      unitPrice: _parseDouble(json['unit_price']),
      totalPrice: _parseDouble(json['total_price']),

      stockLeft: json['stock_left'] is int
          ? json['stock_left']
          : int.tryParse('${json['stock_left']}') ?? 0,

      serials: json['serials'] is List
          ? List<SerialModel>.from(
              json['serials'].map((x) => SerialModel.fromJson(x)),
            )
          : [],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

// ==================== Serial Model ====================
class SerialModel {
  final String serialNumber;
  final String barcodeImage;

  const SerialModel({required this.serialNumber, required this.barcodeImage});

  factory SerialModel.fromJson(Map<String, dynamic> json) {
    return SerialModel(
      serialNumber: json['serial_number'] ?? '',
      barcodeImage: json['barcode_image'] ?? '',
    );
  }
}

class OrderRemark {
  final int id;
  final String remark;
  final DateTime createdAt;

  OrderRemark({
    required this.id,
    required this.remark,
    required this.createdAt,
  });

  factory OrderRemark.fromJson(Map<String, dynamic> json) {
    return OrderRemark(
      id: json['id'] ?? 0,
      remark: json['remark'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

