import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/widgets/custom_text_field_widget.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
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
  } else if (windowSubField[WindowSubfields.priceBasis] == 'PERIMETER') {
    num perimeter = (2 * width) + (2 * height);
    switch (ref.read(cartProvider).selectedColor) {
      case WindowColors.brown:
        price = (windowSubField[WindowSubfields.brownPrice] / 21) * perimeter;
        break;
      case WindowColors.white:
        price = (windowSubField[WindowSubfields.whitePrice] / 21) * perimeter;
        break;
      case WindowColors.mattBlack:
        price =
            (windowSubField[WindowSubfields.mattBlackPrice] / 21) * perimeter;
        break;
      case WindowColors.mattGray:
        price =
            (windowSubField[WindowSubfields.mattGrayPrice] / 21) * perimeter;
        break;
      case WindowColors.woodFinish:
        price =
            (windowSubField[WindowSubfields.woodFinishPrice] / 21) * perimeter;
        break;
    }
  } else if (windowSubField[WindowSubfields.priceBasis] ==
      'PERIMETER DOUBLED') {
    num perimeter = (4 * width) + (2 * height);
    switch (ref.read(cartProvider).selectedColor) {
      case WindowColors.brown:
        price = (windowSubField[WindowSubfields.brownPrice] / 21) * perimeter;
        break;
      case WindowColors.white:
        price = (windowSubField[WindowSubfields.whitePrice] / 21) * perimeter;
        break;
      case WindowColors.mattBlack:
        price =
            (windowSubField[WindowSubfields.mattBlackPrice] / 21) * perimeter;
        break;
      case WindowColors.mattGray:
        price =
            (windowSubField[WindowSubfields.mattGrayPrice] / 21) * perimeter;
        break;
      case WindowColors.woodFinish:
        price =
            (windowSubField[WindowSubfields.woodFinishPrice] / 21) * perimeter;
        break;
    }
  } else if (windowSubField[WindowSubfields.priceBasis] == 'STACKED WIDTH') {
    num stackedValue = (2 * height) + (6 * width);
    switch (ref.read(cartProvider).selectedColor) {
      case WindowColors.brown:
        price =
            (windowSubField[WindowSubfields.brownPrice] / 21) * stackedValue;
        break;
      case WindowColors.white:
        price =
            (windowSubField[WindowSubfields.whitePrice] / 21) * stackedValue;
        break;
      case WindowColors.mattBlack:
        price = (windowSubField[WindowSubfields.mattBlackPrice] / 21) *
            stackedValue;
        break;
      case WindowColors.mattGray:
        price =
            (windowSubField[WindowSubfields.mattGrayPrice] / 21) * stackedValue;
        break;
      case WindowColors.woodFinish:
        price = (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
            stackedValue;
        break;
    }
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(
        child: quicksandBlackRegular(
            '${windowSubField[WindowSubfields.name]}: ',
            textAlign: TextAlign.left,
            fontSize: 14),
      ),
      Flexible(
        child: quicksandBlackRegular(' PHP ${formatPrice(price.toDouble())}',
            textAlign: TextAlign.left, fontSize: 14),
      ),
    ],
  );
}

Widget square100NetworkImage(String url) {
  return Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
  );
}

Widget square150NetworkImage(String url) {
  return Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(10),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
  );
}

Widget square300NetworkImage(String url) {
  return Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
        border: Border.all(),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
  );
}

Widget square80PercentNetworkImage(BuildContext context, String url) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.width * 0.8,
    decoration: BoxDecoration(
        border: Border.all(),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)),
  );
}

Widget bookmarksContainer(WidgetRef ref) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      quicksandBlackBold('BOOKMARKS', fontSize: 30),
      if (ref.read(bookmarksProvider).bookmarkedProducts.isNotEmpty)
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ref.read(bookmarksProvider).bookmarkedProducts.length,
            itemBuilder: (context, index) {
              return _bookmarkedProductEntry(
                  ref, ref.read(bookmarksProvider).bookmarkedProducts[index]);
            })
      else
        vertical20Pix(
            child: quicksandBlackBold('YOU HAVE NO\nBOOKMARKED ITEMS',
                fontSize: 16))
    ],
  );
}

