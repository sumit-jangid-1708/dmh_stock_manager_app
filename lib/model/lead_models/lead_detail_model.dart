class LeadDetailModel {
  final int id;
  final String leadId;
  final String fullName;
  final String shippingName;
  final String countryCode;
  final String phone;
  final String shippingPhone;
  final String whatsappNumber;
  final String email;
  final String companyName;
  final String designation;
  final String source;
  final String sourceDisplay;
  final String priority;
  final String priorityDisplay;
  final int? assignedTo;
  final String? assignedToName;
  final String status;
  final String statusDisplay;
  final List<dynamic> tags;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String shippingAddress1;
  final String shippingAddress2;
  final String shippingCity;
  final String shippingZip;
  final String shippingProvince;
  final String shippingProvinceName;
  final String shippingCountry;
  final String externalSource;
  final dynamic externalCheckoutId;
  final List<dynamic> products;
  final String notes;
  final String lostReason;
  final String lostReasonDisplay;
  final String lostNotes;
  final String? lostAt;
  final int? lostBy;
  final String? lostByName;
  final String? nextFollowUp;
  final String createdAt;
  final String updatedAt;
  final int createdBy;
  final String createdByName;
  final int updatedBy;
  final String updatedByName;
  final List<LeadActivity> activities;
  final List<dynamic> followUps;
  final List<dynamic> leadNotes;

  LeadDetailModel({
    required this.id,
    required this.leadId,
    required this.fullName,
    required this.shippingName,
    required this.countryCode,
    required this.phone,
    required this.shippingPhone,
    required this.whatsappNumber,
    required this.email,
    required this.companyName,
    required this.designation,
    required this.source,
    required this.sourceDisplay,
    required this.priority,
    required this.priorityDisplay,
    this.assignedTo,
    this.assignedToName,
    required this.status,
    required this.statusDisplay,
    required this.tags,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.shippingAddress1,
    required this.shippingAddress2,
    required this.shippingCity,
    required this.shippingZip,
    required this.shippingProvince,
    required this.shippingProvinceName,
    required this.shippingCountry,
    required this.externalSource,
    this.externalCheckoutId,
    required this.products,
    required this.notes,
    required this.lostReason,
    required this.lostReasonDisplay,
    required this.lostNotes,
    this.lostAt,
    this.lostBy,
    this.lostByName,
    this.nextFollowUp,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.createdByName,
    required this.updatedBy,
    required this.updatedByName,
    required this.activities,
    required this.followUps,
    required this.leadNotes,
  });

  factory LeadDetailModel.fromJson(Map<String, dynamic> json) {
    return LeadDetailModel(
      id: json['id'] ?? 0,
      leadId: json['lead_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      shippingName: json['shipping_name']?.toString() ?? '',
      countryCode: json['country_code']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      shippingPhone: json['shipping_phone']?.toString() ?? '',
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      sourceDisplay: json['source_display']?.toString() ?? '',
      priority: json['priority']?.toString() ?? '',
      priorityDisplay: json['priority_display']?.toString() ?? '',
      assignedTo: json['assigned_to'],
      assignedToName: json['assigned_to_name']?.toString(),
      status: json['status']?.toString() ?? '',
      statusDisplay: json['status_display']?.toString() ?? '',
      tags: json['tags'] as List? ?? [],
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      shippingAddress1: json['shipping_address1']?.toString() ?? '',
      shippingAddress2: json['shipping_address2']?.toString() ?? '',
      shippingCity: json['shipping_city']?.toString() ?? '',
      shippingZip: json['shipping_zip']?.toString() ?? '',
      shippingProvince: json['shipping_province']?.toString() ?? '',
      shippingProvinceName: json['shipping_province_name']?.toString() ?? '',
      shippingCountry: json['shipping_country']?.toString() ?? '',
      externalSource: json['external_source']?.toString() ?? '',
      externalCheckoutId: json['external_checkout_id'],
      products: json['products'] as List? ?? [],
      notes: json['notes']?.toString() ?? '',
      lostReason: json['lost_reason']?.toString() ?? '',
      lostReasonDisplay: json['lost_reason_display']?.toString() ?? '',
      lostNotes: json['lost_notes']?.toString() ?? '',
      lostAt: json['lost_at']?.toString(),
      lostBy: json['lost_by'],
      lostByName: json['lost_by_name']?.toString(),
      nextFollowUp: json['next_follow_up']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name']?.toString() ?? '',
      updatedBy: json['updated_by'] ?? 0,
      updatedByName: json['updated_by_name']?.toString() ?? '',
      activities: (json['activities'] as List? ?? [])
          .map((e) => LeadActivity.fromJson(e))
          .toList(),
      followUps: json['follow_ups'] as List? ?? [],
      leadNotes: json['lead_notes'] as List? ?? [],
    );
  }
}

class LeadActivity {
  final int id;
  final String event;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final int actor;
  final String actorName;
  final String createdAt;

  LeadActivity({
    required this.id,
    required this.event,
    required this.title,
    required this.description,
    required this.metadata,
    required this.actor,
    required this.actorName,
    required this.createdAt,
  });

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      id: json['id'] ?? 0,
      event: json['event']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      actor: json['actor'] ?? 0,
      actorName: json['actor_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
