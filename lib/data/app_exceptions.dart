// Path: lib/data/app_exceptions.dart

class AppExceptions implements Exception {
  final dynamic _message; // ✅ Changed from String? to dynamic
  final String? _prefix;

  AppExceptions([this._message, this._prefix]);

  @override
  String toString() {
    // ✅ Handle null message
    if (_message == null) {
      return _prefix ?? "An error occurred";
    }

    // ✅ Handle Map type messages
    if (_message is Map) {
      try {
        final map = _message as Map;

        // Get first key-value pair
        if (map.isNotEmpty) {
          final firstKey = map.keys.first;
          final firstValue = map[firstKey];

          // If value is a List, get first item
          if (firstValue is List && firstValue.isNotEmpty) {
            return "$_prefix${firstValue[0]}";
          }
          // If value is String, return it
          else if (firstValue is String) {
            return "$_prefix$firstValue";
          }
        }

        // If we can't parse the map, return generic message
        return "${_prefix}An error occurred";
      } catch (e) {
        return "${_prefix}An error occurred";
      }
    }

    // ✅ Handle String and other types
    return "$_prefix$_message";
  }

  // ✅ Helper method to get clean message
  String get message {
    if (_message == null) return "An error occurred";

    if (_message is Map) {
      try {
        final map = _message as Map;
        if (map.isNotEmpty) {
          final firstValue = map[map.keys.first];
          if (firstValue is List && firstValue.isNotEmpty) {
            return firstValue[0].toString();
          } else if (firstValue is String) {
            return firstValue;
          }
        }
      } catch (e) {
        return "An error occurred";
      }
    }

    return _message.toString();
  }
}

class InternetExceptions extends AppExceptions {
  InternetExceptions([String? message]) : super(message, "No Internet Connection: ");
}

class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message]) : super(message, "Request Timeout: ");
}

class FetchDataException extends AppExceptions {
  FetchDataException([dynamic message]) : super(message, "Error Occurred During Communication: ");
}

class BadRequestException extends AppExceptions {
  BadRequestException([dynamic message]) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends AppExceptions {
  UnauthorizedException([dynamic message]) : super(message, "Unauthorized: ");
}

class ServerException extends AppExceptions {
  ServerException([dynamic message]) : super(message, "Internal Server Error: ");
}

// // Path: lib/data/app_exceptions.dart
//
// class AppExceptions implements Exception {
//   final String? _message;
//   final String? _prefix;
//
//   AppExceptions([this._message, this._prefix]);
//
//   @override
//   String toString() {
//     return "$_prefix$_message";
//   }
// }
//
// class InternetExceptions extends AppExceptions {
//   InternetExceptions([String? message]) : super(message, "No Internet Connection");
// }
//
// class RequestTimeOut extends AppExceptions {
//   RequestTimeOut([String? message]) : super(message, "Request Timeout");
// }
//
// class FetchDataException extends AppExceptions {
//   FetchDataException([String? message]) : super(message, "Error Occurred During Communication: ");
// }
//
// class BadRequestException extends AppExceptions {
//   BadRequestException([String? message]) : super(message, "Invalid Request: ");
// }
//
// class UnauthorizedException extends AppExceptions {
//   UnauthorizedException([String? message]) : super(message, "Unauthorized: ");
// }
//
// class ServerException extends AppExceptions {
//   ServerException([String? message]) : super(message, "Internal Server Error: ");
// }
