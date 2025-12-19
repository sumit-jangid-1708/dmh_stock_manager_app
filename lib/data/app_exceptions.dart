// Path: lib/data/app_exceptions.dart

class AppExceptions implements Exception {
  final String? _message;
  final String? _prefix;

  AppExceptions([this._message, this._prefix]);

  @override
  String toString() {
    return "$_prefix$_message";
  }
}

class InternetExceptions extends AppExceptions {
  InternetExceptions([String? message]) : super(message, "No Internet Connection");
}

class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message]) : super(message, "Request Timeout");
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message]) : super(message, "Error Occurred During Communication: ");
}

class BadRequestException extends AppExceptions {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends AppExceptions {
  UnauthorizedException([String? message]) : super(message, "Unauthorized: ");
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message, "Internal Server Error: ");
}
