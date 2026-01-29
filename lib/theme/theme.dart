import 'package:flutter/cupertino.dart';
import 'colors.dart';

class AppTheme {
  static CupertinoThemeData darkTheme = const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.darkBackground,
    barBackgroundColor: AppColors.surfaceDark,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.textPrimary,
      textStyle: TextStyle(
        color: AppColors.textPrimary,
        fontFamily: '.SF Pro Text',
      ),
    ),
  );

  static CupertinoThemeData lightTheme = const CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryBlue,
    scaffoldBackgroundColor: AppColors.lightBackground,
    barBackgroundColor: AppColors.surfaceLightMode,
    textTheme: CupertinoTextThemeData(
      primaryColor: CupertinoColors.black,
      textStyle: TextStyle(
        color: CupertinoColors.black,
        fontFamily: '.SF Pro Text',
      ),
    ),
  );
}
