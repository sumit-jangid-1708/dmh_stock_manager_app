import 'package:dmj_stock_manager/model/login_model.dart';
import 'package:dmj_stock_manager/res/routes/routes_names.dart';
import 'package:dmj_stock_manager/view_models/services/auth_service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;

  final GetStorage storage = GetStorage();
  final AuthService authService = AuthService();


  /// verify the Otp
  void verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      Get.snackbar("Invalid OTP", "OTP must be 6 digits");
      return;
    }

    try {
      isLoading.value = true;
      final data = {"otp": otp};

      final LoginResponseModel response = await authService.loginApi(data);

      if (response.token.isNotEmpty) {
        storage.write("access_token", response.token);
        print("access_token 🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢🤢 ${response.token}");
        Get.snackbar("Success", "Login successful!");
        Get.offAllNamed(RouteName.dashboard);
      } else {
        Get.snackbar("Error", "Invalid OTP or no token received");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }


  /// logout from the app
  void logout() {
    storage.remove("access_token");
    otpController.clear();
    Get.offAllNamed(RouteName.auth); // go back to login screen
  }
}
