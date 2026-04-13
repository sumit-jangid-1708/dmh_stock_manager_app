class CreateOrderResponseModel {
  final OrderModel order;
  final List<AllocatedSerialModel> allocatedSerials;
  final String message;

  CreateOrderResponseModel({
    required this.order,
    required this.allocatedSerials,
    required this.message,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseModel(
      message: json['message'] ?? '',
      order: OrderModel.fromJson(json['order']),
      allocatedSerials: (json['allocated_serials'] as List? ?? [])
          .map((e) => AllocatedSerialModel.fromJson(e))
          .toList(),
    );
  }
}

// ✅ allocated_barcodes → allocated_serials (API response change)
class AllocatedSerialModel {
  final int productId;
  final String productName;
  final int quantity;
  final List<String> serials;

  AllocatedSerialModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.serials,
  });

  factory AllocatedSerialModel.fromJson(Map<String, dynamic> json) {
    return AllocatedSerialModel(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      serials: (json['serials'] as List?)?.cast<String>() ?? [],
    );
  }
}

class OrderModel {
  final int id;
  final List<OrderItemSimple> items;
  final List<AllocatedSerialModel> allocatedSerials;
  final String customerName;
  final DateTime createdAt;
  final String status;
  final int orderStatus;
  final String packageExpence;
  final String totalAmount;
  final String paidAmount;
  final String? customerEmail;
  final String countryCode;
  final String mobile;
  final String? channelOrderId;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String paidStatus;
  final bool isDeleted;
  final String? transactionId;
  final int channel;

  // ✅ Status helpers — same as OrderDetailModel
  String get orderStatusText {
    switch (orderStatus) {
      case 1: return "In Process";
      case 2: return "Packed";
      case 3: return "In Transit";
      case 4: return "Delivered";
      case 5: return "Courier Return";
      case 6: return "Customer Return";
      default: return "Unknown";
    }
  }

  OrderModel({
    required this.id,
    required this.items,
    required this.allocatedSerials,
    required this.customerName,
    required this.createdAt,
    required this.status,
    required this.orderStatus,
    required this.packageExpence,
    required this.totalAmount,
    required this.paidAmount,
    required this.countryCode,
    required this.mobile,
    required this.paidStatus,
    required this.isDeleted,
    required this.channel,
    this.customerEmail,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemSimple.fromJson(e))
          .toList(),
      allocatedSerials: (json['allocated_serials'] as List? ?? [])
          .map((e) => AllocatedSerialModel.fromJson(e))
          .toList(),
      customerName: json['customer_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'ACTIVE',
      orderStatus: json['order_status'] ?? 0,
      packageExpence: json['package_expence']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      customerEmail: json['customer_email'],
      countryCode: json['country_code'] ?? '',
      mobile: json['mobile'] ?? '',
      channelOrderId: json['channel_order_id'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'])
          : null,
      paidStatus: json['paid_status'] ?? 'UNPAID',
      isDeleted: json['is_deleted'] ?? false,
      transactionId: json['transaction_id'],
      channel: json['channel'] ?? 0,
    );
  }
}

// ✅ API mein items sirf product_id, product_name, quantity, unit_price return karta hai
// OrderItem (detail wala) se alag hai — isliye alag class
class OrderItemSimple {
  final int productId;
  final String productName;
  final int quantity;
  final String unitPrice;

