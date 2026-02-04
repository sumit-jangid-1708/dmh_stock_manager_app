class HsnGstModel {
  final int? id;
  final String? hsnCode;
  final double? gstPercentage;
  final DateTime? createdAt;

  HsnGstModel({
     this.id,
     this.hsnCode,
     this.gstPercentage,
     this.createdAt,
  });

  factory HsnGstModel.fromJson(Map<String, dynamic> json) {
    return HsnGstModel(
      id: json['id'],
      hsnCode: json['hsn_code'] ?? '',
      gstPercentage: num.tryParse(json['gst_percentage'].toString())
          ?.toDouble() ??
          0.0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
