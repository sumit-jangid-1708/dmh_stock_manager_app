class ActivityLogResponse {
  final int? count;
  final String? next;
  final String? previous;
  final List<ActivityLog> results;

  ActivityLogResponse({
    this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory ActivityLogResponse.fromJson(Map<String, dynamic> json) {
    return ActivityLogResponse(
      count: json['count'] as int?,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => ActivityLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}

class ActivityLog {
  final int id;
  final int? userId;
  final String? username;
  final String? event;
  final String? description;
  final String? screen;
  final String? target;
  final ActivityMetadata? metadata;
  final DateTime? clientTimestamp;
  final String? appVersion;
  final String? deviceId;
  final String? ipAddress;
  final DateTime? createdAt;

  ActivityLog({
    required this.id,
    this.userId,
    this.username,
    this.event,
    this.description,
    this.screen,
    this.target,
    this.metadata,
    this.clientTimestamp,
    this.appVersion,
    this.deviceId,
    this.ipAddress,
    this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as int,
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      event: json['event'] as String?,
      description: json['description'] as String?,
      screen: json['screen'] as String?,
      target: json['target'] as String?,
      metadata: json['metadata'] != null
          ? ActivityMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      clientTimestamp: json['client_timestamp'] != null
          ? DateTime.tryParse(json['client_timestamp'] as String)
          : null,
      appVersion: json['app_version'] as String?,
      deviceId: json['device_id'] as String?,
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'event': event,
      'description': description,
      'screen': screen,
      'target': target,
      'metadata': metadata?.toJson(),
      'client_timestamp': clientTimestamp?.toIso8601String(),
      'app_version': appVersion,
      'device_id': deviceId,
      'ip_address': ipAddress,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class ActivityMetadata {
  final String? method; // GET / POST / etc.
  final dynamic result; // shape varies per screen -> kept dynamic
  final dynamic request; // request payload/body (varies)
  final String? description;
  final int? durationMs;
  final int? statusCode;
  final List<String> queryParameters;

  ActivityMetadata({
    this.method,
    this.result,
    this.request,
    this.description,
    this.durationMs,
    this.statusCode,
    this.queryParameters = const [],
  });

  factory ActivityMetadata.fromJson(Map<String, dynamic> json) {
    return ActivityMetadata(
      method: json['method'] as String?,
      result: json['result'],
      request: json['request'],
      description: json['description'] as String?,
      durationMs: json['duration_ms'] as int?,
      statusCode: json['status_code'] as int?,
      queryParameters: (json['query_parameters'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'result': result,
      'request': request,
      'description': description,
      'duration_ms': durationMs,
      'status_code': statusCode,
      'query_parameters': queryParameters,
    };
  }

  /// Helper: agar result ke andar {"data": {...}} ya {"status":200,...}
  /// jaisa common wrapper ho to yahan se easily access kar sakte hain.
  Map<String, dynamic>? get resultAsMap =>
      result is Map<String, dynamic> ? result as Map<String, dynamic> : null;

  /// Helper: result.data (jaise low-stock API me hota hai)
  Map<String, dynamic>? get resultData {
    final map = resultAsMap;
    if (map != null && map['data'] is Map<String, dynamic>) {
      return map['data'] as Map<String, dynamic>;
    }
    return null;
  }
}