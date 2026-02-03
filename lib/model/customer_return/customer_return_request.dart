import 'package:dmj_stock_manager/model/customer_return/customer_return_enum.dart';

class CustomerReturnRequest {
  final int orderId;
  final int productId;
  final int channelId;
  final int quantity;
  final CustomerReturnCondition condition;
  final double? refundAmount;
  final String? reason;

  CustomerReturnRequest({
    required this.orderId,
    required this.productId,
    required this.channelId,
    required this.quantity,
    required this.condition,
    this.refundAmount,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "order_id": orderId,
      "product_id": productId,
      "channel_id": channelId,
      "quantity": quantity,
      "condition": condition.apiValue,
    };

    // ✅ ALWAYS send refund_amount for ALL conditions (SAFE, DAMAGED, LOST)
    if (refundAmount != null) {
      data["refund_amount"] = refundAmount;
    }

    // ✅ ALWAYS send reason for ALL conditions
    if (reason != null && reason!.isNotEmpty) {
      data['reason'] = reason;
    }

    return data;
  }
}