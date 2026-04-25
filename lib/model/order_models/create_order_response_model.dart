class CreateOrderResponseModel {
  final String message;
  final int orderId;
  final String totalAmount;
  final String paidAmount;
  final String remainingAmount;
  final String paymentStatus;

  final OrderModel order;
  final List<RemarkModel> remarks;
  final List<AllocatedSerialModel> allocatedSerials;

  CreateOrderResponseModel({
    required this.message,
    required this.orderId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.order,
    required this.remarks,
    required this.allocatedSerials,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseModel(
      message: json['message'] ?? '',
      orderId: json['order_id'] ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      remainingAmount: json['remaining_amount']?.toString() ?? '0.00',
      paymentStatus: json['payment_status'] ?? '',

      order: OrderModel.fromJson(json['order'] ?? {}),

      remarks: (json['remarks'] as List? ?? [])
          .map((e) => RemarkModel.fromJson(e))
          .toList(),

      allocatedSerials: (json['allocated_serials'] as List? ?? [])
          .map((e) => AllocatedSerialModel.fromJson(e))
          .toList(),
    );
  }
}

class OrderModel {
  final int id;
  final List<OrderItemModel> items;
  final List<RemarkModel> remarks;
  final LatestStatusModel? latestStatus;

  final String status;
  final int orderStatus;
  final String packageExpence;
  final String totalAmount;
  final String paidAmount;

  final String customerName;
  final String? customerEmail;
  final String countryCode;
  final String mobile;

  final DateTime createdAt;

  final String? channelOrderId;
  final String? paymentMethod;
  final String? buyerShipmentCharger;

  final DateTime? paymentDate;
  final String paidStatus;

  final bool isDeleted;
  final String? transactionId;
  final int channel;

  OrderModel({
    required this.id,
    required this.items,
    required this.remarks,
    required this.latestStatus,
    required this.status,
    required this.orderStatus,
    required this.packageExpence,
    required this.totalAmount,
    required this.paidAmount,
    required this.customerName,
    required this.countryCode,
    required this.mobile,
    required this.createdAt,
    required this.paidStatus,
    required this.isDeleted,
    required this.channel,
    this.customerEmail,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
    this.buyerShipmentCharger,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,

      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),

      remarks: (json['remarks'] as List? ?? [])
          .map((e) => RemarkModel.fromJson(e))
          .toList(),

      latestStatus: json['latest_status'] != null
          ? LatestStatusModel.fromJson(json['latest_status'])
          : null,

      status: json['status'] ?? 'ACTIVE',
      orderStatus: json['order_status'] ?? 0,
      packageExpence: json['package_expence']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',

      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'],
      countryCode: json['country_code'] ?? '',
      mobile: json['mobile'] ?? '',

      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),

      channelOrderId: json['channel_order_id'],
      paymentMethod: json['payment_method'],
      buyerShipmentCharger: json['buyer_shipment_charger']?.toString(),

      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'])
          : null,

      paidStatus: json['paid_status'] ?? 'PENDING',
      isDeleted: json['is_deleted'] ?? false,
      transactionId: json['transaction_id'],
      channel: json['channel'] ?? 0,
    );
  }
}

class OrderItemModel {
  final int id;
  final ProductsModel product;
  final int quantity;
  final String unitPrice;

  OrderItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      product: ProductsModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
    );
  }
}

class ProductsModel {
  final int id;
  final String name;
  final String sku;
  final String? image;

  ProductsModel({
    required this.id,
    required this.name,
    required this.sku,
    this.image,
  });

  factory ProductsModel.fromJson(Map<String, dynamic> json) {
    return ProductsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      image: (json['product_image_variants'] as List?)?.isNotEmpty == true
          ? json['product_image_variants'][0]
          : null,
    );
  }
}

class RemarkModel {
  final int id;
  final String remark;
  final DateTime createdAt;

  RemarkModel({
    required this.id,
    required this.remark,
    required this.createdAt,
  });