  OrderItemSimple({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemSimple.fromJson(Map<String, dynamic> json) {
    return OrderItemSimple(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
    );
  }
}


// import 'package:dmj_stock_manager/model/order_models/order_detail_model.dart';
//
// class CreateOrderResponseModel {
//   final OrderModel order;
//   final List<AllocatedBarcodeModel> allocatedBarcodes;
//
//   CreateOrderResponseModel({
//     required this.order,
//     required this.allocatedBarcodes,
//   });
//
//   factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
//     return CreateOrderResponseModel(
//       order: OrderModel.fromJson(json['order']),
//       allocatedBarcodes: (json['allocated_barcodes'] as List? ?? [])
//           .map((e) => AllocatedBarcodeModel.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class AllocatedBarcodeModel {
//   final int productId;
//   final int qty;
//   final List<String> barcodes;
//
//   AllocatedBarcodeModel({
//     required this.productId,
//     required this.qty,
//     required this.barcodes,
//   });
//
//   factory AllocatedBarcodeModel.fromJson(Map<String, dynamic> json) {
//     return AllocatedBarcodeModel(
//       productId: json['product_id'] ?? 0,
//       qty: json['qty'] ?? 0,
//       barcodes: (json['barcodes'] as List?)?.cast<String>() ?? [],
//     );
//   }
// }
//
// class OrderModel {
//   final int id;
//   final List<OrderItem> items;
//   final String customerName;
//   final DateTime createdAt;
//
//   // ✅ FIXED: was String?, now List<OrderRemark>
//   final List<OrderRemark> remarks;
//
//   final int channel;
//   final String countryCode;
//   final String mobile;
//
//   final String? channelOrderId;
//   final String? customerEmail;
//   final String? paymentMethod;
//   final DateTime? paymentDate;
//   final String paidStatus;
//   final String? transactionId;
//   final String packageExpence;
//
//   OrderModel({
//     required this.id,
//     required this.items,
//     required this.customerName,
//     required this.createdAt,
//     required this.channel,
//     required this.countryCode,
//     required this.mobile,
//     required this.paidStatus,
//     required this.remarks,
//     this.customerEmail,
//     this.channelOrderId,
//     this.paymentMethod,
//     this.paymentDate,
//     this.transactionId,
//     required this.packageExpence,
//   });
//
//   factory OrderModel.fromJson(Map<String, dynamic> json) {
//     return OrderModel(
//       id: json['id'] ?? 0,
//       items: (json['items'] as List? ?? [])
//           .map((e) => OrderItem.fromJson(e))
//           .toList(),
//       customerName: json['customer_name'] ?? '',
//       createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
//
//       // ✅ FIXED: parse remarks as List<OrderRemark>
//       remarks: (json['remarks'] as List? ?? [])
//           .map((e) => OrderRemark.fromJson(e as Map<String, dynamic>))
//           .toList(),
//
//       channel: json['channel'] ?? 0,
//       countryCode: json['country_code'] ?? '',
//       mobile: json['mobile'] ?? '',
//       customerEmail: json['customer_email'],
//       channelOrderId: json['channel_order_id'],
//       paymentMethod: json['payment_method'],
//       paymentDate: json['payment_date'] != null
//           ? DateTime.tryParse(json['payment_date'])
//           : null,
//       paidStatus: json['paid_status'] ?? 'UNPAID',
//       transactionId: json['transaction_id'],
//       packageExpence: json['package_expence'] ?? "0.00",
//     );
//   }
// }
//
// class OrderItem {
//   final int id;
//   final Product product;
//   final int quantity;
//   final String unitPrice;
//   final int order;
//
//   OrderItem({
//     required this.id,
//     required this.product,
//     required this.quantity,
//     required this.unitPrice,
//     required this.order,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       id: json['id'] ?? 0,
//       product: Product.fromJson(json['product']),
//       quantity: json['quantity'] ?? 0,
//       unitPrice: json['unit_price']?.toString() ?? '0',
//       order: json['order'] ?? 0,
//     );
//   }
// }
//
// class Product {
//   final int id;
//   final int vendor;
//   final String prefixCode;
//   final String name;
//   final String size;
//   final String color;
//   final String material;
//   final int serial;
//   final String sku;
//   final String barcode;
//   final String barcodeImage;
//   final List<String> productImageVariants;
//   final String unitPurchasePrice;
//   final int? hsn;
//
//   Product({
//     required this.id,
//     required this.vendor,
//     required this.prefixCode,
//     required this.name,
//     required this.size,
//     required this.color,
//     required this.material,
//     required this.serial,
//     required this.sku,
//     required this.barcode,
//     required this.barcodeImage,
//     required this.productImageVariants,
//     required this.unitPurchasePrice,
//     this.hsn,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'] ?? 0,
//       vendor: json['vendor'] ?? 0,
//       prefixCode: json['prefix_code'] ?? '',
//       name: json['name'] ?? '',
//       size: json['size'] ?? '',
//       color: json['color'] ?? '',
//       material: json['material'] ?? '',
//       serial: json['serial'] ?? 0,
//       sku: json['sku'] ?? '',
//       barcode: json['barcode'] ?? '',
//       barcodeImage: json['barcode_image'] ?? '',
//       productImageVariants:
//           (json['product_image_variants'] as List?)?.cast<String>() ?? [],
//       unitPurchasePrice: json['unit_purchase_price']?.toString() ?? '0.00',
//       hsn: json['hsn'],
//     );
//   }
// }
