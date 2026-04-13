class ReturnReportResponse {
  final int count;
  final List<ReturnReport> results;

  ReturnReportResponse({required this.count, required this.results});

  factory ReturnReportResponse.fromJson(Map<String, dynamic> json) {
    return ReturnReportResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => ReturnReport.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'count': count, 'results': results.map((e) => e.toJson()).toList()};
  }
}

class ReturnReport {
  final int orderId;
  final String customerName;
  final String mobile;
  final double totalAmount;
  final DateTime createdAt;
  final double refund;
  final double damageLoss;
  final double claimReceived;
  final List<ReturnItem> items;
  final List<ReturnEntry> returns;
  final double netLoss;
  final double totalLoss;

  ReturnReport({
    required this.orderId,
    required this.customerName,
    required this.mobile,
    required this.totalAmount,
    required this.createdAt,
    required this.refund,
    required this.damageLoss,
    required this.claimReceived,
    required this.items,
    required this.returns,
    required this.netLoss,
    required this.totalLoss,
  });

  factory ReturnReport.fromJson(Map<String, dynamic> json) {
    return ReturnReport(
      orderId: json['order_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      mobile: json['mobile'] ?? '',
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      refund: (json['refund'] ?? 0).toDouble(),
      damageLoss: (json['damage_loss'] ?? 0).toDouble(),
      claimReceived: (json['claim_received'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ReturnItem.fromJson(e))
          .toList(),
      returns: (json['returns'] as List<dynamic>? ?? [])
          .map((e) => ReturnEntry.fromJson(e))
          .toList(),
      netLoss: (json['net_loss'] ?? 0).toDouble(),
      totalLoss: (json['total_loss'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_name': customerName,
      'mobile': mobile,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'refund': refund,
      'damage_loss': damageLoss,
      'claim_received': claimReceived,
      'items': items.map((e) => e.toJson()).toList(),
      'returns': returns.map((e) => e.toJson()).toList(),
      'net_loss': netLoss,
      'total_loss': totalLoss,
    };
  }
}

class ReturnItem {
  final String product;
  final String sku;
  final int qty;
  final double unitPrice;

  ReturnItem({
    required this.product,
    required this.sku,
    required this.qty,
    required this.unitPrice,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      product: json['product'] ?? '',
      sku: json['sku'] ?? '',
      qty: json['qty'] ?? 0,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'sku': sku,
      'qty': qty,
      'unit_price': unitPrice,
    };
  }
}

class ReturnEntry {
  final String type; // customer_return / courier_return
  final String product;
  final String sku;
  final int qty;
  final String condition; // SAFE / DAMAGED etc
  final double refundAmount;
  final DateTime date;

  ReturnEntry({
    required this.type,
    required this.product,
    required this.sku,
    required this.qty,
    required this.condition,
    required this.refundAmount,
    required this.date,
  });

  factory ReturnEntry.fromJson(Map<String, dynamic> json) {
    return ReturnEntry(
      type: json['type'] ?? '',
      product: json['product'] ?? '',
      sku: json['sku'] ?? '',
      qty: json['qty'] ?? 0,
      condition: json['condition'] ?? '',
      refundAmount: (json['refund_amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'product': product,
      'sku': sku,
      'qty': qty,
      'condition': condition,
      'refund_amount': refundAmount,
      'date': date.toIso8601String(),
    };
  }
}
