// model/purchase_bill_response_model.dart

class PurchaseBillResponseModel {
  final String message;
  final int billId;
  final double totalAmount;
  final int itemsCount;
  final bool inventoryUpdated;

  PurchaseBillResponseModel({
    required this.message,
    required this.billId,
    required this.totalAmount,
    required this.itemsCount,
    required this.inventoryUpdated,
  });

  factory PurchaseBillResponseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseBillResponseModel(
      message: json['message'] as String? ?? '',
      billId: json['bill_id'] as int? ?? 0,
      totalAmount: json['total_amount'] as double? ?? 0,
      itemsCount: json['items_count'] as int? ?? 0,
      inventoryUpdated: json['inventory_updated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'bill_id': billId,
      'total_amount': totalAmount,
      'items_count': itemsCount,
      'inventory_updated': inventoryUpdated,
    };
  }

  @override
  String toString() {
    return 'PurchaseBillResponseModel(message: $message, billId: $billId, totalAmount: $totalAmount, itemsCount: $itemsCount, inventoryUpdated: $inventoryUpdated)';
  }
}





class PurchaseBillModel {
  final int id;
  final VendorsModel vendor;
  final List<PurchaseItemModel> items;
  final String billNumber;
  final DateTime billDate;
  final DateTime? paidDate;
  final double paidAmount;
  final double totalAmount;
  final String status;
  final String description;
  final DateTime createdAt;

  PurchaseBillModel({
    required this.id,
    required this.vendor,
    required this.items,
    required this.billNumber,
    required this.billDate,
    this.paidDate,
    required this.paidAmount,
    required this.totalAmount,
    required this.status,
    required this.description,
    required this.createdAt,
  });

  factory PurchaseBillModel.fromJson(Map<String, dynamic> json) {
    return PurchaseBillModel(
      id: json['id'],
      vendor: VendorsModel.fromJson(json['vendor']),
      items: (json['items'] as List)
          .map((e) => PurchaseItemModel.fromJson(e))
          .toList(),
      billNumber: json['bill_number'],
      billDate: DateTime.parse(json['bill_date']),
      paidDate:
      json['paid_date'] != null ? DateTime.parse(json['paid_date']) : null,
      paidAmount: _parseDouble(json['paid_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      status: json['status'],
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}


class VendorsModel {
  final int id;
  final String name;
  final String countryCode;
  final String mobile;
  final String email;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final bool withGst;
  final String firmName;
  final String gstNumber;

  VendorsModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.mobile,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pinCode,
    required this.withGst,
    required this.firmName,
    required this.gstNumber,
  });

  factory VendorsModel.fromJson(Map<String, dynamic> json) {
    return VendorsModel(
      id: json['id'],
      name: json['name'],
      countryCode: json['country_code'],
      mobile: json['mobile'],
      email: json['email'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pinCode: json['pin_code'],
      withGst: json['with_Gst'],
      firmName: json['firm_name'],
      gstNumber: json['gst_number'],
    );
  }
}

class PurchaseItemModel {
  final int productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  PurchaseItemModel({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      productId: json['product_id'],
      productName: json['product_name'],
      productSku: json['product_sku'],
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }
}
