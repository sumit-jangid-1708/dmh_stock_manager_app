import 'dart:ui';

import 'package:flutter/material.dart';

class OrderDetailModel {
  final int id;
  final List<OrderItem> items;
  final String customerName;
  final DateTime createdAt;
  final List<OrderRemark> remarks;
  final String status;
  final int orderStatus; // ✅ NEW
  final bool isDeleted;
  final int channel;
  final String countryCode;
  final String mobile;
  final String? channelOrderId;
  final String? customerEmail;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String paidStatus;
  final String? transactionId;
  final String packageExpence;
  final String totalAmount;
  final String paidAmount;

  OrderDetailModel({
    required this.id,
    required this.items,
    required this.customerName,
    required this.createdAt,
    required this.status,
    required this.orderStatus, // ✅ NEW
    required this.isDeleted,
    required this.channel,
    required this.countryCode,
    required this.mobile,
    required this.paidStatus,
    required this.remarks,
    required this.packageExpence,
    required this.totalAmount,
    required this.paidAmount,
    this.customerEmail,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      customerName: json['customer_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      remarks: (json['remarks'] as List? ?? [])
          .map((e) => OrderRemark.fromJson(e))
          .toList(),
      status: json['status'] ?? "ACTIVE",
      orderStatus: json['order_status'] is int
          ? json['order_status']
          : int.tryParse('${json['order_status']}') ?? 0, // ✅ NEW
      isDeleted: json['is_deleted'] ?? false,
      channel: json['channel'] ?? 0,
      countryCode: json['country_code'] ?? '',
      mobile: json['mobile'] ?? '',
      customerEmail: json['customer_email'],
      channelOrderId: json['channel_order_id'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'])
          : null,
      paidStatus: json['paid_status'] ?? 'UNPAID',
      transactionId: json['transaction_id'],
      packageExpence: json['package_expence'] ?? "0.00",
      totalAmount: json['total_amount'] ?? "0.00",
      paidAmount: json['paid_amount'] ?? "0.00",
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

class OrderItem {
  final int id;
  final Product product;
  final int quantity;
  final String unitPrice;
  final int order;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.order,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      order: json['order'],
    );
  }
}

class Product {
  final int id;
  final int vendor;
  final String prefixCode;
  final String name;
  final String size;
  final String color;
  final String material;
  final int serial;
  final String sku;
  final String barcode;
  final String barcodeImage;
  final List<String> productImageVariants;
  final String unitPurchasePrice;
  final int? hsn;

  String get baseSku {
    final parts = sku.split('-');
    if (parts.length > 4) {
      // Remove last 4 parts (color, size, material, serial)
      return parts.sublist(0, parts.length - 4).join('-');
    }
    return sku;
  }

  Product({
    required this.id,
    required this.vendor,
    required this.prefixCode,
    required this.name,
    required this.size,
    required this.color,
    required this.material,
    required this.serial,
    required this.sku,
    required this.barcode,
    required this.barcodeImage,
    required this.productImageVariants,
    required this.unitPurchasePrice,
    this.hsn,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      vendor: json['vendor'],
      prefixCode: json['prefix_code'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      serial: json['serial'] ?? 0,
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      barcodeImage: json['barcode_image'] ?? '',
      productImageVariants:
          (json['product_image_variants'] as List?)?.cast<String>() ?? [],
      unitPurchasePrice: json['unit_purchase_price'] ?? '0.00',
      hsn: json['hsn'],
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
