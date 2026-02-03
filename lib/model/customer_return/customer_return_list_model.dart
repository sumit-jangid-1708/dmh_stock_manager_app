class CustomerReturnListModel {
  final int? quantity;
  final String condition;
  final String refundAmount;
  final String refundStatus;
  final String? reason;

  CustomerReturnListModel({
    required this.quantity,
    required this.condition,
    required this.refundAmount,
    required this.refundStatus,
    this.reason,
  });

  factory CustomerReturnListModel.fromJson(Map<String, dynamic> json) {
    return CustomerReturnListModel(
      quantity: json['quantity'] ?? 0, // ✅ SAFE
      condition: json['condition'] ?? '',
      refundAmount: json['refund_amount']?.toString() ?? '0.00',
      refundStatus: json['refund_status'] ?? '',
      reason: json['reason'],
    );
  }
}