Widget _bookmarkedProductEntry(WidgetRef ref, String windowID) {
  return FutureBuilder(
      future: getThisItemDoc(windowID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);
        final windowData = snapshot.data!.data() as Map<dynamic, dynamic>;
        String name = windowData[WindowFields.name];
        String imageURL = windowData[WindowFields.imageURL];
        num minHeight = windowData[WindowFields.minHeight];
        num maxHeight = windowData[WindowFields.maxHeight];
        num minWidth = windowData[WindowFields.minWidth];
        num maxWidth = windowData[WindowFields.maxWidth];
        return GestureDetector(
          onTap: () =>
              NavigatorRoutes.selectedWindow(context, ref, windowID: windowID),
          child: all10Pix(
              child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
                color: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.delete, color: Colors.white)])),
            dismissThresholds: {DismissDirection.endToStart: 0.2},
            confirmDismiss: (direction) async {
              displayDeleteEntryDialog(context,
                  message:
                      'Are you sure you wish to remove this product from your bookmarks?',
                  deleteEntry: () => removeBookmarkedProduct(context, ref,
                      productID: windowID));
              return false;
            },
            child: Container(
                decoration: BoxDecoration(
                    color: CustomColors.lavenderMist, border: Border.all()),
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                            backgroundImage: NetworkImage(imageURL),
                            backgroundColor: Colors.transparent,
                            radius: 30),
                        Gap(20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            quicksandBlackBold(name,
                                textOverflow: TextOverflow.ellipsis,
                                fontSize: 16),
                            montserratBlackRegular(
                                'Width: ${minWidth.toString()} - ${maxWidth.toString()}ft',
                                fontSize: 12),
                            montserratBlackRegular(
                                'Height: ${minHeight.toString()} - ${maxHeight.toString()}ft',
                                fontSize: 12)
                          ],
                        )
                      ],
                    ),
                  ],
                )),
          )),
        );
      });
}

StreamBuilder pendingCheckOutStreamBuilder() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(Collections.cart)
        .where(CartFields.clientID,
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData ||
          snapshot.hasError) return Container();
      List<DocumentSnapshot> filteredCartItems = snapshot.data!.docs;
      filteredCartItems = filteredCartItems.where((cart) {
        final cartData = cart.data() as Map<dynamic, dynamic>;
        String itemType = cartData[CartFields.itemType];
        Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
        String requestStatus = quotation[QuotationFields.requestStatus];
        bool isRequestingAdditionalService =
            quotation[QuotationFields.isRequestingAdditionalService];
        bool isFurniture =
            (itemType == ItemTypes.window || itemType == ItemTypes.door);
        return (isFurniture &&
                (requestStatus == RequestStatuses.approved ||
                    requestStatus == RequestStatuses.denied)) ||
            (!isFurniture && !isRequestingAdditionalService) ||
            (!isFurniture &&
                isRequestingAdditionalService &&
                (requestStatus == RequestStatuses.approved ||
                    requestStatus == RequestStatuses.denied));
      }).toList();
      //int availableCollectionCount = snapshot.data!.docs.length;

      if (filteredCartItems.length > 0)
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: CustomColors.coralRed),
          child: Center(
            child: quicksandWhiteRegular(filteredCartItems.length.toString(),
                fontSize: 12),
          ),
        );
      else {
        return Container();
      }
    },
  );
}

StreamBuilder pendingPickUpOrdersStreamBuilder() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(Collections.orders)
        .where(OrderFields.clientID,
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData ||
          snapshot.hasError) return Container();
      List<DocumentSnapshot> filteredOrders = snapshot.data!.docs;
      filteredOrders = filteredOrders.where((order) {
        final orderData = order.data() as Map<dynamic, dynamic>;
        String orderStatus = orderData[OrderFields.orderStatus];
        Map<dynamic, dynamic> review = orderData[OrderFields.review];
        return (orderStatus == OrderStatuses.forPickUp) ||
            (orderStatus == OrderStatuses.completed && review.isEmpty);
      }).toList();

      if (filteredOrders.length > 0)
        return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: CustomColors.coralRed),
            child: Center(
                child: quicksandWhiteRegular(filteredOrders.length.toString(),
                    fontSize: 12)));
      else {
        return Container();
      }
    },
  );
}

StreamBuilder approvedAppointmentsStreamBuilder() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection(Collections.appointments)
        .where(AppointmentFields.clientID,
            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting ||
          !snapshot.hasData ||
          snapshot.hasError) return Container();
      List<DocumentSnapshot> filteredAppointments = snapshot.data!.docs;

      filteredAppointments = filteredAppointments.where((appointment) {
        final appointmentData = appointment.data() as Map<dynamic, dynamic>;
        String appointmentStatus =
            appointmentData[AppointmentFields.appointmentStatus];
        return appointmentStatus == AppointmentStatuses.approved;
      }).toList();

      if (filteredAppointments.length > 0)
        return Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: CustomColors.coralRed),
            child: Center(
                child: quicksandWhiteRegular(
                    filteredAppointments.length.toString(),
                    fontSize: 12)));
      else {
        return Container();
      }
    },
  );
}

