class LeadChoice {
  final String value;
  final String label;

  const LeadChoice({required this.value, required this.label});

  factory LeadChoice.fromJson(Map<String, dynamic> json) => LeadChoice(
    value: json['value']?.toString() ?? '',
    label: json['label']?.toString() ?? '',
  );
}

class LeadEmployee {
  final int id;
  final String name;
  final String username;

  const LeadEmployee({
    required this.id,
    required this.name,
    required this.username,
  });

  factory LeadEmployee.fromJson(Map<String, dynamic> json) => LeadEmployee(
    id: _asInt(json['id']),
    name: json['name']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
  );
}

class LeadProduct {
  final int id;
  final String name;
  final String sku;
  final String retailerPrice;

  const LeadProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.retailerPrice,
  });

  factory LeadProduct.fromJson(Map<String, dynamic> json) => LeadProduct(
    id: _asInt(json['id']),
    name: json['name']?.toString() ?? '',
    sku: json['sku']?.toString() ?? '',
    retailerPrice: json['retailer_price']?.toString() ?? '0',
  );
}

class LeadOptions {
  final List<LeadChoice> statuses;
  final List<LeadChoice> priorities;
  final List<LeadChoice> sources;
  final List<LeadChoice> lostReasons;
  final List<LeadChoice> followUpTypes;
  final List<LeadChoice> followUpStatuses;
  final List<LeadChoice> paymentStatuses;
  final List<LeadEmployee> employees;
  final List<Map<String, dynamic>> countries;
  final List<LeadProduct> products;

  const LeadOptions({
    this.statuses = const [],
    this.priorities = const [],
    this.sources = const [],
    this.lostReasons = const [],
    this.followUpTypes = const [],
    this.followUpStatuses = const [],
    this.paymentStatuses = const [],
    this.employees = const [],
    this.countries = const [],
    this.products = const [],
  });

  factory LeadOptions.fromJson(Map<String, dynamic> json) => LeadOptions(
    statuses: _choices(json['statuses']),
    priorities: _choices(json['priorities']),
    sources: _choices(json['sources']),
    lostReasons: _choices(json['lost_reasons']),
    followUpTypes: _choices(json['follow_up_types']),
    followUpStatuses: _choices(json['follow_up_statuses']),
    paymentStatuses: _choices(json['payment_statuses']),
    employees: _maps(json['employees']).map(LeadEmployee.fromJson).toList(),
    countries: _maps(json['countries']),
    products: _maps(json['products']).map(LeadProduct.fromJson).toList(),
  );
}

class LeadStats {
  final int total,
      newCount,
      active,
      converted,
      lost,
      followUpsToday,
      overdueFollowUps;
  final double conversionRate;

  const LeadStats({
    this.total = 0,
    this.newCount = 0,
    this.active = 0,
    this.converted = 0,
    this.lost = 0,
    this.followUpsToday = 0,
    this.overdueFollowUps = 0,
    this.conversionRate = 0,
  });

  factory LeadStats.fromJson(Map<String, dynamic> json) => LeadStats(
    total: _asInt(json['total']),
    newCount: _asInt(json['new']),
    active: _asInt(json['active']),
    converted: _asInt(json['converted']),
    lost: _asInt(json['lost']),
    followUpsToday: _asInt(json['follow_ups_today']),
    overdueFollowUps: _asInt(json['overdue_follow_ups']),
    conversionRate: _asDouble(json['conversion_rate']),
  );
}

class LeadModel {
  final int id;
  final String leadId,
      fullName,
      shippingName,
      countryCode,
      phone,
      shippingPhone,
      whatsappNumber,
      email,
      companyName,
      designation,
      address,
      address1,
      address2,
      city,
      state,
      pincode,
      zip,
      province,
      provinceName,
      country,
      shippingAddress1,
      shippingAddress2,
      shippingCity,
      shippingZip,
      shippingProvince,
      shippingProvinceName,
      shippingCountry,
      externalSource,
      status,
      statusDisplay,
      priority,
      priorityDisplay,
      source,
      sourceDisplay,
      notes,
      lostReason,
      lostReasonDisplay,
      lostNotes,
      createdAt,
      updatedAt,
      createdByName,
      updatedByName;
  final int? assignedTo, lostBy;
  final int createdBy, updatedBy;
  final String assignedToName, lostByName;
  final dynamic nextFollowUp, externalCheckoutId;
  final String? lostAt;
  final List<dynamic> tags;
  final List<LeadProduct> products;
  final List<Map<String, dynamic>> activities,
      followUps,
      leadNotes,
      statusHistory;
  final Map<String, dynamic>? conversion;

