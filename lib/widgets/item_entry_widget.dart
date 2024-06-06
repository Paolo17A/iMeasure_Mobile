import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import '../utils/color_util.dart';
import 'text_widgets.dart';

Widget itemEntry(BuildContext context,
    {required DocumentSnapshot productDoc,
    required Function onPress,
    Color fontColor = Colors.black}) {
  final productData = productDoc.data() as Map<dynamic, dynamic>;
  String imageURL = productData[WindowFields.imageURL];
  String itemName = productData[WindowFields.name];
  return GestureDetector(
    onTap: () => onPress(),
    child: Container(
      width: 150,
      //decoration: BoxDecoration(color: CustomColors.deepNavyBlue),
      child: Column(
        children: [
          _productImage(imageURL),
          Container(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: montserratBlackBold(itemName,
                  textOverflow: TextOverflow.ellipsis, fontSize: 16),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _productImage(String firstImage) {
  return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            border:
                Border.all(color: CustomColors.deepNavyBlue.withOpacity(0.5)),
            image: DecorationImage(
                fit: BoxFit.fill, image: NetworkImage(firstImage))),
      ));
}
