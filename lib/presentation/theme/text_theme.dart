
import 'package:alghaya_men_alkhalg/core/constants.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';


final lightTextTheme = TextTheme(
  bodyLarge: TextStyle(fontFamily: AppFontFamilies.notoBold, color: AppColors.lightTextPrimary, fontSize: 24,),
  bodyMedium: TextStyle(fontFamily: AppFontFamilies.notoRegular,color: AppColors.lightTextSecondary, fontSize: 15),
  bodySmall: TextStyle(fontFamily: AppFontFamilies.notoRegular,color: AppColors.lightTextSecondary, fontSize: 12),

);


final darkTextTheme = TextTheme(
  bodyLarge: TextStyle(fontFamily: AppFontFamilies.notoBold, color: AppColors.darkTextPrimary, fontSize: 24,),
  bodyMedium: TextStyle(fontFamily: AppFontFamilies.notoRegular,color: AppColors.darkTextSecondary, fontSize: 15),
  bodySmall: TextStyle(fontFamily: AppFontFamilies.notoRegular,color: AppColors.darkTextSecondary, fontSize: 12),

);