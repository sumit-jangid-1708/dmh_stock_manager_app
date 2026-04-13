class OrderStatusLogResponse {
  final List<OrderStatusLog> data;
  final int count;

  OrderStatusLogResponse({required this.data, required this.count});

  factory OrderStatusLogResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusLogResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => OrderStatusLog.fromJson(e))
          .toList(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'count': count,
  };
}

class OrderStatusLog {
  final int id;
  final int orderId;
  final int status;
  final OrderStatusExtraData? extraData;
  final DateTime createdAt;

  OrderStatusLog({
    required this.id,
    required this.orderId,
    required this.status,
    required this.extraData,
    required this.createdAt,
  });

  factory OrderStatusLog.fromJson(Map<String, dynamic> json) {
    return OrderStatusLog(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      status: json['status'] ?? 0,
      extraData: json['json'] != null
          ? OrderStatusExtraData.fromJson(
        json['json'] as Map<String, dynamic>,
      )
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'status': status,
    'json': extraData?.toJson(),
    'created_at': createdAt.toIso8601String(),
  };
}

class OrderStatusExtraData {
  final String? note;
  final String? updatedBy;
  final String? height;
  final String? width;
  final String? length;
  final String? weight;
  final String? image; // ✅ NEW

  OrderStatusExtraData({
    this.note,
    this.updatedBy,
    this.height,
    this.width,
    this.length,
    this.weight,
    this.image,
  });

  factory OrderStatusExtraData.fromJson(Map<String, dynamic> json) {
    return OrderStatusExtraData(
      note: json['note'] as String?,
      updatedBy: json['updated_by'] as String?,
      height: json['height']?.toString(),
      width: json['width']?.toString(),
      length: json['length']?.toString(),
      weight: json['weight']?.toString(),
      image: json['image'] as String?, // ✅ NEW
    );
  }

  Map<String, dynamic> toJson() => {
    'note': note,
    'updated_by': updatedBy,
    'height': height,
    'width': width,
    'length': length,
    'weight': weight,
    'image': image,
  };

  /// True if at least one dimension field is present
  bool get hasDimensions =>
      [height, width, length, weight].any((v) => v != null && v!.isNotEmpty);
}