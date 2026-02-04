class BarcodeListResponseModel {
  final List<BarcodeModel>? barcodes;

  BarcodeListResponseModel({
    this.barcodes,
  });

  factory BarcodeListResponseModel.fromJson(Map<String, dynamic> json) {
    return BarcodeListResponseModel(
      barcodes: json['barcodes'] != null
          ? List<BarcodeModel>.from(
          json['barcodes'].map((x) => BarcodeModel.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcodes': barcodes?.map((x) => x.toJson()).toList(),
    };
  }
}


class BarcodeModel {
  final String? barcode;
  final String? image;

  BarcodeModel({
    this.barcode,
    this.image,
  });

  factory BarcodeModel.fromJson(Map<String, dynamic> json) {
    return BarcodeModel(
      barcode: json['barcode'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'image': image,
    };
  }
}
