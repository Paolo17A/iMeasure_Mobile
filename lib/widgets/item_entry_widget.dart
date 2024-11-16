import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Widget itemEntry(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot productDoc,
    required Function onPress,
    Color fontColor = Colors.black}) {
  final productData = productDoc.data() as Map<dynamic, dynamic>;
  List<dynamic> imageURLs = productData[ItemFields.imageURLs];
  String itemName = productData[ItemFields.name];
  String itemType = productData[ItemFields.itemType];
  return GestureDetector(
    onTap: () => onPress(),
    child: Container(
      width: 150,
      //decoration: BoxDecoration(color: CustomColors.deepNavyBlue),
      child: Column(
        children: [
          GestureDetector(
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                      content: square80PercentNetworkImage(
                          context, imageURLs.first))),
              child: _productImage(imageURLs.first)),
          Container(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: quicksandBlackBold(itemName,
                  textOverflow: TextOverflow.ellipsis, fontSize: 16),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //if (itemType == ItemTypes.window || itemType == ItemTypes.door)
              ElevatedButton(
                  onPressed: () {
                    if (itemType == ItemTypes.window) {
                      NavigatorRoutes.selectedWindow(context, ref,
                          windowID: productDoc.id);
                    } else if (itemType == ItemTypes.door) {
                      NavigatorRoutes.selectedDoor(context, ref,
                          doorID: productDoc.id);
                    } else if (itemType == ItemTypes.rawMaterial) {
                      NavigatorRoutes.selectedRawMaterial(context, ref,
                          rawMaterialID: productDoc.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Icon(Icons.visibility_outlined, size: 20))
              // else
              //   Container(
              //     width: MediaQuery.of(context).size.width * 0.17,
              //     height: 40,
              //     padding: EdgeInsets.all(4),
              //     decoration: BoxDecoration(
              //         color: CustomColors.deepCharcoal,
              //         borderRadius: BorderRadius.circular(12)),
              //     child: Center(
              //       child: quicksandWhiteBold(
              //           'PHP ${formatPrice(productDoc[ItemFields.price].toDouble())}',
              //           fontSize: 10),
              //     ),
              //   ),
              // Gap(4),
              // if (itemType == ItemTypes.rawMaterial)
              //   ElevatedButton(
              //       onPressed: () => addRawMaterialToCart(context, ref,
              //           itemID: productDoc.id),
              //       style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.white,
              //           shape: RoundedRectangleBorder(
              //               side: BorderSide(),
              //               borderRadius: BorderRadius.circular(10))),
              //       child: Icon(Icons.shopping_cart, color: Colors.black))
            ],
          )
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
                Border.all(color: CustomColors.deepCharcoal.withOpacity(0.5)),
            image: DecorationImage(
                fit: BoxFit.fill, image: NetworkImage(firstImage))),
      ));
}
