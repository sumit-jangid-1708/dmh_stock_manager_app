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
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List? ?? [])
          .map((e) => BillModel.fromJson(e))
          .toList(),
    );
  }
}

class BillModel {
  final int id;
  final String countryCode;
  final String customerName;
  final String mobile;
  final String createdAt;
  final String? remarks;

  final String? paymentMethod;
  final String? paymentDate;
  final String paidStatus;
  final String? transactionId;

  final int channel;
  final double subtotal;
  final double gstAmount;
  final double grandTotal;

  final List<BillItemModel> items;

  BillModel({
    required this.id,
    required this.countryCode,
    required this.customerName,
    required this.mobile,
    required this.createdAt,
    this.remarks,
    this.paymentMethod,
    this.paymentDate,
    required this.paidStatus,
    this.transactionId,
    required this.channel,
    required this.subtotal,
    required this.gstAmount,
    required this.grandTotal,
    required this.items,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      countryCode: json['country_code'] ?? '',
      customerName: json['customer_name'] ?? '',
      mobile: json['mobile'] ?? '',
      createdAt: json['created_at'] ?? '',
      remarks: json['remarks'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'],
      paidStatus: json['paid_status'] ?? '',
      transactionId: json['transaction_id'],
      channel: json['channel'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      gstAmount: (json['gst_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List? ?? [])
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
  final int order;

  BillItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.order,
  });

  factory BillItemModel.fromJson(Map<String, dynamic> json) {
    return BillItemModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'] ?? 0,
      unitPrice: num.tryParse(json['unit_price'].toString())?.toDouble() ?? 0.0,
      order: json['order'] ?? 0,
    );
  }
}


class ProductModel {
  final int id;
  final int vendor;
  final String prefixCode;
  final String name;
  final String size;
  final String color;
  final String material;
  final int serial;
  final String sku;
  final String barcode;
  final String barcodeImage;
  final List<String> imageVariants;
  final double unitPurchasePrice;
  final int? hsn;

  ProductModel({
    required this.id,
    required this.vendor,
    required this.prefixCode,
    required this.name,
    required this.size,
    required this.color,
    required this.material,
    required this.serial,
    required this.sku,
    required this.barcode,
    required this.barcodeImage,
    required this.imageVariants,
    required this.unitPurchasePrice,
    this.hsn,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      vendor: json['vendor'],
      prefixCode: json['prefix_code'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      serial: json['serial'] ?? 0,
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      barcodeImage: json['barcode_image'] ?? '',
      imageVariants:
      (json['product_image_variants'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      unitPurchasePrice:
      num.tryParse(json['unit_purchase_price'].toString())
          ?.toDouble() ??
          0.0,
      hsn: json['hsn'],
    );
  }
}
