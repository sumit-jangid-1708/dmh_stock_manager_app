class LeadsOptionsModel {
  final List<LeadOption> statuses;
  final List<LeadOption> priorities;
  final List<LeadOption> sources;
  final List<LeadOption> lostReasons;
  final List<LeadOption> followUpTypes;
  final List<LeadOption> followUpStatuses;
  final List<LeadOption> paymentStatuses;
  final List<Employee> employees;
  final List<Country> countries;
  final List<Product> products;

  LeadsOptionsModel({
    required this.statuses,
    required this.priorities,
    required this.sources,
    required this.lostReasons,
    required this.followUpTypes,
    required this.followUpStatuses,
    required this.paymentStatuses,
    required this.employees,
    required this.countries,
    required this.products,
  });

  factory LeadsOptionsModel.fromJson(Map<String, dynamic> json) {
    return LeadsOptionsModel(
      statuses: (json['statuses'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      priorities: (json['priorities'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      sources: (json['sources'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      lostReasons: (json['lost_reasons'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      followUpTypes: (json['follow_up_types'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      followUpStatuses: (json['follow_up_statuses'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      paymentStatuses: (json['payment_statuses'] as List? ?? [])
          .map((e) => LeadOption.fromJson(e))
          .toList(),

      employees: (json['employees'] as List? ?? [])
          .map((e) => Employee.fromJson(e))
          .toList(),

      countries: (json['countries'] as List? ?? [])
          .map((e) => Country.fromJson(e))
          .toList(),

      products: (json['products'] as List? ?? [])
          .map((e) => Product.fromJson(e))
          .toList(),
    );
  }
}


/// Status, Priority, Source, Lost Reason, etc.
class LeadOption {
  final String value;
  final String label;

  LeadOption({
    required this.value,
    required this.label,
  });

  factory LeadOption.fromJson(Map<String, dynamic> json) {
    return LeadOption(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}


class Employee {
  final int id;
  final String name;
  final String username;

  Employee({
    required this.id,
    required this.name,
    required this.username,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}


class Country {
  final String name;
  final String dialCode;

  Country({
    required this.name,
    required this.dialCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']?.toString() ?? '',
      dialCode: json['dial_code']?.toString() ?? '',
    );
  }
}


class Product {
  final int id;
  final String name;
  final String sku;
  final String size;
  final String color;
  final String retailerPrice;
  final String wholesalePrice;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.size,
    required this.color,
    required this.retailerPrice,
    required this.wholesalePrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      retailerPrice: json['retailer_price']?.toString() ?? '0.00',
      wholesalePrice: json['wholesale_price']?.toString() ?? '0.00',
    );
  }
}