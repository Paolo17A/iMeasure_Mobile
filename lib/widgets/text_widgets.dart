import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imeasure_mobile/utils/color_util.dart';

Text montserratWhiteBold(String label,
    {double fontSize = 20,
    TextAlign textAlign = TextAlign.center,
    TextOverflow? textOverflow}) {
  return Text(
    label,
    textAlign: textAlign,
    overflow: textOverflow,
    style: GoogleFonts.montserrat(
        fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
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
    style: GoogleFonts.montserrat(fontSize: fontSize, color: Colors.black),
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
    style: GoogleFonts.montserrat(fontSize: fontSize, color: Colors.white),
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
    style: GoogleFonts.montserrat(
        fontSize: fontSize,
        color: Colors.black,
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
    style: GoogleFonts.montserrat(
        fontSize: fontSize,
        color: CustomColors.midnightBlue,
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
    style: GoogleFonts.montserrat(
        fontSize: fontSize, color: CustomColors.midnightBlue),
  );
}
