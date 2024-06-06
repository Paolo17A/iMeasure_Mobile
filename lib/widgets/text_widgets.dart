import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imeasure_mobile/utils/color_util.dart';

Text montserratWhiteBold(String label,
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

Text montserratBlackBold(String label,
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

Text montserratMidnightBlueBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize,
        color: CustomColors.deepNavyBlue,
        fontWeight: FontWeight.bold),
  );
}

Text montserratMidnightBlueRegular(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.quicksand(
        fontSize: fontSize, color: CustomColors.deepNavyBlue),
  );
}

Text itcBaumansDeepNavyBlueBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.baumans(
        fontSize: fontSize,
        color: CustomColors.deepNavyBlue,
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

Text itcBaumansAzureBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    style: GoogleFonts.baumans(
        fontSize: fontSize,
        color: CustomColors.azure,
        fontWeight: FontWeight.bold,
        decoration: textDecoration,
        textStyle: TextStyle(overflow: textOverflow)),
  );
}
