class CreateBillModel {
  final String message;
  final int orderId;
  final String paymentMethod;
  final String paymentDate;
  final String paidStatus;
  final String? transactionId;

  CreateBillModel({
    required this.message,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentDate,
    required this.paidStatus,
    required this.transactionId,
  });

  factory CreateBillModel.fromJson(Map<String, dynamic> json) {
    return CreateBillModel(
      message: json["message"] ?? "",
      orderId: json["order_id"] ?? 0,
      paymentMethod: json["payment_method"] ?? "",
      paymentDate: json["payment_date"] ?? "",
      paidStatus: json["paid_status"] ?? "",
      transactionId: json["transaction_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "order_id": orderId,
      "payment_method": paymentMethod,
      "payment_date": paymentDate,
      "paid_status": paidStatus,
      "transaction_id": transactionId,
    };
  }
}
