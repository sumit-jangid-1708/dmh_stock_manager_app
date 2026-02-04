class StockAlertResponseModel {
  final int count;
  final List<StockAlertItemModel> results;

  StockAlertResponseModel({
    required this.count,
    required this.results,
  });

  factory StockAlertResponseModel.fromJson(Map<String, dynamic> json) {
    return StockAlertResponseModel(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((e) => StockAlertItemModel.fromJson(e))
          .toList(),
    );
  }
}


class StockAlertItemModel {
  final int productId;
  final String sku;
  final String name;
  final int quantity;
  final bool popular;
  final int threshold;

  StockAlertItemModel({
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.popular,
    required this.threshold,
  });

  factory StockAlertItemModel.fromJson(Map<String, dynamic> json) {
    return StockAlertItemModel(
      productId: json['product_id'] ?? 0,
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      popular: json['popular'] ?? false,
      threshold: json['threshold'] ?? 0,
    );
  }
}
