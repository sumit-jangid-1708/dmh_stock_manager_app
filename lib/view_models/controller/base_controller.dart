import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/app_exceptions.dart';
import '../../res/components/widgets/custom_error_dialog.dart';

mixin BaseController {
  void handleError(dynamic error, {VoidCallback? onRetry}) {
    if (Get.isDialogOpen ?? false) return;

    String title = "Error";
    String message = "Something went wrong. Please try again.";
    IconData icon = Icons.error_outline_rounded;
    Color color = Colors.red;

    if (error is InternetExceptions) {
      title = "No Internet";
      message = "Please check your internet connection and try again.";
      icon = Icons.wifi_off_rounded;
      color = Colors.orange;
    } else if (error is RequestTimeOut) {
      title = "Connection Slow";
      message =
          "Your connection is slow or the server took too long.\nPlease check your internet and try again.";
      icon = Icons.signal_wifi_statusbar_connected_no_internet_4_rounded;
      color = Colors.orange.shade700;
    } else if (error is UnauthorizedException) {
      // ✅ Token expire
      title = "Session Expired";
      message = "Your session has expired. Please login again.";
      icon = Icons.lock_outline_rounded;
      color = Colors.blue;
    } else if (error is ServerException) {
      // ✅ Server down ya 5xx error
      title = "Server Error";
      message = error.toString().contains("Server is not responding")
          ? "Server is not responding. Please try again later."
          : error.toString();
      icon = Icons.dns_rounded;
      color = Colors.red;
    } else if (error is AppExceptions) {
      // ✅ API se aaya specific error (400, stock error etc.)
      title = "Error";
      message = error.toString();
      icon = Icons.info_outline_rounded;
      color = Colors.red;
    } else {
      // ✅ Unknown error
      title = "Something Went Wrong";
      message = "An unexpected error occurred. Please try again.";
      icon = Icons.error_outline_rounded;
      color = Colors.red;
    }

    Get.dialog(
      CustomErrorDialog(
        title: title,
        message: message,
        icon: icon,
        color: color,
        onRetry: onRetry,
      ),
      barrierDismissible: false,
    );
  }
}
