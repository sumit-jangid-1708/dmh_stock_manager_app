class LeadStatusHistoryResponse {
  final int count;
  final List<LeadStatusHistoryModel> results;

  LeadStatusHistoryResponse({required this.count, required this.results});

  factory LeadStatusHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LeadStatusHistoryResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((item) => LeadStatusHistoryModel.fromJson(item))
          .toList(),
    );
  }
}

class LeadStatusHistoryModel {
  final int id;
  final String oldStatus;
  final String oldStatusDisplay;
  final String newStatus;
  final String newStatusDisplay;
  final String reason;
  final int changedBy;
  final String changedByName;
  final String createdAt;

  LeadStatusHistoryModel({
    required this.id,
    required this.oldStatus,
    required this.oldStatusDisplay,
    required this.newStatus,
    required this.newStatusDisplay,
    required this.reason,
    required this.changedBy,
    required this.changedByName,
    required this.createdAt,
  });

  factory LeadStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return LeadStatusHistoryModel(
      id: json['id'] ?? 0,
      oldStatus: json['old_status']?.toString() ?? '',
      oldStatusDisplay: json['old_status_display']?.toString() ?? '',
      newStatus: json['new_status']?.toString() ?? '',
      newStatusDisplay: json['new_status_display']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      changedBy: json['changed_by'] ?? 0,
      changedByName: json['changed_by_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
