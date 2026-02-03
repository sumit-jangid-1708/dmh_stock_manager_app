class CourierReturnResponse {
  final String message;
  final int id;

  CourierReturnResponse({
    required this.message,
    required this.id,
  });

  factory CourierReturnResponse.fromJson(Map<String, dynamic> json) {
    return CourierReturnResponse(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
