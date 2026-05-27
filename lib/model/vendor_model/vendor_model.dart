class VendorModel {
  final int id;
  final String vendorName;
  final String phoneNumber;
  final String countryCode;
  final String? email;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final bool withGst;
  final String? firmName;
  final String? gstNumber;
  final String initials; // ✅ NEW
  final String fullLocation; // ✅ NEW

  VendorModel({
    required this.id,
    required this.vendorName,
    required this.countryCode,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.withGst,
    this.firmName,
    this.gstNumber,
    required this.initials, // ✅ NEW
    required this.fullLocation, // ✅ NEW
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json["id"],
      vendorName: json["name"] ?? "",
      phoneNumber: json["mobile"] ?? "",
      countryCode: json["country_code"] ?? "",
      email: json["email"],
      address: json["address"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      pinCode: json["pin_code"] ?? "",
      country: json["country"] ?? "",
      withGst: json["with_Gst"] ?? false,
      firmName: json["firm_name"],
      gstNumber: json["gst_number"],
      initials: json["initials"] ?? "", // ✅ NEW
      fullLocation: json["full_location"] ?? "", // ✅ NEW
    );
  }

  @override
  String toString() => vendorName;
}
