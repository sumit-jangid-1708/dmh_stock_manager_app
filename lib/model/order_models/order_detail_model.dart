// lib/model/order_models/order_details_model.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class OrderDetailsModel {
  final int orderId;
  final String channel;
  final String channelOrderId;
  final String customerName;
  final String customerEmail;
  final String mobile;
  final String countryCode;
  final int orderStatus;
  // ✅ Changed: String -> List<dynamic>
  final List<OrderRemark> remarks;
  final DateTime createdAt;
  final String paidStatus;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String? transactionId;
  final int totalItems;
  final List<OrderItemModel> items;
  final OrderTotalModel total;

  const OrderDetailsModel({
    required this.orderId,
    required this.channel,
    required this.channelOrderId,
    required this.customerName,
    required this.customerEmail,
    required this.orderStatus,
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
    required this.total,
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
      orderStatus: json['order_status'] ?? 0, // ✅ NEW
      mobile: json['mobile'] ?? '',
      countryCode: json['country_code'] ?? '',
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
      total: OrderTotalModel.fromJson(json['total'] ?? {}),
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
      default:
        return "Unknown";
    }
  }

  Color get orderStatusColor {
    switch (orderStatus) {
      case 1:
        return const Color(0xFFFF9800); // Orange
      case 2:
        return const Color(0xFF2196F3); // Blue
      case 3:
        return const Color(0xFF9C27B0); // Purple
      case 4:
        return const Color(0xFF4CAF50); // Green
      case 5:
        return const Color(0xFFF44336); // Red
      case 6:
        return const Color(0xFFFF5722); // Deep Orange
      default:
        return Colors.grey;
    }
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

class OrderTotalModel {
  final double packageExpense;
  final double buyerShipmentCharges;
  final ShipmentAmountModel shipment;

  const OrderTotalModel({
    required this.packageExpense,
    required this.buyerShipmentCharges,
    required this.shipment,
  });

  factory OrderTotalModel.fromJson(Map<String, dynamic> json) {
    final shipmentData = json['shipment'];

    ShipmentAmountModel shipmentParsed;

    if (shipmentData is Map<String, dynamic>) {
      // ✅ Case 1: direct object
      shipmentParsed = ShipmentAmountModel.fromJson(shipmentData);
    } else if (shipmentData is List && shipmentData.isNotEmpty) {
      // ✅ Case 2: list → take first element
      shipmentParsed = ShipmentAmountModel.fromJson(
        shipmentData.first is Map<String, dynamic> ? shipmentData.first : {},
      );
    } else {
      // ✅ Case 3: null / empty / invalid
      shipmentParsed = ShipmentAmountModel.empty();
    }

    return OrderTotalModel(
      packageExpense: _toDouble(json['package_expense']),
      buyerShipmentCharges: _toDouble(json['buyer_shipment_charges']),
      shipment: shipmentParsed,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

class ShipmentAmountModel {
  final double shippingExpense;
  final double otherExpense;

  const ShipmentAmountModel({
    required this.shippingExpense,
    required this.otherExpense,
  });

  factory ShipmentAmountModel.empty() {
    return const ShipmentAmountModel(shippingExpense: 0.0, otherExpense: 0.0);
  }

  factory ShipmentAmountModel.fromJson(Map<String, dynamic> json) {
    return ShipmentAmountModel(
      shippingExpense: _toDouble(json['shipping_expense']),
      otherExpense: _toDouble(json['other_expense']),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
