import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ButtonVariant { primary, secondary, outlined }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget childContent;
    if (isLoading) {
      childContent = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: variant == ButtonVariant.outlined ? AppColors.primary : Colors.white,
        ),
      );
    } else if (icon != null) {
      childContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      );
    } else {
      childContent = Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      );
    }

    if (variant == ButtonVariant.outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          ),
          child: childContent,
        ),
      );
    }

    final bgColor = switch (variant) {
      ButtonVariant.primary => AppColors.primary,
      ButtonVariant.secondary => isDark ? AppColors.darkCard : const Color(0xFFE2E8F0),
      _ => AppColors.primary,
    };

    final fgColor = switch (variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      _ => Colors.white,
    };

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: childContent,
      ),
    );
  }
}
