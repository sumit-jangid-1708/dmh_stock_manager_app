class LoginResponseModel {
  final String token;
  final AppUserModel? user;

  LoginResponseModel({required this.token, this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: (json['token'] ?? '').toString(),
      user: json['user'] is Map<String, dynamic>
          ? AppUserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user?.toJson(),
    };
  }
}

class AppUserModel {
  final int id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String roleDisplay;
  final List<String> modules;
  final Map<String, List<String>> actionPermissions;

  AppUserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.roleDisplay,
    required this.modules,
    required this.actionPermissions,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      username: (json['username'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      roleDisplay: (json['role_display'] ?? json['role'] ?? 'User').toString(),
      modules: _stringList(json['modules']),
      actionPermissions: _permissions(json['action_permissions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'role': role,
      'role_display': roleDisplay,
      'modules': modules,
      'action_permissions': actionPermissions,
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).toList();
  }

  static Map<String, List<String>> _permissions(dynamic value) {
    final result = <String, List<String>>{};
    if (value is! Map) return result;
    value.forEach((key, permissions) {
      result[key.toString()] = _stringList(permissions);
    });
    return result;
  }
}
