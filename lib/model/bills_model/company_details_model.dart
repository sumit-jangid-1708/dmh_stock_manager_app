// lib/model/company_details_model.dart

class CompanyDetails {
  final String name;
  final String? gst;
  final String address;
  final String phone;

  const CompanyDetails({
    required this.name,
    this.gst,
    required this.address,
    required this.phone,
  });

  /// Returns true if all required fields are non-empty.
  /// [gst] is intentionally excluded from this check as it is optional.
  bool get isValid =>
      name.trim().isNotEmpty &&
          address.trim().isNotEmpty &&
          phone.trim().isNotEmpty;

  /// Convenience copy-with for pre-filling in same session.
  /// To explicitly clear [gst], pass an empty string — passing null keeps
  /// the existing value (standard copyWith behaviour).
  CompanyDetails copyWith({
    String? name,
    String? gst,
    String? address,
    String? phone,
  }) {
    return CompanyDetails(
      name: name ?? this.name,
      gst: gst ?? this.gst,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() =>
      'CompanyDetails(name: $name, gst: $gst, address: $address, phone: $phone)';
}