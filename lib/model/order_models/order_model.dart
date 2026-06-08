import 'package:flutter/material.dart';

class OrderListResponse {
  final List<OrderDetailModel> data;

  OrderListResponse({
    required this.data,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    // ✅ Handles both { "data": [...] } and { "results": [...] }
    final List<dynamic> list = json['data'] ?? json['results'] ?? [];
    return OrderListResponse(
      data: list.map((e) => OrderDetailModel.fromJson(e)).toList(),
    );
  }
}

class OrderDetailModel {
  final int id;
  final List<OrderItem> items;
  final String customerName;
  final DateTime createdAt;
  final List<OrderRemark> remarks;

  final String status;
  final LatestStatus? latestStatus;
  final int? orderStatus;
  final bool isDeleted;

  final String channel;
  final String date;

  final String countryCode;
  final String mobile;
  final String? channelOrderId;
  final String? customerEmail;

  final String? paymentMethod;
  final DateTime? paymentDate;
  final String paidStatus;
  final String? transactionId;

  final String totalAmount;
  final String packageExpence;
  final String buyerShipmentCharger;
  final String buyerTaxAmount;
  final String paidAmount;
  final String refundedAmount;
  final String refundAdditionalCharges;

  OrderDetailModel({
    required this.id,
    required this.items,
    required this.customerName,
    required this.createdAt,
    required this.remarks,
    required this.status,
    required this.latestStatus,
    required this.orderStatus,
    required this.isDeleted,
    required this.channel,
    required this.date,
    required this.countryCode,
    required this.mobile,
    required this.paidStatus,
    required this.totalAmount,
    required this.packageExpence,
    required this.buyerShipmentCharger,
    required this.buyerTaxAmount,
    required this.paidAmount,
    required this.refundedAmount,
    required this.refundAdditionalCharges,
    this.customerEmail,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: _toInt(json['id']),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      customerName: json['customer_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      remarks: (json['remarks'] as List? ?? [])
          .map((e) => OrderRemark.fromJson(e))
          .toList(),
      status: json['status']?.toString() ?? '',
      latestStatus: json['latest_status'] != null
          ? LatestStatus.fromJson(json['latest_status'])
          : null,
      orderStatus: _toInt(json['order_status']),
      isDeleted: json['is_deleted'] ?? false,
      channel: json['channel']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      customerEmail: json['customer_email']?.toString(),
      channelOrderId: json['channel_order_id']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'])
          : null,
      paidStatus: json['paid_status']?.toString() ?? 'PENDING',
      transactionId: json['transaction_id']?.toString(),
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      packageExpence: json['package_expence']?.toString() ?? '0.00',
      buyerShipmentCharger: json['buyer_shipment_charger']?.toString() ?? '0.00',
      buyerTaxAmount: json['buyer_tax_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      refundedAmount: json['refunded_amount']?.toString() ?? '0.00',
      refundAdditionalCharges: json['refund_additional_charges']?.toString() ?? '0.00',
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  int? get effectiveStatus => latestStatus?.status ?? orderStatus;

  String get orderStatusText {
    switch (effectiveStatus) {
      case 1: return "In Process";
      case 2: return "Packed";
      case 3: return "In Transit";
      case 4: return "Delivered";
      case 5: return "Courier Return";
      case 6: return "Customer Return";
      case 7: return "Return Received";
      default: return status.isEmpty ? "Unknown" : status;
    }
  }

  Color get orderStatusColor {
    switch (effectiveStatus) {
      case 1: return const Color(0xFFFF9800);
      case 2: return const Color(0xFF0C5460);
      case 3: return const Color(0xFF004085);
      case 4: return const Color(0xFF4CAF50);
      case 5: return const Color(0xFFF44336);
      case 6: return const Color(0xFFFF5722);
      case 7: return const Color(0xFF00897B);
      default: return Colors.grey;
    }
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final String sku;
  final int quantity;
  final String unitPrice;
  final String productImage;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _toInt(json['id']),
      productId: _toInt(json['product_id']),
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      quantity: _toInt(json['quantity']),
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      productImage: json['product_image'] ?? '',
    );
  }

  static int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
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
      id: (json['id'] is int) ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      remark: json['remark'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class LatestStatus {
  final int status;
  final String note;
  final DateTime createdAt;

  LatestStatus({
    required this.status,
    required this.note,
    required this.createdAt,
  });

  factory LatestStatus.fromJson(Map<String, dynamic> json) {
    return LatestStatus(
      status: (json['status'] is int) ? json['status'] : int.tryParse(json['status']?.toString() ?? '') ?? 0,
      note: json['note'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
