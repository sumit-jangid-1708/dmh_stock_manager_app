import 'package:flutter/material.dart';

class AppGradientButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;

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
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A4F), Color(0xFF4A4ABF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A1A4F).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (icon != null && text != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: fontSize + 4),
          const SizedBox(width: 6),
          Text(
            text!,
            style: TextStyle(fontSize: fontSize, color: textColor),
          ),
        ],
      );
    }

    if (icon != null) {
      return Icon(icon, color: textColor);
    }

    return Text(
      text!,
      style: TextStyle(fontSize: fontSize, color: textColor),
    );
  }
}
