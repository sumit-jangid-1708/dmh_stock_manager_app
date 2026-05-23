// model/purchase_bill_response_model.dart

class PurchaseBillResponseModel {
  int? count;
  List<PurchaseBillModel>? results;

  PurchaseBillResponseModel({this.count, this.results});

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
  String? billNumber;
  String? billDate;
  String? placeOfSupply;
  PurchaseVendorModel? vendor;
  String? gstType;
  PurchaseTaxFieldsModel? taxFields;
  String? subtotal;
  String? discount;
  String? shipping;
  String? otherExpense;
  String? roundOff;
  String? totalAmount;
  String? paidAmount;
  double? remainingAmount;
  String? status;
  String? paymentMode;
  String? transactionId;
  String? paidDate;
  String? description;
  String? createdAt;
  List<PurchaseItemModel>? items;

  PurchaseBillModel({
    this.id,
    this.billNumber,
    this.billDate,
    this.placeOfSupply,
    this.vendor,
    this.gstType,
    this.taxFields,
    this.subtotal,
    this.discount,
    this.shipping,
    this.otherExpense,
    this.roundOff,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.status,
    this.paymentMode,
    this.transactionId,
    this.paidDate,
    this.description,
    this.createdAt,
    this.items,
  });

  PurchaseBillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    billNumber = json['bill_number'];
    billDate = json['bill_date'];
    placeOfSupply = json['place_of_supply'];

    // ✅ Bool/int check — sirf Map hone par parse karo
    vendor = json['vendor'] is Map<String, dynamic>
        ? PurchaseVendorModel.fromJson(json['vendor'])
        : null;

    gstType = json['gst_type'];

    // ✅ Same check for taxFields
    taxFields = json['tax_fields'] is Map<String, dynamic>
        ? PurchaseTaxFieldsModel.fromJson(json['tax_fields'])
        : null;

    subtotal = json['subtotal'];
    discount = json['discount'];
    shipping = json['shipping'];
    otherExpense = json['other_expense'];
    roundOff = json['round_off'];
    totalAmount = json['total_amount'];
    paidAmount = json['paid_amount'];

    // ✅ remaining_amount null safe
    remainingAmount = json['remaining_amount'] != null
        ? double.tryParse(json['remaining_amount'].toString())
        : 0.0;

    status = json['status'];
    paymentMode = json['payment_mode'];
    transactionId = json['transaction_id'];
    paidDate = json['paid_date'];
    description = json['description'];
    createdAt = json['created_at'];

    if (json['items'] != null && json['items'] is List) {
      items = <PurchaseItemModel>[];
      json['items'].forEach((v) {
        if (v is Map<String, dynamic>) {
          items!.add(PurchaseItemModel.fromJson(v));
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['bill_number'] = billNumber;
    data['bill_date'] = billDate;
    data['place_of_supply'] = placeOfSupply;
    if (vendor != null) {
      data['vendor'] = vendor!.toJson();
    }
    data['gst_type'] = gstType;
    if (taxFields != null) {
      data['tax_fields'] = taxFields!.toJson();
    }
    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['shipping'] = shipping;
    data['other_expense'] = otherExpense;
    data['round_off'] = roundOff;
    data['total_amount'] = totalAmount;
    data['paid_amount'] = paidAmount;
    data['remaining_amount'] = remainingAmount;
    data['status'] = status;
    data['payment_mode'] = paymentMode;
    data['transaction_id'] = transactionId;
    data['paid_date'] = paidDate;
    data['description'] = description;
    data['created_at'] = createdAt;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PurchaseTaxFieldsModel {
  double? sgstPercent;
  double? cgstPercent;
  double? igstPercent;
  double? taxAmount;

  PurchaseTaxFieldsModel({
    this.sgstPercent,
    this.cgstPercent,
    this.igstPercent,
    this.taxAmount,
  });

  PurchaseTaxFieldsModel.fromJson(Map<String, dynamic> json) {
    sgstPercent = json['sgst_percent'] != null
        ? double.tryParse(json['sgst_percent'].toString())
        : 0.0;
    cgstPercent = json['cgst_percent'] != null
        ? double.tryParse(json['cgst_percent'].toString())
        : 0.0;
    igstPercent = json['igst_percent'] != null
        ? double.tryParse(json['igst_percent'].toString())
        : 0.0;
    taxAmount = json['tax_amount'] != null
        ? double.tryParse(json['tax_amount'].toString())
        : 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['sgst_percent'] = sgstPercent;
    data['cgst_percent'] = cgstPercent;
    data['igst_percent'] = igstPercent;
    data['tax_amount'] = taxAmount;
    return data;
  }
}

class PurchaseVendorModel {
  int? id;
  String? name;
  String? mobile;

  PurchaseVendorModel({this.id, this.name, this.mobile});

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
    unitPrice = double.tryParse(json['unit_price'].toString());
    totalPrice = double.tryParse(json['total_price'].toString());
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
