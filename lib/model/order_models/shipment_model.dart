class ShipmentModel {
  final int id;
  final int orderId;
  final String trackingId;
  final String shippingDate;
  final String trackingUrl;
  final String shippingExpense;
  final String otherExpense;
  final String notes;
  final DateTime createdAt;
  final int courierPartner;
  final int mediator;

  ShipmentModel({
    required this.id,
    required this.orderId,
    required this.trackingId,
    required this.shippingDate,
    required this.trackingUrl,
    required this.shippingExpense,
    required this.otherExpense,
    required this.notes,
    required this.createdAt,
    required this.courierPartner,
    required this.mediator,
  });

  // shipment_model.dart — createdAt null-safe banao
  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? json['order'] ?? 0, // ✅ 'order' fallback bhi
      trackingId: json['tracking_id'] ?? '',
      shippingDate: json['shipping_date'] ?? '',
      trackingUrl: json['tracking_url'] ?? '',
      shippingExpense: json['shipping_expense']?.toString() ?? '0',
      otherExpense: json['other_expense']?.toString() ?? '0',
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] != null  // ✅ null check
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      courierPartner: json['courier_partner'] ?? 0,
      mediator: json['mediator'] ?? 0,
    );
  }
}