class ScanProductResponseModel {
  final int? serialScanned;
  final ProductModel? product;

  ScanProductResponseModel({
    this.serialScanned,
    this.product,
  });

  factory ScanProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ScanProductResponseModel(
      serialScanned: json['serial_scanned'],
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial_scanned': serialScanned,
      'product': product?.toJson(),
    };
  }
}


class ProductModel {
  final int? id;
  final VendorModel? vendor;
  final InventoryModel? inventory;
  final List<dynamic>? damagedInventory;
  final String? prefixCode;
  final String? name;
  final String? size;
  final String? color;
  final String? material;
  final int? serial;
  final String? sku;
  final String? barcode;
  final String? barcodeImage;
  final String? productImage;
  final List<String>? productImageVariants;
  final String? unitPurchasePrice;

  ProductModel({
    this.id,
    this.vendor,
    this.inventory,
    this.damagedInventory,
    this.prefixCode,
    this.name,
    this.size,
    this.color,
    this.material,
    this.serial,
    this.sku,
    this.barcode,
    this.barcodeImage,
    this.productImage,
    this.productImageVariants,
    this.unitPurchasePrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      vendor: json['vendor'] != null
          ? VendorModel.fromJson(json['vendor'])
          : null,
      inventory: json['inventory'] != null
          ? InventoryModel.fromJson(json['inventory'])
          : null,
      damagedInventory: json['damaged_inventory'] ?? [],
      prefixCode: json['prefix_code'],
      name: json['name'],
      size: json['size'],
      color: json['color'],
      material: json['material'],
      serial: json['serial'],
      sku: json['sku'],
      barcode: json['barcode'],
      barcodeImage: json['barcode_image'],
      productImage: json['product_image'],
      productImageVariants: json['product_image_variants'] != null
          ? List<String>.from(json['product_image_variants'])
          : [],
      unitPurchasePrice: json['unit_purchase_price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor': vendor?.toJson(),
      'inventory': inventory?.toJson(),
      'damaged_inventory': damagedInventory,
      'prefix_code': prefixCode,
      'name': name,
      'size': size,
      'color': color,
      'material': material,
      'serial': serial,
      'sku': sku,
      'barcode': barcode,
      'barcode_image': barcodeImage,
      'product_image': productImage,
      'product_image_variants': productImageVariants,
      'unit_purchase_price': unitPurchasePrice,
    };
  }
}


class VendorModel {
  final int? id;
  final String? name;
  final String? countryCode;
  final String? mobile;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final bool? withGst;
  final String? firmName;
  final String? gstNumber;

  VendorModel({
    this.id,
    this.name,
    this.countryCode,
    this.mobile,
    this.email,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.withGst,
    this.firmName,
    this.gstNumber,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_code': countryCode,
      'mobile': mobile,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pin_code': pinCode,
      'with_Gst': withGst,
      'firm_name': firmName,
      'gst_number': gstNumber,
    };
  }
}


class InventoryModel {
  final int? id;
  final int? quantity;
  final int? productId;

  InventoryModel({this.id, this.quantity, this.productId});

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      quantity: json['quantity'],
      productId: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'product': productId,
    };
  }
}
