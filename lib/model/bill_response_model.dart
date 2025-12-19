class BillsResponseModel {
  final int count;
  final String? next;
  final String? previous;
  final List<BillModel> results;

  BillsResponseModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory BillsResponseModel.fromJson(Map<String, dynamic> json) {
    return BillsResponseModel(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((e) => BillModel.fromJson(e))
          .toList(),
    );
  }
}

class BillModel {
  final int id;
  final String customerName;
  final String mobile;
  final String createdAt;
  final String? remarks;
  final double subtotal;
  final double gstPercentage;
  final double gstAmount;
  final double grandTotal;
  final List<BillItemModel> items;

  BillModel({
    required this.id,
    required this.customerName,
    required this.mobile,
    required this.createdAt,
    required this.remarks,
    required this.subtotal,
    required this.gstPercentage,
    required this.gstAmount,
    required this.grandTotal,
    required this.items,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      mobile: json['mobile'] ?? '',
      createdAt: json['created_at'] ?? '',
      remarks: json['remarks'],
      subtotal: num.tryParse(json['subtotal'].toString())?.toDouble() ?? 0.0,
      gstPercentage: num.tryParse(json['gst_percentage'].toString())?.toDouble() ?? 0.0,
      gstAmount: num.tryParse(json['gst_amount'].toString())?.toDouble() ?? 0.0,
      grandTotal: num.tryParse(json['grand_total'].toString())?.toDouble() ?? 0.0,
      items: (json['items'] as List)
          .map((e) => BillItemModel.fromJson(e))
          .toList(),
    );
  }
}

class BillItemModel {
  final int id;
  final ProductModel product;
  final int quantity;
  final double unitPrice;

  BillItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      unitPrice: num.tryParse(json['unit_price'].toString())?.toDouble() ?? 0.0,
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String size;
  final String color;
  final String material;
  final String barcode;
  final String? image;

  ProductModel({
    required this.id,
    required this.name,
    required this.size,
    required this.color,
    required this.material,
    required this.barcode,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      barcode: json['barcode'] ?? '',
      image: (json['product_image_variants'] as List?)?.isNotEmpty == true
          ? json['product_image_variants'][0]
          : null,
    );
  }
}
