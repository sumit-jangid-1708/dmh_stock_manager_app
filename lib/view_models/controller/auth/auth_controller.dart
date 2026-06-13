import 'package:dmj_stock_manager/model/login_model.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/utils/app_alerts.dart';
import 'package:dmj_stock_manager/view_models/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../base_controller.dart';

class AuthController extends GetxController with BaseController {
  final otpController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final currentUser = Rxn<AppUserModel>();

  final GetStorage storage = GetStorage();
  final AuthService authService = AuthService();

  @override
  void onInit() {
    super.onInit();
    _loadStoredUser();
  }

  /// verify the Otp
  void verifyOtp() async {
    await loginWithPassword();
  }

  Future<void> loginWithPassword() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      AppAlerts.error("Username and password are required");
      return;
    }

    try {
      isLoading.value = true;
      final data = {"username": username, "password": password};

      final LoginResponseModel response = await authService.loginApi(data);

      if (response.token.isNotEmpty) {
        storage.write("access_token", response.token);
        if (response.user != null) {
          currentUser.value = response.user;
          storage.write("app_user", response.user!.toJson());
        }
        passwordController.clear();
        AppAlerts.success("Login successful! Welcome back");
        Get.offAllNamed(RouteName.dashboard);
      } else {
        AppAlerts.error("Invalid login or no token received");
      }
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  bool get isSuperAdmin {
    final user = currentUser.value;
    return user?.role == "super_admin";
  }

  bool canView(String moduleKey) {
    final user = currentUser.value;
    if (user == null) return false;
    if (isSuperAdmin) return true;
    return user.modules.contains(moduleKey);
  }

  bool canAction(String moduleKey, String action) {
    final user = currentUser.value;
    if (user == null) return false;
    if (isSuperAdmin) return true;
    return user.actionPermissions[moduleKey]?.contains(action) ?? false;
  }

  void _loadStoredUser() {
    final raw = storage.read("app_user");
    if (raw is Map) {
      currentUser.value = AppUserModel.fromJson(Map<String, dynamic>.from(raw));
    }
  }

  /// logout from the app
  void logout() {
    storage.remove("access_token");
    storage.remove("app_user");
    currentUser.value = null;
    otpController.clear();
    usernameController.clear();
    passwordController.clear();
    Get.offAllNamed(RouteName.auth); // go back to login screen
    AppAlerts.success("Logged out successfully");
  }
}
