class OrderDetailModel {
  final int id;
  final List<OrderItem> items;
  final String customerName;
  final DateTime createdAt;
  final String remarks;
  final int channel;
  final String countryCode;
  final String mobile;

  OrderDetailModel({
    required this.id,
    required this.items,
    required this.customerName,
    required this.createdAt,
    required this.remarks,
    required this.channel,
    required this.countryCode,
    required this.mobile,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      customerName: json['customer_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      remarks: json['remarks'] as String,
      channel: json['channel'] as int,
      countryCode: json['country_code'] as String,
      mobile: json['mobile'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'customer_name': customerName,
      'created_at': createdAt.toIso8601String(),
      'remarks': remarks,
      'channel': channel,
      'country_code': countryCode,
      'mobile': mobile,
    };
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
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'unit_price': unitPrice,
      'order': order,
    };
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
  final List<String> productImageVariants; // Added
  final String unitPurchasePrice;

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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      vendor: json['vendor'] as int,
      prefixCode: json['prefix_code'] as String,
      name: json['name'] as String,
      size: json['size'] as String,
      color: json['color'] as String,
      material: json['material'] as String,
      serial: json['serial'] as int,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String,
      barcodeImage: json['barcode_image'] as String,
      productImageVariants: (json['product_image_variants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      unitPurchasePrice: json['unit_purchase_price'] as String? ?? "0.00",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor': vendor,
      'prefix_code': prefixCode,
      'name': name,
      'size': size,
      'color': color,
      'material': material,
      'serial': serial,
      'sku': sku,
      'barcode': barcode,
      'barcode_image': barcodeImage,
      'product_image_variants': productImageVariants,
      'unit_purchase_price': unitPurchasePrice,
    };
  }
}



// class OrderDetailModel {
//   final int id;
//   final List<OrderItem> items;
//   final String customerName;
//   final DateTime createdAt;
//   final String remarks;
//   final int channel;
//   final String countryCode; // 👈 new
//   final String mobile;      // 👈 new
//
//   OrderDetailModel({
//     required this.id,
//     required this.items,
//     required this.customerName,
//     required this.createdAt,
//     required this.remarks,
//     required this.channel,
//     required this.countryCode,
//     required this.mobile,
//   });
//
//   factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
//     return OrderDetailModel(
//       id: json['id'],
//       items: (json['items'] as List)
//           .map((item) => OrderItem.fromJson(item))
//           .toList(),
//       customerName: json['customer_name'],
//       createdAt: DateTime.parse(json['created_at']),
//       remarks: json['remarks'],
//       channel: json['channel'],
//       countryCode: json['country_code'], // 👈 no default, nullable
//       mobile: json['mobile'],             // 👈 new
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'items': items.map((e) => e.toJson()).toList(),
//       'customer_name': customerName,
//       'created_at': createdAt.toIso8601String(),
//       'remarks': remarks,
//       'channel': channel,
//       'country_code': countryCode, // 👈 new
//       'mobile': mobile,            // 👈 new
//     };
//   }
// }
//
// class OrderItem {
//   final int id;
//   final Product product;
//   final int quantity;
//   final String unitPrice;
//   final int order;
//
//   OrderItem({
//     required this.id,
//     required this.product,
//     required this.quantity,
//     required this.unitPrice,
//     required this.order,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       id: json['id'],
//       product: Product.fromJson(json['product']),
//       quantity: json['quantity'],
//       unitPrice: json['unit_price'],
//       order: json['order'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'product': product.toJson(),
//       'quantity': quantity,
//       'unit_price': unitPrice,
//       'order': order,
//     };
//   }
// }
//
// class Product {
//   final int id;
//   final int vendor;
//   final String prefixCode;
//   final String name;
//   final String size;
//   final String color;
//   final String material;
//   final int serial;
//   final String sku;
//   final String barcode;
//   final String barcodeImage;
//   final String unitPurchasePrice; // 👈 new
//
//   Product({
//     required this.id,
//     required this.vendor,
//     required this.prefixCode,
//     required this.name,
//     required this.size,
//     required this.color,
//     required this.material,
//     required this.serial,
//     required this.sku,
//     required this.barcode,
//     required this.barcodeImage,
//     required this.unitPurchasePrice,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['id'],
//       vendor: json['vendor'],
//       prefixCode: json['prefix_code'],
//       name: json['name'],
//       size: json['size'],
//       color: json['color'],
//       material: json['material'],
//       serial: json['serial'],
//       sku: json['sku'],
//       barcode: json['barcode'],
//       barcodeImage: json['barcode_image'],
//       unitPurchasePrice: json['unit_purchase_price'] ?? "0.00", // 👈 new
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'vendor': vendor,
//       'prefix_code': prefixCode,
//       'name': name,
//       'size': size,
//       'color': color,
//       'material': material,
//       'serial': serial,
//       'sku': sku,
//       'barcode': barcode,
//       'barcode_image': barcodeImage,
//       'unit_purchase_price': unitPurchasePrice, // 👈 new
//     };
//   }
// }
