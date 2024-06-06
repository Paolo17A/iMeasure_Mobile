import 'package:flutter/material.dart';

import 'color_util.dart';

ThemeData themeData = ThemeData(
  colorSchemeSeed: CustomColors.deepNavyBlue,
  scaffoldBackgroundColor: CustomColors.lavenderMist,
  appBarTheme: const AppBarTheme(
      backgroundColor: CustomColors.lavenderMist, toolbarHeight: 40),
  snackBarTheme: const SnackBarThemeData(
      backgroundColor: CustomColors.aquaMarine,
      contentTextStyle:
          TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: CustomColors.emeraldGreen)),
);
