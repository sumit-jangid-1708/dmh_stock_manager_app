// lib/model/order_models/order_details_model.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsModel {
  final int id;
  final int orderId;
  final String date;

  final String channel;
  final String channelName;
  final String channelOrderId;
  final String channelId;

  final String customerName;
  final String customerEmail;

  final String mobile;
  final String countryCode;

  final int orderStatus;
  final String status;
  final String statusDate;
  final String statusTimestamp;

  final List<OrderRemark> remarks;

  final DateTime createdAt;

  final String paidStatus;
  final double paidAmount;
  final double remainingAmount;

  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? transactionId;

  final bool billGenerated;

  final int totalItems;
  final double totalAmount;

  final double packageExpence;
  final double buyerShipmentCharger;
  final double buyerTaxAmount;

  final List<OrderItemModel> items;

  final BillBreakdownModel billBreakdown;
  final PackageModel package;
  final OrderShipmentModel shipment;

  const OrderDetailsModel({
    required this.id,
    required this.orderId,
    required this.date,
    required this.channel,
    required this.channelName,
    required this.channelOrderId,
    required this.channelId,
    required this.customerName,
    required this.customerEmail,
    required this.mobile,
    required this.countryCode,
    required this.orderStatus,
    required this.status,
    required this.statusDate,
    required this.statusTimestamp,
    required this.remarks,
    required this.createdAt,
    required this.paidStatus,
    required this.paidAmount,
    required this.remainingAmount,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
    required this.billGenerated,
    required this.totalItems,
    required this.totalAmount,
    required this.packageExpence,
    required this.buyerShipmentCharger,
    required this.buyerTaxAmount,
    required this.items,
    required this.billBreakdown,
    required this.package,
    required this.shipment,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      date: json['date'] ?? '',

      channel: json['channel'] ?? '',
      channelName: json['channel_name'] ?? '',
      channelOrderId: json['channel_order_id'] ?? '',
      channelId: json['channel_id'] ?? '',

      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',

      mobile: json['mobile'] ?? '',
      countryCode: json['country_code'] ?? '',

      orderStatus: _toInt(json['order_status']),
      status: json['status'] ?? '',
      statusDate: json['status_date'] ?? '',
      statusTimestamp: json['status_timestamp'] ?? '',

      remarks: (json['remarks'] as List? ?? [])
          .map((e) => OrderRemark.fromJson(e))
          .toList(),

      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),

      paidStatus: json['paid_status'] ?? '',
      paidAmount: _toDouble(json['paid_amount']),
      remainingAmount: _toDouble(json['remaining_amount']),

      paymentMethod: json['payment_method']?.toString(),

      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString())
          : null,

      transactionId: json['transaction_id']?.toString(),

      billGenerated: json['bill_generated'] ?? false,

      totalItems: _toInt(json['total_items']),
      totalAmount: _toDouble(json['total_amount']),

      packageExpence: _toDouble(json['package_expence']),
      buyerShipmentCharger: _toDouble(json['buyer_shipment_charger']),
      buyerTaxAmount: _toDouble(json['buyer_tax_amount']),

      items: (json['items'] as List? ?? [])
          .map((e) => OrderItemModel.fromJson(e))
          .toList(),

      billBreakdown: BillBreakdownModel.fromJson(json['bill_breakdown'] ?? {}),

      package: PackageModel.fromJson(json['package'] ?? {}),

      shipment: OrderShipmentModel.fromJson(json['shipment'] ?? {}),
    );
  }

  String get orderStatusText {
    switch (orderStatus) {
      case 1:
        return "In Process";
      case 2:
        return "Packed";
      case 3:
        return "In Transit";
      case 4:
        return "Delivered";
      case 5:
        return "Courier Return";
      case 6:
        return "Customer Return";
      case 7:
        return "Return Received";
      default:
        return status;
    }
  }

  Color get orderStatusColor {
    switch (orderStatus) {
      case 1:
        return const Color(0xFFFF9800);
      case 2:
        return const Color(0xFF2196F3);
      case 3:
        return const Color(0xFF9C27B0);
      case 4:
        return const Color(0xFF4CAF50);
      case 5:
        return const Color(0xFFF44336);
      case 6:
        return const Color(0xFFFF5722);
      case 7:
        return const Color(0xFF00897B);
      default:
        return Colors.grey;
    }
  }
}

