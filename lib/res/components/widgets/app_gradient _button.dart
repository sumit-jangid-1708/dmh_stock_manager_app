// lib/res/components/widgets/app_gradient_button.dart

import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading; // ✅ Added

  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Color textColor;
  final EdgeInsets padding;

  const AppGradientButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false, // ✅ Added
    this.width,
    this.height = 40,
    this.borderRadius = 15,
    this.fontSize = 15,
    this.textColor = Colors.white,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  }) : assert(
  text != null || icon != null,
  "Either text or icon must be provided",
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading || onPressed == null
                ? [Colors.grey.shade400, Colors.grey.shade500] // ✅ Disabled state
                : [const Color(0xFF1A1A4F), const Color(0xFF4A4ABF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isLoading || onPressed == null
                  ? Colors.transparent
                  : const Color(0xFF1A1A4F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed, // ✅ Disable when loading
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledBackgroundColor: Colors.transparent, // ✅ Keep gradient visible
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // ✅ Show loading spinner
    if (isLoading) {
      return SizedBox(
        height: fontSize + 4,
        width: fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    // ✅ Icon + Text
    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: fontSize + 4),
          const SizedBox(width: 8),
          Text(
            text!,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // ✅ Icon only
    if (icon != null) {
      return Icon(icon, color: textColor, size: fontSize + 4);
    }

    // ✅ Text only
    return Text(
      text!,
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}