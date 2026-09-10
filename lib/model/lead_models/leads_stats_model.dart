class LeadStatsModel {
  final int total;
  final int newLeads;
  final int active;
  final int converted;
  final int lost;
  final int followUpsToday;
  final int overdueFollowUps;
  final double conversionRate;

  LeadStatsModel({
    required this.total,
    required this.newLeads,
    required this.active,
    required this.converted,
    required this.lost,
    required this.followUpsToday,
    required this.overdueFollowUps,
    required this.conversionRate,
  });

  factory LeadStatsModel.fromJson(Map<String, dynamic> json) {
    return LeadStatsModel(
      total: _toInt(json['total']),
      newLeads: _toInt(json['new']),
      active: _toInt(json['active']),
      converted: _toInt(json['converted']),
      lost: _toInt(json['lost']),
      followUpsToday: _toInt(json['follow_ups_today']),
      overdueFollowUps: _toInt(json['overdue_follow_ups']),
      conversionRate: _toDouble(json['conversion_rate']),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
