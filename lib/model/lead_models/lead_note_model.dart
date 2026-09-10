class LeadNoteResponse {
  final int count;
  final List<LeadNoteModel> results;

  LeadNoteResponse({required this.count, required this.results});

  factory LeadNoteResponse.fromJson(Map<String, dynamic> json) {
    return LeadNoteResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((item) => LeadNoteModel.fromJson(item))
          .toList(),
    );
  }
}

class LeadNoteModel {
  final int id;
  final int lead;
  final String note;
  final int createdBy;
  final String createdByName;
  final String createdAt;

  LeadNoteModel({
    required this.id,
    required this.lead,
    required this.note,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory LeadNoteModel.fromJson(Map<String, dynamic> json) {
    return LeadNoteModel(
      id: json['id'] ?? 0,
      lead: json['lead'] ?? 0,
      note: json['note']?.toString() ?? '',
      createdBy: json['created_by'] ?? 0,
      createdByName: json['created_by_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
