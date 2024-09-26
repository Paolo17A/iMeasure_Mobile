import 'package:flutter/material.dart';
import 'package:imeasure_mobile/utils/color_util.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

Widget submitButton(BuildContext context,
    {required String label, required Function onPress}) {
  return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          onPressed: () => onPress(), child: quicksandWhiteRegular(label)));
}

Widget roundedLavenderMistButton(
    {required Function onPress, required Widget child}) {
  return ElevatedButton(
      onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
          backgroundColor: CustomColors.lavenderMist,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
      child: child);
}
