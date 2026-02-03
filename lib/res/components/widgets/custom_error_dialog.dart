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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack( // Close icon ko corner me set karne ke liye stack use kiya
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 60, color: color),
                const SizedBox(height: 15),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A4F)),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // --- Action Buttons Row ---
                Row(
                  children: [
                    // Back/Cancel Button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Close", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Main Retry/Okay Button
                    Expanded(
                      flex: 2, // Isko thoda bada dikhane ke liye
                      child: AppGradientButton(
                        onPressed: () {
                          Get.back();
                          if (onRetry != null) onRetry!();
                        },
                        text: onRetry != null ? "Retry" : "Okay",
                        height: 48,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          // --- Top Right Corner Close Icon ---
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}