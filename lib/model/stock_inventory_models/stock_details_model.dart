// stock_detail_model.dart
class StockResponseModel {
  final String? message;
  final StockData? data;
  final int? status;

  StockResponseModel({
    this.message,
    this.data,
    this.status,
  });

  factory StockResponseModel.fromJson(Map<String, dynamic> json) {
    return StockResponseModel(
      message: json["message"],
      data: json["data"] != null ? StockData.fromJson(json["data"]) : null,
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "data": data?.toJson(),
      "status": status,
    };
  }
}

class StockData {
  final List<StockDetail>? stockDetail;
  final int? stockCount;
  final double? totalStockValue;
  final List<StockDetail>? lowProducts;
  final int? lowCount;

  StockData({
    this.stockDetail,
    this.stockCount,
    this.totalStockValue,
    this.lowProducts,
    this.lowCount,
  });

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      stockDetail: (json["Stock_detail"] as List<dynamic>?)
          ?.map((e) => StockDetail.fromJson(e))
          .toList(),
      stockCount: json["Stock_count"],
      totalStockValue: (json["total_stock_value"] as num?)?.toDouble(),
      lowProducts: (json["low_products"] as List<dynamic>?)
          ?.map((e) => StockDetail.fromJson(e))
          .toList(),
      lowCount: json["low_count"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Stock_detail": stockDetail?.map((e) => e.toJson()).toList(),
      "Stock_count": stockCount,
      "total_stock_value": totalStockValue,
      "low_products": lowProducts?.map((e) => e.toJson()).toList(),
      "low_count": lowCount,
    };
  }
}

class StockDetail {
  final String? name;
  final String? sku;
  final String? size;
  final String? unitPurchasePrice;
  final int? inventoryQuantity;

  StockDetail({
    this.name,
    this.sku,
    this.size,
    this.unitPurchasePrice,
    this.inventoryQuantity,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      name: json["name"],
      sku: json["sku"],
      size: json["size"],
      unitPurchasePrice: json["unit_purchase_price"],
      inventoryQuantity: json["inventory_quantity"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "sku": sku,
      "size": size,
      "unit_purchase_price": unitPurchasePrice,
      "inventory_quantity": inventoryQuantity,
    };
  }
}