  factory RemarkModel.fromJson(Map<String, dynamic> json) {
    return RemarkModel(
      id: json['id'] ?? 0,
      remark: json['remark'] ?? '',
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class LatestStatusModel {
  final int status;
  final String note;
  final DateTime createdAt;

  LatestStatusModel({
    required this.status,
    required this.note,
    required this.createdAt,
  });

  factory LatestStatusModel.fromJson(Map<String, dynamic> json) {
    return LatestStatusModel(
      status: json['status'] ?? 0,
      note: json['note'] ?? '',
      createdAt:
      DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class AllocatedSerialModel {
  final int productId;
  final String productName;
  final int quantity;
  final String unitPrice;
  final List<String> serials;

  AllocatedSerialModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.serials,
  });

  factory AllocatedSerialModel.fromJson(Map<String, dynamic> json) {
    return AllocatedSerialModel(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      serials: (json['serials'] as List?)?.cast<String>() ?? [],
    );
  }
}


// class CreateOrderResponseModel {
//   final OrderModel order;
//   final List<AllocatedSerialModel> allocatedSerials;
//   final String message;
//
//   CreateOrderResponseModel({
//     required this.order,
//     required this.allocatedSerials,
//     required this.message,
//   });
//
//   factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
//     return CreateOrderResponseModel(
//       message: json['message'] ?? '',
//       order: OrderModel.fromJson(json['order']),
//       allocatedSerials: (json['allocated_serials'] as List? ?? [])
//           .map((e) => AllocatedSerialModel.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// // ✅ allocated_barcodes → allocated_serials (API response change)
// class AllocatedSerialModel {
//   final int productId;
//   final String productName;
//   final int quantity;
//   final List<String> serials;
//
//   AllocatedSerialModel({
//     required this.productId,
//     required this.productName,
//     required this.quantity,
//     required this.serials,
//   });
//
//   factory AllocatedSerialModel.fromJson(Map<String, dynamic> json) {
//     return AllocatedSerialModel(
//       productId: json['product_id'] ?? 0,
//       productName: json['product_name'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       serials: (json['serials'] as List?)?.cast<String>() ?? [],
//     );
//   }
// }
//
// class OrderModel {
//   final int id;
//   final List<OrderItemSimple> items;
//   final List<AllocatedSerialModel> allocatedSerials;
//   final String customerName;
//   final DateTime createdAt;
//   final String status;
//   final int orderStatus;
//   final String packageExpence;
//   final String totalAmount;
//   final String paidAmount;
//   final String? customerEmail;
//   final String countryCode;
//   final String mobile;
//   final String? channelOrderId;
//   final String? paymentMethod;
//   final DateTime? paymentDate;
//   final String paidStatus;
//   final bool isDeleted;
//   final String? transactionId;
//   final int channel;
//
//   // ✅ Status helpers — same as OrderDetailModel
//   String get orderStatusText {
//     switch (orderStatus) {
//       case 1: return "In Process";
//       case 2: return "Packed";
//       case 3: return "In Transit";
//       case 4: return "Delivered";
//       case 5: return "Courier Return";
//       case 6: return "Customer Return";
//       default: return "Unknown";
//     }
//   }
//
//   OrderModel({
//     required this.id,
//     required this.items,
//     required this.allocatedSerials,
//     required this.customerName,
//     required this.createdAt,
//     required this.status,
//     required this.orderStatus,
//     required this.packageExpence,
//     required this.totalAmount,
//     required this.paidAmount,
//     required this.countryCode,
//     required this.mobile,
//     required this.paidStatus,
//     required this.isDeleted,
//     required this.channel,
//     this.customerEmail,
//     this.channelOrderId,
//     this.paymentMethod,
//     this.paymentDate,
//     this.transactionId,
//   });
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json['id'] ?? 0,
//       items: (json['items'] as List? ?? [])
//           .map((e) => OrderItemSimple.fromJson(e))
//           .toList(),
//       allocatedSerials: (json['allocated_serials'] as List? ?? [])
//           .map((e) => AllocatedSerialModel.fromJson(e))
//           .toList(),
//       customerName: json['customer_name'] ?? '',
//       createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
//       status: json['status'] ?? 'ACTIVE',
//       orderStatus: json['order_status'] ?? 0,
//       packageExpence: json['package_expence']?.toString() ?? '0.00',
//       totalAmount: json['total_amount']?.toString() ?? '0.00',
//       paidAmount: json['paid_amount']?.toString() ?? '0.00',
//       customerEmail: json['customer_email'],
//       countryCode: json['country_code'] ?? '',
//       mobile: json['mobile'] ?? '',
//       channelOrderId: json['channel_order_id'],
//       paymentMethod: json['payment_method'],
//       paymentDate: json['payment_date'] != null
//           ? DateTime.tryParse(json['payment_date'])
//           : null,
//       paidStatus: json['paid_status'] ?? 'UNPAID',
//       isDeleted: json['is_deleted'] ?? false,
//       transactionId: json['transaction_id'],
//       channel: json['channel'] ?? 0,
//     );
//   }
// }
//
// // ✅ API mein items sirf product_id, product_name, quantity, unit_price return karta hai
// // OrderItem (detail wala) se alag hai — isliye alag class
// class OrderItemSimple {
//   final int productId;
//   final String productName;
//   final int quantity;
//   final String unitPrice;
//
//   OrderItemSimple({
//     required this.productId,
//     required this.productName,
//     required this.quantity,
//     required this.unitPrice,
//   });
//
//   factory OrderItemSimple.fromJson(Map<String, dynamic> json) {
//     return OrderItemSimple(
//       productId: json['product_id'] ?? 0,
//       productName: json['product_name'] ?? '',
//       quantity: json['quantity'] ?? 0,
//       unitPrice: json['unit_price']?.toString() ?? '0.00',
//     );
//   }
// }