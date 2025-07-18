import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

InputDecorationTheme buildLightTextFieldTheme(TextTheme textTheme) {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightCard,

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFFB8B3A9),width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),

    hintStyle: textTheme.bodyMedium?.copyWith(
      color: AppColors.lightTextSecondary,
    ),
    labelStyle: textTheme.bodyMedium,
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    iconColor: AppColors.lightPrimary,
  );
}

InputDecorationTheme buildDarkTextFieldTheme(TextTheme textTheme) {
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,

    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey,width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkSecondary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),

    hintStyle: textTheme.bodyMedium?.copyWith(
      color: AppColors.darkTextSecondary,
    ),
    labelStyle: textTheme.bodyMedium,
    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    iconColor: AppColors.darkPrimary,
  );
}
