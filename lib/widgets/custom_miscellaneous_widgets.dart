import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../utils/color_util.dart';
import '../utils/string_util.dart';
import 'custom_padding_widgets.dart';
import 'text_widgets.dart';

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, Widget child) {
  return Stack(children: [
    child,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Widget buildProfileImage(
    {required String profileImageURL, double radius = 70}) {
  return profileImageURL.isNotEmpty
      ? CircleAvatar(
          radius: radius,
          backgroundColor: CustomColors.lavenderMist,
          backgroundImage: NetworkImage(profileImageURL),
        )
      : CircleAvatar(
          radius: radius,
          backgroundColor: CustomColors.lavenderMist,
          child: Icon(
            Icons.person,
            color: CustomColors.forestGreen,
            size: radius + 10,
          ));
}

Widget roundedWhiteContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      padding: const EdgeInsets.all(20),
      child: child);
}

Widget roundedSkyBlueContainer(BuildContext context, {required Widget child}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CustomColors.deepSkyBlue),
      padding: const EdgeInsets.all(20),
      child: child);
}

void showOtherPics(BuildContext context, {required String selectedImage}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
              content: SingleChildScrollView(
            child: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(selectedImage), fit: BoxFit.fill)),
              ),
              vertical10Pix(
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: montserratWhiteRegular('CLOSE')),
              )
            ]),
          )));
}

Widget snapshotHandler(AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const CircularProgressIndicator();
  } else if (!snapshot.hasData) {
    return Text('No data found');
  } else if (snapshot.hasError) {
    return Text('Error gettin data: ${snapshot.error.toString()}');
  }
  return Container();
}

Widget mandatoryWindowSubfield(WidgetRef ref,
    {required Map<dynamic, dynamic> windowSubField,
    required double height,
    required double width}) {
  num price = 0;
  if (windowSubField[WindowSubfields.priceBasis] == 'HEIGHT') {
    switch (ref.read(cartProvider).selectedColor) {
      case WindowColors.brown:
        price = (windowSubField[WindowSubfields.brownPrice] / 21) * height;
        break;
      case WindowColors.white:
        price = (windowSubField[WindowSubfields.whitePrice] / 21) * height;
        break;
      case WindowColors.mattBlack:
        price = (windowSubField[WindowSubfields.mattBlackPrice] / 21) * height;
        break;
      case WindowColors.mattGray:
        price = (windowSubField[WindowSubfields.mattGrayPrice] / 21) * height;
        break;
      case WindowColors.woodFinish:
        price = (windowSubField[WindowSubfields.woodFinishPrice] / 21) * height;
        break;
    }
  } else if (windowSubField[WindowSubfields.priceBasis] == 'WIDTH') {
    switch (ref.read(cartProvider).selectedColor) {
      case WindowColors.brown:
        price = (windowSubField[WindowSubfields.brownPrice] / 21) * width;
        break;
      case WindowColors.white:
        price = (windowSubField[WindowSubfields.whitePrice] / 21) * width;
        break;
      case WindowColors.mattBlack:
        price = (windowSubField[WindowSubfields.mattBlackPrice] / 21) * width;
        break;
      case WindowColors.mattGray:
        price = (windowSubField[WindowSubfields.mattGrayPrice] / 21) * width;
        break;
      case WindowColors.woodFinish:
        price = (windowSubField[WindowSubfields.woodFinishPrice] / 21) * width;
        break;
    }
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      quicksandBlackRegular('${windowSubField[WindowSubfields.name]}: ',
          fontSize: 14),
      quicksandBlackRegular(' PHP ${formatPrice(price.toDouble())}',
          fontSize: 14),
    ],
  );
}
