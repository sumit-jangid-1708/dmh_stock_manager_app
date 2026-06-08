// model/purchase_bill_response_model.dart

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
  String? billNumber;
  String? billDate;
  String? placeOfSupply;

  PurchaseVendorModel? vendor;
  String? gstType;
  PurchaseTaxFieldsModel? taxFields;

  double? subtotal;
  double? taxAmount;

  String? discount;
  String? shipping;
  String? otherExpense;
  String? roundOff;

  double? totalAmount;
  String? paidAmount;
  double? remainingAmount;

  String? status;
  String? paymentMode;
  String? transactionId;
  String? paidDate;
  String? paymentDueDate;

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
    this.taxAmount,
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
    this.paymentDueDate,
    this.description,
    this.createdAt,
    this.items,
  });

  PurchaseBillModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    billNumber = json['bill_number'];
    billDate = json['bill_date'];
    placeOfSupply = json['place_of_supply'];

    vendor = json['vendor'] is Map<String, dynamic>
        ? PurchaseVendorModel.fromJson(json['vendor'])
        : null;

    gstType = json['gst_type'];

    taxFields = json['tax_fields'] is Map<String, dynamic>
        ? PurchaseTaxFieldsModel.fromJson(json['tax_fields'])
        : null;

    subtotal = double.tryParse(json['subtotal'].toString());

    taxAmount = double.tryParse(
      json['tax_amount'].toString(),
    );

    discount = json['discount']?.toString();
    shipping = json['shipping']?.toString();
    otherExpense = json['other_expense']?.toString();
    roundOff = json['round_off']?.toString();

    totalAmount = double.tryParse(
      json['total_amount'].toString(),
    );

    paidAmount = json['paid_amount']?.toString();

    remainingAmount = double.tryParse(
      json['remaining_amount'].toString(),
    );

    status = json['status'];
    paymentMode = json['payment_mode'];
    transactionId = json['transaction_id'];
    paidDate = json['paid_date'];
    paymentDueDate = json['payment_due_date'];

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
    data['tax_amount'] = taxAmount;

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
    data['payment_due_date'] = paymentDueDate;

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
    sgstPercent = double.tryParse(
      json['sgst_percent'].toString(),
    );

    cgstPercent = double.tryParse(
      json['cgst_percent'].toString(),
    );

    igstPercent = double.tryParse(
      json['igst_percent'].toString(),
    );

    taxAmount = double.tryParse(
      json['tax_amount'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sgst_percent': sgstPercent,
      'cgst_percent': cgstPercent,
      'igst_percent': igstPercent,
      'tax_amount': taxAmount,
    };
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
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
    };
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

    unitPrice = double.tryParse(
      json['unit_price'].toString(),
    );

    totalPrice = double.tryParse(
      json['total_price'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}