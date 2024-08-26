import 'package:flutter/material.dart';

import 'color_util.dart';

ThemeData themeData = ThemeData(
  colorSchemeSeed: CustomColors.emeraldGreen,
  scaffoldBackgroundColor: CustomColors.deepCharcoal,
  appBarTheme: const AppBarTheme(
      backgroundColor: CustomColors.lavenderMist, toolbarHeight: 40),
  snackBarTheme: const SnackBarThemeData(
      backgroundColor: CustomColors.forestGreen,
      contentTextStyle:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  dividerColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: CustomColors.forestGreen)),
);