  const LeadModel({
    required this.id,
    this.leadId = '',
    this.fullName = '',
    this.shippingName = '',
    this.countryCode = '',
    this.phone = '',
    this.shippingPhone = '',
    this.whatsappNumber = '',
    this.email = '',
    this.companyName = '',
    this.designation = '',
    this.address = '',
    this.address1 = '',
    this.address2 = '',
    this.city = '',
    this.state = '',
    this.pincode = '',
    this.zip = '',
    this.province = '',
    this.provinceName = '',
    this.country = '',
    this.shippingAddress1 = '',
    this.shippingAddress2 = '',
    this.shippingCity = '',
    this.shippingZip = '',
    this.shippingProvince = '',
    this.shippingProvinceName = '',
    this.shippingCountry = '',
    this.externalSource = '',
    this.status = '',
    this.statusDisplay = '',
    this.priority = '',
    this.priorityDisplay = '',
    this.source = '',
    this.sourceDisplay = '',
    this.notes = '',
    this.lostReason = '',
    this.lostReasonDisplay = '',
    this.lostNotes = '',
    this.lostAt,
    this.lostBy,
    this.lostByName = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.assignedTo,
    this.assignedToName = '',
    this.nextFollowUp,
    this.externalCheckoutId,
    this.tags = const [],
    this.createdBy = 0,
    this.createdByName = '',
    this.updatedBy = 0,
    this.updatedByName = '',
    this.products = const [],
    this.activities = const [],
    this.followUps = const [],
    this.leadNotes = const [],
    this.statusHistory = const [],
    this.conversion,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
    id: _asInt(json['id']),
    leadId: json['lead_id']?.toString() ?? '',
    fullName: json['full_name']?.toString() ?? '',
    shippingName:
        json['shipping_name']?.toString() ??
        json['full_name']?.toString() ??
        '',
    countryCode: json['country_code']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    shippingPhone: json['shipping_phone']?.toString() ?? '',
    whatsappNumber: json['whatsapp_number']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    companyName: json['company_name']?.toString() ?? '',
    designation: json['designation']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    address1: json['shipping_address1']?.toString() ?? '',
    address2: json['shipping_address2']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    pincode: json['pincode']?.toString() ?? '',
    zip: json['pincode']?.toString() ?? '',
    province: json['shipping_province']?.toString() ?? '',
    provinceName: json['shipping_province_name']?.toString() ?? '',
    country: json['country']?.toString() ?? '',
    shippingAddress1: json['shipping_address1']?.toString() ?? '',
    shippingAddress2: json['shipping_address2']?.toString() ?? '',
    shippingCity: json['shipping_city']?.toString() ?? '',
    shippingZip: json['shipping_zip']?.toString() ?? '',
    shippingProvince: json['shipping_province']?.toString() ?? '',
    shippingProvinceName: json['shipping_province_name']?.toString() ?? '',
    shippingCountry: json['shipping_country']?.toString() ?? '',
    externalSource: json['external_source']?.toString() ?? '',
    externalCheckoutId: json['external_checkout_id'],
    status: json['status']?.toString() ?? '',
    statusDisplay: json['status_display']?.toString() ?? '',
    priority: json['priority']?.toString() ?? '',
    priorityDisplay: json['priority_display']?.toString() ?? '',
    source: json['source']?.toString() ?? '',
    sourceDisplay: json['source_display']?.toString() ?? '',
    notes: json['notes']?.toString() ?? '',
    lostReason: json['lost_reason']?.toString() ?? '',
    lostReasonDisplay: json['lost_reason_display']?.toString() ?? '',
    lostNotes: json['lost_notes']?.toString() ?? '',
    lostAt: json['lost_at']?.toString(),
    lostBy: json['lost_by'] == null ? null : _asInt(json['lost_by']),
    lostByName: json['lost_by_name']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    updatedAt: json['updated_at']?.toString() ?? '',
    assignedTo: json['assigned_to'] == null
        ? null
        : _asInt(
            json['assigned_to'] is Map
                ? json['assigned_to']['id']
                : json['assigned_to'],
          ),
    assignedToName:
        json['assigned_to_name']?.toString() ??
        (json['assigned_to'] is Map
            ? json['assigned_to']['name']?.toString() ?? ''
            : ''),
    nextFollowUp: json['next_follow_up'],
    tags: json['tags'] is List ? List<dynamic>.from(json['tags']) : const [],
    createdBy: _asInt(json['created_by']),
    createdByName: json['created_by_name']?.toString() ?? '',
    updatedBy: _asInt(json['updated_by']),
    updatedByName: json['updated_by_name']?.toString() ?? '',
    products: _maps(json['products']).map(LeadProduct.fromJson).toList(),
    activities: _maps(json['activities']),
    followUps: _maps(json['follow_ups']),
    leadNotes: _maps(json['lead_notes']),
    statusHistory: _maps(json['status_history']),
    conversion: json['conversion'] is Map
        ? Map<String, dynamic>.from(json['conversion'])
        : null,
  );
}

List<Map<String, dynamic>> _maps(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];
List<LeadChoice> _choices(dynamic value) =>
    _maps(value).map(LeadChoice.fromJson).toList();
int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
double _asDouble(dynamic value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

class GetLeadsModel {
  final int count;
  final int page;
  final int pages;
  final List<LeadModel> results;

  const GetLeadsModel({
    required this.count,
    required this.page,
    required this.pages,
    required this.results,
  });

  factory GetLeadsModel.fromJson(Map<String, dynamic> json) {
    return GetLeadsModel(
      count: _asInt(json['count']),
      page: _asInt(json['page']),
      pages: _asInt(json['pages']),
      results: _maps(json['results']).map(LeadModel.fromJson).toList(),
    );
  }
}
