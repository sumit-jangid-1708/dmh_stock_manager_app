class LeadActivityResponse {
  final int count;
  final List<LeadActivityModel> results;

  LeadActivityResponse({required this.count, required this.results});

  factory LeadActivityResponse.fromJson(Map<String, dynamic> json) {
    return LeadActivityResponse(
      count: json['count'] ?? 0,
      results: (json['results'] as List? ?? [])
          .map((item) => LeadActivityModel.fromJson(item))
          .toList(),
    );
  }
}

class LeadActivityModel {
  final int id;
  final String event;
  final String title;
  final String description;
  final Map<String, dynamic> metadata;
  final int actor;
  final String actorName;
  final String createdAt;

  LeadActivityModel({
    required this.id,
    required this.event,
    required this.title,
    required this.description,
    required this.metadata,
    required this.actor,
    required this.actorName,
    required this.createdAt,
  });

  factory LeadActivityModel.fromJson(Map<String, dynamic> json) {
    return LeadActivityModel(
      id: json['id'] ?? 0,
      event: json['event']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      actor: json['actor'] ?? 0,
      actorName: json['actor_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
