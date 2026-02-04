class BestSellingProductsResponseModel {
  final int count;
  final List<BestSellingProductModel> results;

  BestSellingProductsResponseModel({
    required this.count,
    required this.results,
  });

  factory BestSellingProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return BestSellingProductsResponseModel(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((e) => BestSellingProductModel.fromJson(e))
          .toList(),
    );
  }
}


class BestSellingProductModel {
  final int productId;
  final String sku;
  final String name;
  final int quantity;
  final bool popular;
  final int threshold;

  BestSellingProductModel({
    required this.productId,
    required this.sku,
    required this.name,
    required this.quantity,
    required this.popular,
    required this.threshold,
  });

  factory BestSellingProductModel.fromJson(Map<String, dynamic> json) {
    return BestSellingProductModel(
      productId: json['product_id'] ?? 0,
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      popular: json['popular'] ?? false,
      threshold: json['threshold'] ?? 0,
    );
  }
}
