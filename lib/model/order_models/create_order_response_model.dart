class CreateOrderResponseModel {
  final OrderModel order;
  final List<AllocatedBarcodeModel> allocatedBarcodes;

  CreateOrderResponseModel({
    required this.order,
    required this.allocatedBarcodes,
  });

  factory CreateOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponseModel(
      order: OrderModel.fromJson(json['order']),
      allocatedBarcodes: (json['allocated_barcodes'] as List? ?? [])
          .map((e) => AllocatedBarcodeModel.fromJson(e))
          .toList(),
    );
  }
}

class AllocatedBarcodeModel {
  final int productId;
  final int qty;
  final List<String> barcodes;

  AllocatedBarcodeModel({
    required this.productId,
    required this.qty,
    required this.barcodes,
  });

  factory AllocatedBarcodeModel.fromJson(Map<String, dynamic> json) {
    return AllocatedBarcodeModel(
      productId: json['product_id'] ?? 0,
      qty: json['qty'] ?? 0,
      barcodes: (json['barcodes'] as List?)?.cast<String>() ?? [],
    );
  }
}

class OrderModel {
  final int id;
  final List<OrderItem> items;
  final String customerName;
  final DateTime createdAt;
  final String? remarks;
  final int channel;
  final String countryCode;
  final String mobile;

  final String? channelOrderId;
  final String? customerEmail;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final String paidStatus;
  final String? transactionId;

  OrderModel({
    required this.id,
    required this.items,
    required this.customerName,
    required this.createdAt,
    required this.channel,
    required this.countryCode,
    required this.mobile,
    required this.paidStatus,
    this.remarks,
    this.customerEmail,
    this.channelOrderId,
    this.paymentMethod,
    this.paymentDate,
    this.transactionId,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e))
          .toList(),
      customerName: json['customer_name'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      remarks: json['remarks'],
      channel: json['channel'] ?? 0,
      countryCode: json['country_code'] ?? '',
      mobile: json['mobile'] ?? '',
      customerEmail: json['customer_email'],
      channelOrderId: json['channel_order_id'],
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      paidStatus: json['paid_status'] ?? 'UNPAID',
      transactionId: json['transaction_id'],
    );
  }
}

class OrderItem {
  final int id;
  final Product product;
  final int quantity;
  final String unitPrice;
  final int order;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.order,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price']?.toString() ?? '0',
      order: json['order'] ?? 0,
    );
  }
}

class Product {
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
  final List<String> productImageVariants;
  final String unitPurchasePrice;
  final int? hsn;

  Product({
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
    required this.productImageVariants,
    required this.unitPurchasePrice,
    this.hsn,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      vendor: json['vendor'] ?? 0,
      prefixCode: json['prefix_code'] ?? '',
      name: json['name'] ?? '',
      size: json['size'] ?? '',
      color: json['color'] ?? '',
      material: json['material'] ?? '',
      serial: json['serial'] ?? 0,
      sku: json['sku'] ?? '',
      barcode: json['barcode'] ?? '',
      barcodeImage: json['barcode_image'] ?? '',
      productImageVariants:
          (json['product_image_variants'] as List?)?.cast<String>() ?? [],
      unitPurchasePrice: json['unit_purchase_price']?.toString() ?? '0.00',
      hsn: json['hsn'],
    );
  }
}


// achha mano mere pas order aaya h lets suppose product 22 ka to mene order create kiya  jisme mere product ke serial nikle 0001 aur 0002 thik h ab mujhe is product ke jo barcode h yani 0001 aur 0002 ko product par print karke lagana h lekin agar me generate barcode wali api se generate karke print kar rha hu to ye to 0003 aur 0004 de rha h lekin ye to mere kaam ke hi nahi h jabki mujhe to 0001 aur 0002 print karne the