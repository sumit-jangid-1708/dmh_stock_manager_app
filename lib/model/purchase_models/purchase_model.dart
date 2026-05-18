// // model/purchase_bill_response_model.dart

class PurchaseBillResponseModel {
  int? count;
  List<PurchaseBillModel>? results;

  PurchaseBillResponseModel({
    this.count,
    this.results,
  });

  PurchaseBillResponseModel.fromJson(Map<String, dynamic> json) {
    count = json['count'];

    if (json['results'] != null) {
      results = <PurchaseBillModel>[];
      json['results'].forEach((v) {
        results!.add(PurchaseBillModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['count'] = count;

    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PurchaseBillModel {
  int? id;
  PurchaseVendorModel? vendor;
  List<PurchaseItemModel>? items;

  double? remainingAmount;

  String? billNumber;
  String? billDate;
  String? placeOfSupply;
  String? gstType;
  String? taxType;

  String? sgstPercent;
  String? cgstPercent;
  String? igstPercent;
  String? roundOff;

  String? paidDate;

  String? subtotal;
  String? discount;
  String? shipping;
  String? otherExpense;

  String? paidAmount;
  String? totalAmount;
  String? taxAmount;

  String? status;
  bool? isDeleted;

  String? description;
  String? createdAt;

  PurchaseBillModel({
    this.id,
    this.vendor,
    this.items,
    this.remainingAmount,
    this.billNumber,
    this.billDate,
    this.placeOfSupply,
    this.gstType,
    this.taxType,
    this.sgstPercent,
    this.cgstPercent,
    this.igstPercent,
    this.roundOff,
    this.paidDate,
    this.subtotal,
    this.discount,
    this.shipping,
    this.otherExpense,
    this.paidAmount,
    this.totalAmount,
    this.taxAmount,
    this.status,
    this.isDeleted,
    this.description,
    this.createdAt,
  });

  PurchaseBillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    vendor =
    json['vendor'] != null ? PurchaseVendorModel.fromJson(json['vendor']) : null;

    if (json['items'] != null) {
      items = <PurchaseItemModel>[];
      json['items'].forEach((v) {
        items!.add(PurchaseItemModel.fromJson(v));
      });
    }

    remainingAmount =
        double.tryParse(json['remaining_amount'].toString());

    billNumber = json['bill_number'];
    billDate = json['bill_date'];

    placeOfSupply = json['place_of_supply'];
    gstType = json['gst_type'];
    taxType = json['tax_type'];

    sgstPercent = json['sgst_percent'];
    cgstPercent = json['cgst_percent'];
    igstPercent = json['igst_percent'];

    roundOff = json['round_off'];

    paidDate = json['paid_date'];

    subtotal = json['subtotal'];
    discount = json['discount'];
    shipping = json['shipping'];
    otherExpense = json['other_expense'];

    paidAmount = json['paid_amount'];
    totalAmount = json['total_amount'];
    taxAmount = json['tax_amount'];

    status = json['status'];

    isDeleted = json['is_deleted'];

    description = json['description'];

    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;

    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }

    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }

    data['remaining_amount'] = remainingAmount;

    data['bill_number'] = billNumber;
    data['bill_date'] = billDate;

    data['place_of_supply'] = placeOfSupply;
    data['gst_type'] = gstType;
    data['tax_type'] = taxType;

    data['sgst_percent'] = sgstPercent;
    data['cgst_percent'] = cgstPercent;
    data['igst_percent'] = igstPercent;

    data['round_off'] = roundOff;

    data['paid_date'] = paidDate;

    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['shipping'] = shipping;
    data['other_expense'] = otherExpense;

    data['paid_amount'] = paidAmount;
    data['total_amount'] = totalAmount;
    data['tax_amount'] = taxAmount;

    data['status'] = status;

    data['is_deleted'] = isDeleted;

    data['description'] = description;

    data['created_at'] = createdAt;

    return data;
  }
}

class PurchaseVendorModel {
  int? id;
  String? name;
  String? mobile;

  PurchaseVendorModel({
    this.id,
    this.name,
    this.mobile,
  });

  PurchaseVendorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['name'] = name;
    data['mobile'] = mobile;

    return data;
  }
}

class PurchaseItemModel {
  int? id;

  int? productId;

  String? productName;
  String? productSku;

  int? quantity;

  double? unitPrice;
  double? totalPrice;

  PurchaseItemModel({
    this.id,
    this.productId,
    this.productName,
    this.productSku,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    productId = json['product_id'];

    productName = json['product_name'];
    productSku = json['product_sku'];

    quantity = json['quantity'];

    unitPrice =
        double.tryParse(json['unit_price'].toString());

    totalPrice =
        double.tryParse(json['total_price'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;

    data['product_id'] = productId;

    data['product_name'] = productName;
    data['product_sku'] = productSku;

    data['quantity'] = quantity;

    data['unit_price'] = unitPrice;
    data['total_price'] = totalPrice;

    return data;
  }
}



//
// class PurchaseBillResponseModel {
//   final String message;
//   final int billId;
//   final double totalAmount;
//   final int itemsCount;
//   final bool inventoryUpdated;
//
//   PurchaseBillResponseModel({
//     required this.message,
//     required this.billId,
//     required this.totalAmount,
//     required this.itemsCount,
//     required this.inventoryUpdated,
//   });
//
//   factory PurchaseBillResponseModel.fromJson(Map<String, dynamic> json) {
//     return PurchaseBillResponseModel(
//       message: json['message'] as String? ?? '',
//       billId: json['bill_id'] as int? ?? 0,
//       totalAmount: json['total_amount'] as double? ?? 0,
//       itemsCount: json['items_count'] as int? ?? 0,
//       inventoryUpdated: json['inventory_updated'] as bool? ?? false,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'message': message,
//       'bill_id': billId,
//       'total_amount': totalAmount,
//       'items_count': itemsCount,
//       'inventory_updated': inventoryUpdated,
//     };
//   }
//
//   @override
//   String toString() {
//     return 'PurchaseBillResponseModel(message: $message, billId: $billId, totalAmount: $totalAmount, itemsCount: $itemsCount, inventoryUpdated: $inventoryUpdated)';
//   }
// }
//
//
//
//
//
// class PurchaseBillModel {
//   final int id;
//   final VendorsModel vendor;
//   final List<PurchaseItemModel> items;
//   final String billNumber;
//   final DateTime billDate;
//   final DateTime? paidDate;
//   final double paidAmount;
//   final double totalAmount;
//   final String status;
//   final String description;
//   final DateTime createdAt;
//
//   PurchaseBillModel({
//     required this.id,
//     required this.vendor,
//     required this.items,
//     required this.billNumber,
//     required this.billDate,
//     this.paidDate,
//     required this.paidAmount,
//     required this.totalAmount,
//     required this.status,
//     required this.description,
//     required this.createdAt,
//   });
//
//   factory PurchaseBillModel.fromJson(Map<String, dynamic> json) {
//     return PurchaseBillModel(
//       id: json['id'],
//       vendor: VendorsModel.fromJson(json['vendor']),
//       items: (json['items'] as List)
//           .map((e) => PurchaseItemModel.fromJson(e))
//           .toList(),
//       billNumber: json['bill_number'],
//       billDate: DateTime.parse(json['bill_date']),
//       paidDate:
//       json['paid_date'] != null ? DateTime.parse(json['paid_date']) : null,
//       paidAmount: _parseDouble(json['paid_amount']),
//       totalAmount: _parseDouble(json['total_amount']),
//       status: json['status'],
//       description: json['description'] ?? '',
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
//
//   static double _parseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     return double.tryParse(value.toString()) ?? 0.0;
//   }
// }
//
//
// class VendorsModel {
//   final int id;
//   final String name;
//   final String countryCode;
//   final String mobile;
//   final String email;
//   final String address;
//   final String city;
//   final String state;
//   final String country;
//   final String pinCode;
//   final bool withGst;
//   final String firmName;
//   final String gstNumber;
//
//   VendorsModel({
//     required this.id,
//     required this.name,
//     required this.countryCode,
//     required this.mobile,
//     required this.email,
//     required this.address,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.pinCode,
//     required this.withGst,
//     required this.firmName,
//     required this.gstNumber,
//   });
//
//   factory VendorsModel.fromJson(Map<String, dynamic> json) {
//     return VendorsModel(
//       id: json['id'],
//       name: json['name'],
//       countryCode: json['country_code'],
//       mobile: json['mobile'],
//       email: json['email'],
//       address: json['address'],
//       city: json['city'],
//       state: json['state'],
//       country: json['country'],
//       pinCode: json['pin_code'],
//       withGst: json['with_Gst'],
//       firmName: json['firm_name'],
//       gstNumber: json['gst_number'],
//     );
//   }
// }
//
// class PurchaseItemModel {
//   final int productId;
//   final String productName;
//   final String productSku;
//   final int quantity;
//   final double unitPrice;
//   final double totalPrice;
//
//   PurchaseItemModel({
//     required this.productId,
//     required this.productName,
//     required this.productSku,
//     required this.quantity,
//     required this.unitPrice,
//     required this.totalPrice,
//   });
//
//   factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
//     return PurchaseItemModel(
//       productId: json['product_id'],
//       productName: json['product_name'],
//       productSku: json['product_sku'],
//       quantity: json['quantity'],
//       unitPrice: (json['unit_price'] as num).toDouble(),
//       totalPrice: (json['total_price'] as num).toDouble(),
//     );
//   }
// }
