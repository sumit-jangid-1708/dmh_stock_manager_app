import 'package:dmj_stock_manager/model/courier_return/courier_enums.dart';

class CourierReturnRequest {
  final int order;
  final int product;
  final int quantity;

  final ReturnCondition condition;
  final ClaimStatus? claimStatus;
  final ClaimResult? claimResult;
  final int? claimAmount;
  final String? remarks;

  CourierReturnRequest({
    required this.order,
    required this.product,
    required this.quantity,
    required this.condition,
    this.claimStatus,
    this.claimResult,
    this.claimAmount,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      "order": order,
      "product": product,
      "quantity": quantity,
      "condition": condition.apiValue,
    };

    if (condition == ReturnCondition.damaged) {
      if (claimStatus == null) {
        throw Exception("claimStatus required when condition is DAMAGED");
      }

      data["claim_status"] = claimStatus!.apiValue;

      if (claimStatus == ClaimStatus.claimed) {
        if (claimResult == null) {
          throw Exception("claimResult required when claimStatus is CLAIMED");
        }

        data["claim_result"] = claimResult!.apiValue;

        if (claimResult == ClaimResult.received) {
          if (claimAmount == null) {
            throw Exception("claimAmount required when claimResult is RECEIVED");
          }
          data["claim_amount"] = claimAmount;
        }
      }

      if (claimStatus == ClaimStatus.notClaimed) {
        if (remarks == null || remarks!.isEmpty) {
          throw Exception("remarks required when claimStatus is NOT_CLAIMED");
        }
        data["remarks"] = remarks;
      }
    }

    return data;
  }
}