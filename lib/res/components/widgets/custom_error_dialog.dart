import 'package:dmj_stock_manager/res/components/widgets/app_gradient%20_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onRetry;

  const CustomErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: color,),
            const SizedBox(height: 15,),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600),),
            const SizedBox(height: 20,),
            AppGradientButton(
                onPressed:(){
                  Get.back();
                  if(onRetry != null) onRetry!();
                },
              text: onRetry != null ? "Retry" : "Okay",
            )
          ],
        ),
      ),
    );
  }
}
