// lib/model/product_models/product_delete_model.dart

class ProductDeleteResponse {
  final String message;

  ProductDeleteResponse({
    required this.message,
  });

  factory ProductDeleteResponse.fromJson(Map<String, dynamic> json) {
    return ProductDeleteResponse(
      message: json['message'] ?? 'Product deleted successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}