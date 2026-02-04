import 'package:dmj_stock_manager/model/order_models/order_detail_by_id_model.dart';

class OrderDetailUIModel {
  final int orderId;
  final String customerName;
  final String? customerEmail;
  final DateTime createdAt;
  final String? remarks;
  final int channel;
  final String countryCode;
  final String mobile;
  final String? channelOrderId;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String paidStatus;
  final String? transactionId;
  final List<OrderItemUIModel> items;

  OrderDetailUIModel({
    required this.orderId,
    required this.customerName,
    this.customerEmail,
    required this.createdAt,
    this.remarks,
    required this.channel,
    required this.countryCode,
    required this.mobile,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    required this.paidStatus,
    this.transactionId,
    required this.items,
  });
}

class OrderItemUIModel {
  final int productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final int stockLeft;
  final List<OrderBarcode> barcodes;

  OrderItemUIModel({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.stockLeft,
    required this.barcodes,
  });
}