Widget starRating(double rating,
    {required Function(double) onUpdate,
    double starSize = 20,
    bool mayMove = true}) {
  return RatingBar(
      minRating: 1,
      maxRating: 5,
      itemCount: 5,
      initialRating: rating,
      updateOnDrag: mayMove,
      allowHalfRating: false,
      ignoreGestures: !mayMove,
      itemSize: starSize,
      ratingWidget: RatingWidget(
          full:
              const Icon(Icons.star, color: Color.fromARGB(255, 236, 217, 49)),
          half:
              const Icon(Icons.star, color: Color.fromARGB(255, 236, 217, 49)),
          empty: const Icon(Icons.star, color: Colors.grey)),
      onRatingUpdate: (val) => onUpdate(val));
}

Widget userReviews(List<DocumentSnapshot> orderDocs) {
  return vertical20Pix(
    child: Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        quicksandBlackBold('REVIEWS'),
        vertical10Pix(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: orderDocs.length,
              itemBuilder: (context, index) {
                final orderData = orderDocs[index];
                String clientID = orderData[OrderFields.clientID];
                Map<String, dynamic> review =
                    orderData[OrderFields.review] ?? {};
                num rating = review[ReviewFields.rating] ?? 0;
                List<dynamic> imageURLs = review[ReviewFields.imageURLs] ?? [];
                String reviewText = review[ReviewFields.review] ?? '';
                return all4Pix(
                  child: Container(
                      //height: 100,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder(
                                          future: getThisUserDoc(clientID),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.waiting ||
                                                !snapshot.hasData ||
                                                snapshot.hasError)
                                              return Container();
                                            final userData =
                                                snapshot.data!.data()
                                                    as Map<dynamic, dynamic>;
                                            String formattedName =
                                                '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';

                                            return quicksandBlackRegular(
                                                formattedName);
                                          }),
                                      starRating(rating.toDouble(),
                                          onUpdate: (val) {}, mayMove: false),
                                      quicksandBlackRegular(reviewText,
                                          fontSize: 16),
                                    ]),
                              ),
                            ],
                          ),
                          if (imageURLs.isNotEmpty)
                            Flexible(
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: imageURLs
                                      .map((imageURL) => all4Pix(
                                            child: Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                    border: Border.all(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            imageURL)))),
                                          ))
                                      .toList()),
                            )
                        ],
                      )),
                );
              }),
        ),
      ],
    ),
  );
}

void showEnlargedPics(BuildContext context, {required String imageURL}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
              content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: quicksandBlackBold('X'))
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.height * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(imageURL), fit: BoxFit.fill)),
              ),
            ]),
          )));
}

Widget addressGroup(BuildContext context,
    {required TextEditingController streetController,
    required TextEditingController barangayController,
    required TextEditingController municipalityController,
    required TextEditingController zipCodeController,
    bool isWhite = false}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWhite
              ? quicksandWhiteBold('Street Number & Name')
              : quicksandBlackBold('Street Number & Name'),
          CustomTextField(
              text: 'Street number & Name',
              displayPrefixIcon: null,
              borderRadius: 4,
              controller: streetController,
              textInputType: TextInputType.text)
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWhite
              ? quicksandWhiteBold('Barangay')
              : quicksandBlackBold('Barangay'),
          CustomTextField(
              text: 'Barangay',
              displayPrefixIcon: null,
              borderRadius: 4,
              controller: barangayController,
              textInputType: TextInputType.text)
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWhite
              ? quicksandWhiteBold('Municipality')
              : quicksandBlackBold('Municipality'),
          CustomTextField(
              text: 'Municipality',
              displayPrefixIcon: null,
              borderRadius: 4,
              controller: municipalityController,
              textInputType: TextInputType.text)
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWhite
              ? quicksandWhiteBold('Zip Code')
              : quicksandBlackBold('Zip Code'),
          CustomTextField(
              text: 'Zip Code',
              displayPrefixIcon: null,
              controller: zipCodeController,
              borderRadius: 4,
              textInputType: TextInputType.number)
        ],
      ),
    ],
  );
}
