class LeadFollowUpResponse {
  final int count;
  final int page;
  final int pages;
  final List<LeadFollowUpModel> results;

  LeadFollowUpResponse({
    required this.count,
    required this.page,
    required this.pages,
    required this.results,
  });

  factory LeadFollowUpResponse.fromJson(Map<String, dynamic> json) {
    return LeadFollowUpResponse(
      count: json['count'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
      results: (json['results'] as List? ?? [])
          .map((item) => LeadFollowUpModel.fromJson(item))
          .toList(),
    );
  }
}

class LeadFollowUpModel {
  final int id;
  final int leadId;
  final String leadName;
  final String leadCode;
  final String followUpDate;
  final String followUpTime;
  final String followUpType;
  final String followUpTypeDisplay;
  final String status;
  final String statusDisplay;
  final String notes;
  final int? assignedTo;
  final String assignedToName;

  LeadFollowUpModel({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.leadCode,
    required this.followUpDate,
    required this.followUpTime,
    required this.followUpType,
    required this.followUpTypeDisplay,
    required this.status,
    required this.statusDisplay,
    required this.notes,
    this.assignedTo,
    required this.assignedToName,
  });

  factory LeadFollowUpModel.fromJson(Map<String, dynamic> json) {
    return LeadFollowUpModel(
      id: json['id'] ?? 0,
      leadId: json['lead_id'] ?? 0,
      leadName: json['lead_name']?.toString() ?? '',
      leadCode: json['lead_code']?.toString() ?? '',
      followUpDate: json['follow_up_date']?.toString() ?? '',
      followUpTime: json['follow_up_time']?.toString() ?? '',
      followUpType: json['follow_up_type']?.toString() ?? '',
      followUpTypeDisplay: json['follow_up_type_display']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusDisplay: json['status_display']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      assignedTo: json['assigned_to'],
      assignedToName: json['assigned_to_name']?.toString() ?? '',
    );
  }
}
