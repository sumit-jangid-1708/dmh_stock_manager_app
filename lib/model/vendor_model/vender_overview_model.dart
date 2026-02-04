// File: lib/model/vendor_overview_model.dart

class VendorOverviewModel {
  final VendorsModel vendor;
  final VendorStatsModel stats;
  final VendorPerformanceModel performance;
  final List<SuppliedProductModel> suppliedProducts;
  final List<PastOrderModel> pastOrders;

  VendorOverviewModel({
    required this.vendor,
    required this.stats,
    required this.performance,
    required this.suppliedProducts,
    required this.pastOrders,
  });

  factory VendorOverviewModel.fromJson(Map<String, dynamic> json) {
    return VendorOverviewModel(
      vendor: VendorsModel.fromJson(json['vendor'] ?? {}),
      stats: VendorStatsModel.fromJson(json['stats'] ?? {}),
      performance: VendorPerformanceModel.fromJson(json['performance'] ?? {}),
      suppliedProducts: (json['supplied_products'] as List? ?? [])
          .map((e) => SuppliedProductModel.fromJson(e))
          .toList(),
      pastOrders: (json['past_orders'] as List? ?? [])
          .map((e) => PastOrderModel.fromJson(e))
          .toList(),
    );
  }
}


class VendorsModel {
  final int id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String gstin;
  final String? vendorLogo;
  final String email;
  final String mobile;
  final String firm;
  final String address;

  VendorsModel({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.gstin,
    this.vendorLogo,
    required this.email,
    required this.mobile,
    required this.firm,
    required this.address,
  });

  factory VendorsModel.fromJson(Map<String, dynamic> json) {
    return VendorsModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      gstin: json['gstin'] ?? '',
      vendorLogo: json['vendor_logo'],
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      firm: json['firm'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class VendorStatsModel {
  final int totalBillsGenerated;
  final int totalProductsPurchased;
  final double totalBusinessAmount;

  VendorStatsModel({
    required this.totalBillsGenerated,
    required this.totalProductsPurchased,
    required this.totalBusinessAmount,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    return VendorStatsModel(
      totalBillsGenerated: json['total_bills_generated'] ?? 0,
      totalProductsPurchased: json['total_products_purchased'] ?? 0,
      totalBusinessAmount:
      num.tryParse(json['total_business_amount'].toString())?.toDouble() ??
          0.0,
    );
  }
}


class VendorPerformanceModel {
  final int onTimeDelivery;
  final double qualityRating;

  VendorPerformanceModel({
    required this.onTimeDelivery,
    required this.qualityRating,
  });

  factory VendorPerformanceModel.fromJson(Map<String, dynamic> json) {
    return VendorPerformanceModel(
      onTimeDelivery: json['on_time_delivery'] ?? 0,
      qualityRating:
      num.tryParse(json['quality_rating'].toString())?.toDouble() ?? 0.0,
    );
  }
}


class SuppliedProductModel {
  final String sku;
  final String productName;
  final int suppliedQty;
  final int remainderQty;

  SuppliedProductModel({
    required this.sku,
    required this.productName,
    required this.suppliedQty,
    required this.remainderQty,
  });

  factory SuppliedProductModel.fromJson(Map<String, dynamic> json) {
    return SuppliedProductModel(
      sku: json['sku'] ?? '',
      productName: json['product_name'] ?? '',
      suppliedQty: json['supplied_qty'] ?? 0,
      remainderQty: json['remainder_qty'] ?? 0,
    );
  }
}


class PastOrderModel {
  final String poNumber;
  final String date;
  final int items;
  final double totalAmount;
  final String status;

  PastOrderModel({
    required this.poNumber,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  factory PastOrderModel.fromJson(Map<String, dynamic> json) {
    return PastOrderModel(
      poNumber: json['po_number'] ?? '',
      date: json['date'] ?? '',
      items: json['items'] ?? 0,
      totalAmount:
      num.tryParse(json['total_amount'].toString())?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
    );
  }
}
