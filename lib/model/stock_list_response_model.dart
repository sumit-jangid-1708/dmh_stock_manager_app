class StockListResponseModel {
  final int count;
  final List<StockItemModel> results;

  StockListResponseModel({
    required this.count,
    required this.results,
  });

  factory StockListResponseModel.fromJson(Map<String, dynamic> json) {
    return StockListResponseModel(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((e) => StockItemModel.fromJson(e))
          .toList(),
    );
  }
}

class StockItemModel{
  final int productId;
  final String sku;
  final String name;
  final int quantity;
  final bool popular;
  final int threshold;

  StockItemModel({
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.popular,
    required this.threshold,
});

  factory StockItemModel.fromJson(Map<String, dynamic> json){
    return StockItemModel(
        productId: json['product_id']?? 0,
        sku: json['sku']?? '',
        name: json['name']?? '',
        quantity: json['quantity']?? 0,
        popular: json['popular']?? false,
        threshold: json['threshold']?? 0,
    );
  }
}