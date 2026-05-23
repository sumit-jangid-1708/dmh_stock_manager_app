class AppExceptions implements Exception {
  final dynamic _message;
  AppExceptions([this._message]);

  @override
  String toString() {
    if (_message is Map) {
      return _message['message'] ?? _message['error'] ?? "Something went wrong";
    }
    return _message?.toString() ?? "An unexpected error occurred";
  }
}

class InternetExceptions extends AppExceptions {
  InternetExceptions() : super("No Internet Connection. Please check your network.");
}

class RequestTimeOut extends AppExceptions {

  RequestTimeOut() : super("Connection is slow or server not responding. Please try again.");
}

class ServerException extends AppExceptions {
  ServerException([String? msg]) : super(msg ?? "Server is not responding. Please try later.");
}

class UnauthorizedException extends AppExceptions {
  UnauthorizedException() : super("Session expired. Please login again.");
}