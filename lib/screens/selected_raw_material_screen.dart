import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/text_widgets.dart';

class SelectedRawMaterialScreen extends ConsumerStatefulWidget {
  final String rawMaterialID;
  const SelectedRawMaterialScreen({super.key, required this.rawMaterialID});

  @override
  ConsumerState<SelectedRawMaterialScreen> createState() =>
      _SelectedRawMaterialScreenState();
}

class _SelectedRawMaterialScreenState
    extends ConsumerState<SelectedRawMaterialScreen> {
  //  PRODUCT VARIABLES
  String name = '';
  String description = '';
  bool isAvailable = false;
  num price = 0;
  List<dynamic> imageURLs = [];
  List<DocumentSnapshot> orderDocs = [];
  bool requestingService = false;
  final addressController = TextEditingController();
  final contactNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        //  GET PRODUCT DATA
        final item = await getThisItemDoc(widget.rawMaterialID);
        final itemData = item.data() as Map<dynamic, dynamic>;
        name = itemData[ItemFields.name];
        description = itemData[ItemFields.description];
        isAvailable = itemData[ItemFields.isAvailable];
        imageURLs = itemData[ItemFields.imageURLs];
        price = itemData[ItemFields.price];
        //  GET USER DATA
        ref.read(cartProvider).setCartItems(await getCartEntries(context));

        orderDocs = await getAllItemOrderDocs(widget.rawMaterialID);
        orderDocs = orderDocs.where((orderDoc) {
          final orderData = orderDoc.data() as Map<dynamic, dynamic>;
          Map review = orderData[OrderFields.review];
          return review.isNotEmpty;
        }).toList();
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting selected product: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(),
        bottomNavigationBar: bottomNavigationBar(context, ref, index: 1),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading, _rawMaterialsContainer()),
      ),
    );
  }

  Widget _rawMaterialsContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (imageURLs.isNotEmpty) _itemImagesDisplay(),
          _nameAnd3D(),
          quicksandBlackBold('PHP ${formatPrice(price.toDouble())}'),
          _description(),
          _availInstallation(),
          _actionButtons(),
          quicksandBlackBold('Is Available: ${isAvailable ? 'YES' : 'NO'}',
              fontSize: 16),
          Divider(),
          if (orderDocs.isNotEmpty) userReviews(orderDocs)
        ],
      ),
    );
  }

  Widget _itemImagesDisplay() {
    List<dynamic> otherImages = [];
    if (imageURLs.length > 1) otherImages = imageURLs.sublist(1);
    return vertical10Pix(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                    content:
                        square80PercentNetworkImage(context, imageURLs.first))),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      fit: BoxFit.fill, image: NetworkImage(imageURLs.first))),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: otherImages
                      .map((otherImage) => all4Pix(
                            child: GestureDetector(
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                      content: square80PercentNetworkImage(
                                          context, otherImage))),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.23,
                                height:
                                    MediaQuery.of(context).size.width * 0.23,
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(otherImage))),
                              ),
                            ),
                          ))
                      .toList()),
            ),
          )
        ],
      ),
    );
  }

  Widget _nameAnd3D() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: all10Pix(
          child: quicksandBlackBold(name,
              fontSize: 28, textAlign: TextAlign.left)),
    );
  }

  Widget _description() {
    return GestureDetector(
      onTap: description.length > 300
          ? () {
              showDialog(
                  context: context,
                  builder: (_) => Dialog(
                        child: SingleChildScrollView(
                          child: all20Pix(
                              child: montserratBlackRegular(description,
                                  textAlign: TextAlign.left, fontSize: 18)),
                        ),
                      ));
            }
          : null,
      child: all10Pix(
          child: montserratBlackRegular(description,
              textAlign: TextAlign.left,
              fontSize: 18,
              maxLines: 6,
              textOverflow: TextOverflow.ellipsis)),
    );
  }

  Widget _availInstallation() {
    return vertical20Pix(
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                  value: requestingService,
                  onChanged: (newVal) {
                    setState(() {
                      requestingService = newVal!;
                    });
                  }),
              quicksandBlackBold('AVAIL INSTALLATION SERVICE', fontSize: 20)
            ],
          ),
          if (requestingService)
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  quicksandBlackBold('Installation Address'),
                  CustomTextField(
                      text: 'Installation Address',
                      controller: addressController,
                      displayPrefixIcon: null,
                      borderRadius: 4,
                      textInputType: TextInputType.streetAddress),
                  Gap(20),
                  quicksandBlackBold('Mobile Number'),
                  CustomTextField(
                      text: 'Contact Number',
                      controller: contactNumberController,
                      displayPrefixIcon: null,
                      borderRadius: 4,
                      textInputType: TextInputType.phone),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return all20Pix(
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
            onPressed: isAvailable
                ? () {
                    addRawMaterialToCart(context, ref,
                        itemID: widget.rawMaterialID,
                        requestingService: requestingService,
                        addressController: addressController,
                        itemOverallPrice: price,
                        contactNumberController: contactNumberController);
                  }
                : null,
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    side: BorderSide(),
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.blueGrey),
            child: quicksandBlackRegular('+ ADD TO CART',
                textAlign: TextAlign.center)),
      ),
    );
  }
}
