import 'package:flutter/material.dart';

import 'color_util.dart';

ThemeData themeData = ThemeData(
  colorSchemeSeed: CustomColors.emeraldGreen,
  scaffoldBackgroundColor: CustomColors.lavenderMist,
  appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: CustomColors.deepCharcoal,
      toolbarHeight: 40),
  snackBarTheme: const SnackBarThemeData(
      backgroundColor: CustomColors.deepCharcoal,
      contentTextStyle:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  dividerColor: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: CustomColors.deepCharcoal)),
);
