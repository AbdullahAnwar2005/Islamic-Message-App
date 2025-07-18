import 'package:alghaya_men_alkhalg/presentation/theme/app_bar_theme.dart';
import 'package:alghaya_men_alkhalg/presentation/theme/text_field_theme.dart';
import 'package:alghaya_men_alkhalg/presentation/theme/text_theme.dart';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';



// light theme data
final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.lightPrimary,
  appBarTheme: lightThemeAppBar,
  cardColor: AppColors.lightCard,
  textTheme: lightTextTheme,
  colorScheme: ColorScheme.light(
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightButton,
      foregroundColor: Colors.white,
    ),
  ),
  inputDecorationTheme: buildLightTextFieldTheme(lightTextTheme),

);

// dark theme data
final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  primaryColor: AppColors.darkPrimary,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkCard,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: AppColors.darkCard,
  textTheme: darkTextTheme,
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkButton,
      foregroundColor: Colors.black,
    ),
  ),
  inputDecorationTheme: buildDarkTextFieldTheme(darkTextTheme),
);
