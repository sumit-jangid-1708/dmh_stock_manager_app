class CompanyListModel {
  final List<CompanyModel>? data;
  final int? count;

  CompanyListModel({
    this.data,
    this.count,
  });

  factory CompanyListModel.fromJson(Map<String, dynamic> json) {
    return CompanyListModel(
      data: (json['data'] as List?)
          ?.map(
            (e) => CompanyModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class CompanyModel {
  final int? id;
  final String? label;
  final String? companyName;
  final String? address;
  final String? gstin;
  final String? phone;
  final String? email;
  final String? terms;

  CompanyModel({
    this.id,
    this.label,
    this.companyName,
    this.address,
    this.gstin,
    this.phone,
    this.email,
    this.terms,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'],
      label: json['label'],
      companyName: json['company_name'],
      address: json['address'],
      gstin: json['gstin'],
      phone: json['phone'],
      email: json['email'],
      terms: json['terms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'company_name': companyName,
      'address': address,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'terms': terms,
    };
  }
}