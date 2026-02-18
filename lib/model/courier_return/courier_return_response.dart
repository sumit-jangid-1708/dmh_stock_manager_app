class CourierReturnResponse {
  final String message;
  final int id;
  final String condition;
  final List<String> serialsProcessed;
  final String newStatus;

  CourierReturnResponse({
    required this.message,
    required this.id,
    required this.condition,
    required this.serialsProcessed,
    required this.newStatus,
  });

  factory CourierReturnResponse.fromJson(Map<String, dynamic> json) {
    return CourierReturnResponse(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
      condition: json['condition'] ?? '',
      serialsProcessed: List<String>.from(json['serials_processed'] ?? []),
      newStatus: json['new_status'] ?? '',
    );
  }
}

// class CourierReturnResponse {
//   final String message;
//   final int id;
//
//   CourierReturnResponse({
//     required this.message,
//     required this.id,
//   });
//
//   factory CourierReturnResponse.fromJson(Map<String, dynamic> json) {
//     return CourierReturnResponse(
//       message: json['message'] ?? '',
//       id: json['id'] ?? 0,
//     );
//   }
// }