class OrderItemModel {
  final int id;
  final int productId;

  final String name;
  final String productName;

  final String sku;
  final String productSku;

  final String productBarcode;
  final String? productBarcodeImage;

  final String? image;
  final String? productImage;

  final List<String> productImageVariants;

  final int vendorId;
  final String vendorName;

  final int quantity;
  final int orderedQuantity;

  final double unitPrice;
  final double subtotal;
  final double totalPrice;

  final int stockLeft;

  final String serial;

  final List<SerialModel> serials;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.productName,
    required this.sku,
    required this.productSku,
    required this.productBarcode,
    this.productBarcodeImage,
    this.image,
    this.productImage,
    required this.productImageVariants,
    required this.vendorId,
    required this.vendorName,
    required this.quantity,
    required this.orderedQuantity,
    required this.unitPrice,
    required this.subtotal,
    required this.totalPrice,
    required this.stockLeft,
    required this.serial,
    required this.serials,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: _toInt(json['id']),
      productId: _toInt(json['product_id']),

      name: json['name'] ?? '',
      productName: json['product_name'] ?? '',

      sku: json['sku'] ?? '',
      productSku: json['product_sku'] ?? '',

      productBarcode: json['product_barcode'] ?? '',
      productBarcodeImage: json['product_barcode_image']?.toString(),

      image: json['image']?.toString(),
      productImage: json['product_image']?.toString(),

      productImageVariants: (json['product_image_variants'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),

      vendorId: _toInt(json['vendor_id']),
      vendorName: json['vendor_name'] ?? '',

      quantity: _toInt(json['quantity']),
      orderedQuantity: _toInt(json['ordered_quantity']),

      unitPrice: _toDouble(json['unit_price']),
      subtotal: _toDouble(json['subtotal']),
      totalPrice: _toDouble(json['total_price']),

      stockLeft: _toInt(json['stock_left']),

      serial: json['serial'] ?? '',

      serials: (json['serials'] as List? ?? [])
          .map((e) => SerialModel.fromJson(e))
          .toList(),
    );
  }
}

class SerialModel {
  final String serialNumber;
  final String qrImage;
  final String barcodeImage;
  final String qrValue;

  const SerialModel({
    required this.serialNumber,
    required this.qrImage,
    required this.barcodeImage,
    required this.qrValue,
  });

  factory SerialModel.fromJson(Map<String, dynamic> json) {
    return SerialModel(
      serialNumber: json['serial_number'] ?? '',
      qrImage: json['qr_image'] ?? '',
      barcodeImage: json['barcode_image'] ?? '',
      qrValue: json['qr_value'] ?? '',
    );
  }
}

class OrderRemark {
  final int id;
  final String remark;
  final DateTime createdAt;

  const OrderRemark({
    required this.id,
    required this.remark,
    required this.createdAt,
  });

  factory OrderRemark.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;

