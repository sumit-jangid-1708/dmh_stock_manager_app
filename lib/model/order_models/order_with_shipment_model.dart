import 'shipment_model.dart';

class OrderWithShipmentModel {
  final int orderId;
  final String customerName;
  final double totalAmount;
  final List<ShipmentModel> shipments;

  OrderWithShipmentModel({
    required this.orderId,
    required this.customerName,
    required this.totalAmount,
    required this.shipments,
  });

  factory OrderWithShipmentModel.fromJson(Map<String, dynamic> json) {
    return OrderWithShipmentModel(
      orderId: json['order_id'],
      customerName: json['customer_name'] ?? '',
      totalAmount:
      (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      shipments: (json['shipments'] as List?)
          ?.map((e) => ShipmentModel.fromJson(e))
          .toList() ??
          [],
    );
  }
}