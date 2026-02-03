class CustomerReturnResponse {
  final String message;
  final int id;

  CustomerReturnResponse({required this.message, required this.id});

  factory CustomerReturnResponse.fromJson(Map<String, dynamic> json) {
    return CustomerReturnResponse(
      message: json['message'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
