import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/app_exceptions.dart';
import '../../res/components/widgets/custom_error_dialog.dart';

mixin BaseController {
  void handleError(dynamic error, {VoidCallback? onRetry}) {
    if (Get.isDialogOpen ?? false) return;

    String title = "Error";
    String message = error.toString();
    IconData icon = Icons.error_outline_rounded;
    Color color = Colors.red;

    if (error is InternetExceptions) {
      title = "No Internet";
      icon = Icons.wifi_off_rounded;
      color = Colors.orange;
    } else if (error is ServerException) {
      title = "Server Error";
      icon = Icons.dns_rounded;
    } else if (error is UnauthorizedException) {
      title = "Session Expired";
      icon = Icons.lock_outline_rounded;
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