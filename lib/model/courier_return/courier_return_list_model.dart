class CourierReturnListModel {
  final int id;
  final int quantity;
  final String condition;
  final String? claimStatus;
  final String? claimResult;
  final String? claimAmount;
  final String? remarks;
  final String receivedAt;
  final int orderId;
  final int productId;

  CourierReturnListModel({
    required this.id,
    required this.quantity,
    required this.condition,
    this.claimStatus,
    this.claimResult,
    this.claimAmount,
    this.remarks,
    required this.receivedAt,
    required this.orderId,
    required this.productId,
  });

  factory CourierReturnListModel.fromJson(Map<String, dynamic> json) {
    return CourierReturnListModel(
      id: json['id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      condition: json['condition'] ?? '',
      claimStatus: json['claim_status'],
      claimResult: json['claim_result'],
      claimAmount: json['claim_amount']?.toString(),
      remarks: json['remarks'],
      receivedAt: json['received_at'] ?? '',
      orderId: json['order'] ?? 0,
      productId: json['product'] ?? 0,
    );
  }
}