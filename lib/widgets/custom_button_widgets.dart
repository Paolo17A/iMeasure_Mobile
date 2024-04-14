import 'package:flutter/material.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

Widget submitButton(BuildContext context,
    {required String label, required Function onPress}) {
  return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          onPressed: () => onPress(),
          child: montserratMidnightBlueBold(label)));
}
