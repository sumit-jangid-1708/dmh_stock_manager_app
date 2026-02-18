class CustomerReturnResponse {
  final String message;
  final int id;
  final String condition;
  final List<String> serialsProcessed;
  final String newStatus;

  CustomerReturnResponse({
    required this.message,
    required this.id,
    required this.condition,
    required this.serialsProcessed,
    required this.newStatus,
  });

  factory CustomerReturnResponse.fromJson(Map<String, dynamic> json) {
    return CustomerReturnResponse(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
      condition: json['condition'] ?? '',
      serialsProcessed: List<String>.from(json['serials_processed'] ?? []),
      newStatus: json['new_status'] ?? '',
    );
  }
}



// class CustomerReturnResponse {
//   final String message;
//   final int id;
//
//   CustomerReturnResponse({required this.message, required this.id});
//
//   factory CustomerReturnResponse.fromJson(Map<String, dynamic> json) {
//     return CustomerReturnResponse(
//       message: json['message'] ?? '',
//       id: json['id'] ?? 0,
//     );
//   }
// }
