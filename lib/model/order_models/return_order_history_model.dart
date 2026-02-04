class ReturnOrderHistoryResponse {
  final String? message;
  final List<ReturnOrderHistory>? data;
  final int? status;

  ReturnOrderHistoryResponse({
    this.message,
    this.data,
    this.status,
  });

  factory ReturnOrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReturnOrderHistoryResponse(
      message: json['message'],
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => ReturnOrderHistory.fromJson(item))
          .toList(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "data": data?.map((item) => item.toJson()).toList(),
      "status": status,
    };
  }
}

class ReturnOrderHistory {
  final int? id;
  final int? delta;
  final String? reason;
  final String? condition;
  final String? note;
  final String? createdAt;
  final int? product;
  final int? channel;
  final int? order;

  ReturnOrderHistory({
    this.id,
    this.delta,
    this.reason,
    this.condition,
    this.note,
    this.createdAt,
    this.product,
    this.channel,
    this.order,
  });

  factory ReturnOrderHistory.fromJson(Map<String, dynamic> json) {
    return ReturnOrderHistory(
      id: json['id'],
      delta: json['delta'],
      reason: json['reason'],
      condition: json['condition'],
      note: json['note'],
      createdAt: json['created_at'],
      product: json['product'],
      channel: json['channel'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "delta": delta,
      "reason": reason,
      "condition": condition,
      "note": note,
      "created_at": createdAt,
      "product": product,
      "channel": channel,
      "order": order,
    };
  }
}
