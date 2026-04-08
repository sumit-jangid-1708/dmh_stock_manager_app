class CourierPartnerDetailModel {
  final int id;
  final String title;
  final List<MediatorDetailModel> mediators;

  CourierPartnerDetailModel({
    required this.id,
    required this.title,
    required this.mediators,
  });

  factory CourierPartnerDetailModel.fromJson(Map<String, dynamic> json) {
    return CourierPartnerDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      mediators: json['mediators'] != null
          ? List<MediatorDetailModel>.from(
        json['mediators']
            .map((x) => MediatorDetailModel.fromJson(x)),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mediators': mediators.map((x) => x.toJson()).toList(),
    };
  }

  CourierPartnerDetailModel copyWith({
    int? id,
    String? title,
    List<MediatorDetailModel>? mediators,
  }) {
    return CourierPartnerDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
      mediators: mediators ?? this.mediators,
    );
  }
}

class MediatorDetailModel {
  final int id;
  final String title;

  MediatorDetailModel({
    required this.id,
    required this.title,
  });

  factory MediatorDetailModel.fromJson(Map<String, dynamic> json) {
    return MediatorDetailModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }

  MediatorDetailModel copyWith({
    int? id,
    String? title,
  }) {
    return MediatorDetailModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }
}