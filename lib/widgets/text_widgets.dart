import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imeasure_mobile/utils/color_util.dart';

Text quicksandWhiteBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        decoration: textDecoration,
        decorationColor: Colors.white,
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold),
  );
}

Text quicksandWhiteRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow,
    TextDecoration? decoration}) {
  return Text(label,
      textAlign: textAlign,
      style: GoogleFonts.quicksand(
          fontSize: fontSize,
          color: Colors.white,
          decoration: decoration,
          decorationColor: Colors.white,
          textStyle: TextStyle(overflow: textOverflow)));
}

Text montserratBlackRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(fontSize: fontSize, color: Colors.black),
  );
}

Text quicksandBlackRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.quicksand(
        fontSize: fontSize,
        color: Colors.black,
        textStyle: TextStyle(overflow: textOverflow)),
  );
}

Text montserratWhiteBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.white),
  );
}

Text montserratWhiteRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(fontSize: fontSize, color: Colors.white),
  );
}

Text quicksandRedBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize, color: Colors.red, fontWeight: FontWeight.bold),
  );
}

Text quicksandBlackBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize,
        color: Colors.black,
        fontWeight: FontWeight.bold,
        decoration: textDecoration),
  );
}

Text quicksandEmeraldGreenBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize,
        color: CustomColors.emeraldGreen,
        fontWeight: FontWeight.bold,
        decoration: textDecoration),
  );
}

Text quicksandDeepCharcoalBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize,
        color: CustomColors.deepCharcoal,
        decoration: textDecoration,
        fontWeight: FontWeight.bold),
  );
}

Text quicksandDeepCharcoalRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize, color: CustomColors.deepCharcoal),
  );
}

Text itcBaumansDeepCharcoalBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.baumans(
        fontSize: fontSize,
        color: CustomColors.deepCharcoal,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
        textStyle: TextStyle(overflow: textOverflow)),
  );
}

Text itcBaumansWhiteBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.baumans(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
        textStyle: TextStyle(overflow: textOverflow)),
  );
}

Text itcBaumansDeepSkyBlueBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.baumans(
        fontSize: fontSize,
        color: CustomColors.deepSkyBlue,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
        textStyle: TextStyle(overflow: textOverflow)),
  );
}