    try {
      parsedDate = DateFormat(
        "dd MMM yyyy, hh:mm a",
      ).parse(json['created_at'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return OrderRemark(
      id: _toInt(json['id']),
      remark: json['remark'] ?? '',
      createdAt: parsedDate,
    );
  }
}

class BillBreakdownModel {
  final double itemsTotal;
  final double productTaxPercent;
  final double productTax;
  final double packageExpence;
  final double buyerShipmentCharger;
  final double buyerTaxAmount;
  final double calculatedTotal;
  final double otherAdjustment;
  final double printedAmount;
  final double grandTotal;

  const BillBreakdownModel({
    required this.itemsTotal,
    required this.productTaxPercent,
    required this.productTax,
    required this.packageExpence,
    required this.buyerShipmentCharger,
    required this.buyerTaxAmount,
    required this.calculatedTotal,
    required this.otherAdjustment,
    required this.printedAmount,
    required this.grandTotal,
  });

  factory BillBreakdownModel.fromJson(Map<String, dynamic> json) {
    return BillBreakdownModel(
      itemsTotal: _toDouble(json['items_total']),
      productTaxPercent: _toDouble(json['product_tax_percent']),
      productTax: _toDouble(json['product_tax']),
      packageExpence: _toDouble(json['package_expence']),
      buyerShipmentCharger: _toDouble(json['buyer_shipment_charger']),
      buyerTaxAmount: _toDouble(json['buyer_tax_amount']),
      calculatedTotal: _toDouble(json['calculated_total']),
      otherAdjustment: _toDouble(json['other_adjustment']),
      printedAmount: _toDouble(json['printed_amount']),
      grandTotal: _toDouble(json['grand_total']),
    );
  }
}

class PackageModel {
  final String height;
  final String width;
  final String length;
  final String deadWeight;
  final String volWeight;
  final String billedWeight;

  const PackageModel({
    required this.height,
    required this.width,
    required this.length,
    required this.deadWeight,
    required this.volWeight,
    required this.billedWeight,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      height: json['height']?.toString() ?? '',
      width: json['width']?.toString() ?? '',
      length: json['length']?.toString() ?? '',
      deadWeight: json['dead_weight']?.toString() ?? '',
      volWeight: json['vol_weight']?.toString() ?? '',
      billedWeight: json['billed_weight']?.toString() ?? '',
    );
  }
}

class OrderShipmentModel {
  final String courier;
  final String mediator;
  final String trackingId;
  final String shipDate;
  final double shippingExpense;
  final String trackingUrl;

  const OrderShipmentModel({
    required this.courier,
    required this.mediator,
    required this.trackingId,
    required this.shipDate,
    required this.shippingExpense,
    required this.trackingUrl,
  });

  factory OrderShipmentModel.fromJson(Map<String, dynamic> json) {
    return OrderShipmentModel(
      courier: json['courier'] ?? '',
      mediator: json['mediator'] ?? '',
      trackingId: json['tracking_id'] ?? '',
      shipDate: json['ship_date'] ?? '',
      shippingExpense: _toDouble(json['shipping_expense']),
      trackingUrl: json['tracking_url'] ?? '',
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

// // lib/model/order_models/order_details_model.dart
// import 'dart:ui';
// import 'package:flutter/material.dart';
//
// class OrderDetailsModel {
//   final int orderId;
//   final String channel;
//   final String channelOrderId;
//   final String customerName;
//   final String customerEmail;
//   final String mobile;
//   final String countryCode;
//   final int orderStatus;
//   // ✅ Changed: String -> List<dynamic>
//   final List<OrderRemark> remarks;
//   final DateTime createdAt;
//   final String paidStatus;
//   final String? paymentMethod;
//   final DateTime? paymentDate;
//   final String? transactionId;
//   final int totalItems;
//   final List<OrderItemModel> items;
//   final OrderTotalModel total;
//
//   const OrderDetailsModel({
//     required this.orderId,
//     required this.channel,
//     required this.channelOrderId,
//     required this.customerName,
//     required this.customerEmail,
//     required this.orderStatus,
//     required this.mobile,
//     required this.countryCode,
//     required this.remarks,
//     required this.createdAt,
//     required this.paidStatus,
//     this.paymentMethod,
//     this.paymentDate,
//     this.transactionId,
//     required this.totalItems,
//     required this.items,
//     required this.total,
//   });
//
//   factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
//     return OrderDetailsModel(
//       orderId: json['order_id'] is int
//           ? json['order_id']
//           : int.tryParse('${json['order_id']}') ?? 0,
//       channel: json['channel'] ?? '',
//       channelOrderId: json['channel_order_id'] ?? '',
//       customerName: json['customer_name'] ?? '',
//       customerEmail: json['customer_email'] ?? '',
//       orderStatus: json['order_status'] ?? 0, // ✅ NEW
//       mobile: json['mobile'] ?? '',
//       countryCode: json['country_code'] ?? '',
//       remarks: (json['remarks'] as List? ?? [])
//           .map((e) => OrderRemark.fromJson(e))
//           .toList(),
//       createdAt: json['created_at'] != null
//           ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
//           : DateTime.now(),
//       paidStatus: json['paid_status'] ?? '',
//       paymentMethod: json['payment_method'],
//       paymentDate: json['payment_date'] != null
//           ? DateTime.tryParse(json['payment_date'])
//           : null,
//       transactionId: json['transaction_id'],
//       totalItems: json['total_items'] is int
//           ? json['total_items']
//           : int.tryParse('${json['total_items']}') ?? 0,
//       items: json['items'] is List
//           ? List<OrderItemModel>.from(
//               json['items'].map((x) => OrderItemModel.fromJson(x)),
//             )
//           : [],
//       total: OrderTotalModel.fromJson(json['total'] ?? {}),
//     );
//   }
//
//   String get orderStatusText {
//     switch (orderStatus) {
//       case 1:
//         return "In Process";
//       case 2:
//         return "Packed";
//       case 3:
//         return "In Transit";
//       case 4:
//         return "Delivered";
//       case 5:
//         return "Courier Return";
//       case 6:
//         return "Customer Return";
//       case 7:
//         return "Return Received";
//       default:
//         return "Unknown";
//     }
//   }
//
//   Color get orderStatusColor {
//     switch (orderStatus) {
//       case 1:
//         return const Color(0xFFFF9800); // Orange
//       case 2:
//         return const Color(0xFF2196F3); // Blue
//       case 3:
//         return const Color(0xFF9C27B0); // Purple
//       case 4:
//         return const Color(0xFF4CAF50); // Green
//       case 5:
//         return const Color(0xFFF44336); // Red
//       case 6:
//         return const Color(0xFFFF5722); // Deep Orange
//       case 7:
//         return const Color(0xFF00897B); // Teal
//       default:
//         return Colors.grey;
//     }
//   }
// }
//
// // ==================== Order Item Model ====================
// class OrderItemModel {
//   final int productId;
//   final String productName;
//   final String productSku;
//   final String productBarcode;
//   final String? productBarcodeImage;
//   final String? productImage;
//   final List<String> productImageVariants;
//   final int vendorId;
//   final String vendorName;
//   final int orderedQuantity;
//   final double unitPrice;
//   final double totalPrice;
//   final int stockLeft;
//   final List<SerialModel> serials;
//
//   const OrderItemModel({
//     required this.productId,
//     required this.productName,
//     required this.productSku,
//     required this.productBarcode,
//     this.productBarcodeImage,
//     this.productImage,
//     required this.productImageVariants,
//     required this.vendorId,
//     required this.vendorName,
//     required this.orderedQuantity,
//     required this.unitPrice,
//     required this.totalPrice,
//     required this.stockLeft,
//     required this.serials,
//   });
//
//   factory OrderItemModel.fromJson(Map<String, dynamic> json) {
//     return OrderItemModel(
//       productId: json['product_id'] is int
//           ? json['product_id']
//           : int.tryParse('${json['product_id']}') ?? 0,
//       productName: json['product_name'] ?? '',
//       productSku: json['product_sku'] ?? '',
//       productBarcode: json['product_barcode'] ?? '',
//       productBarcodeImage: json['product_barcode_image'],
//       productImage: json['product_image'],
//       productImageVariants: json['product_image_variants'] is List
//           ? List<String>.from(json['product_image_variants'])
//           : [],
//       vendorId: json['vendor_id'] is int
//           ? json['vendor_id']
//           : int.tryParse('${json['vendor_id']}') ?? 0,
//       vendorName: json['vendor_name'] ?? '',
//       orderedQuantity: json['ordered_quantity'] is int
//           ? json['ordered_quantity']
//           : int.tryParse('${json['ordered_quantity']}') ?? 0,
//       unitPrice: _parseDouble(json['unit_price']),
//       totalPrice: _parseDouble(json['total_price']),
//       stockLeft: json['stock_left'] is int
//           ? json['stock_left']
//           : int.tryParse('${json['stock_left']}') ?? 0,
//       serials: json['serials'] is List
//           ? List<SerialModel>.from(
//               json['serials'].map((x) => SerialModel.fromJson(x)),
//             )
//           : [],
//     );
//   }
//
//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is double) return value;
//     if (value is int) return value.toDouble();
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }
// }
//
// // ==================== Serial Model ====================
// class SerialModel {
//   final String serialNumber;
//   final String barcodeImage;
//
//   const SerialModel({required this.serialNumber, required this.barcodeImage});
//
//   factory SerialModel.fromJson(Map<String, dynamic> json) {
//     return SerialModel(
//       serialNumber: json['serial_number'] ?? '',
//       barcodeImage: json['barcode_image'] ?? '',
//     );
//   }
// }
//
// class OrderRemark {
//   final int id;
//   final String remark;
//   final DateTime createdAt;
//
//   OrderRemark({
//     required this.id,
//     required this.remark,
//     required this.createdAt,
//   });
//
//   factory OrderRemark.fromJson(Map<String, dynamic> json) {
//     return OrderRemark(
//       id: json['id'] ?? 0,
//       remark: json['remark'] ?? '',
//       createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
//     );
//   }
// }
//
// class OrderTotalModel {
//   final double packageExpense;
//   final double buyerShipmentCharges;
//   final ShipmentAmountModel shipment;
//
//   const OrderTotalModel({
//     required this.packageExpense,
//     required this.buyerShipmentCharges,
//     required this.shipment,
//   });
//
//   factory OrderTotalModel.fromJson(Map<String, dynamic> json) {
//     final shipmentData = json['shipment'];
//
//     ShipmentAmountModel shipmentParsed;
//
//     if (shipmentData is Map<String, dynamic>) {
//       // ✅ Case 1: direct object
//       shipmentParsed = ShipmentAmountModel.fromJson(shipmentData);
//     } else if (shipmentData is List && shipmentData.isNotEmpty) {
//       // ✅ Case 2: list → take first element
//       shipmentParsed = ShipmentAmountModel.fromJson(
//         shipmentData.first is Map<String, dynamic> ? shipmentData.first : {},
//       );
//     } else {
//       // ✅ Case 3: null / empty / invalid
//       shipmentParsed = ShipmentAmountModel.empty();
//     }
//
//     return OrderTotalModel(
//       packageExpense: _toDouble(json['package_expense']),
//       buyerShipmentCharges: _toDouble(json['buyer_shipment_charges']),
//       shipment: shipmentParsed,
//     );
//   }
//
//   static double _toDouble(dynamic val) {
//     if (val == null) return 0.0;
//     if (val is double) return val;
//     if (val is int) return val.toDouble();
//     return double.tryParse(val.toString()) ?? 0.0;
//   }
// }
//
// class ShipmentAmountModel {
//   final double shippingExpense;
//   final double otherExpense;
//
//   const ShipmentAmountModel({
//     required this.shippingExpense,
//     required this.otherExpense,
//   });
//
//   factory ShipmentAmountModel.empty() {
//     return const ShipmentAmountModel(shippingExpense: 0.0, otherExpense: 0.0);
//   }
//
//   factory ShipmentAmountModel.fromJson(Map<String, dynamic> json) {
//     return ShipmentAmountModel(
//       shippingExpense: _toDouble(json['shipping_expense']),
//       otherExpense: _toDouble(json['other_expense']),
//     );
//   }
//
//   static double _toDouble(dynamic val) {
//     if (val == null) return 0.0;
//     if (val is double) return val;
//     if (val is int) return val.toDouble();
//     return double.tryParse(val.toString()) ?? 0.0;
//   }
// }
