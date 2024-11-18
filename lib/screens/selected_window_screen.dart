import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/screens/unity_screen.dart';
import 'package:imeasure_mobile/utils/color_util.dart';

import '../models/glass_model.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/quotation_dialog_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/dropdown_widget.dart';
import '../widgets/text_widgets.dart';

class SelectedWindowScreen extends ConsumerStatefulWidget {
  final String windowID;
  const SelectedWindowScreen({super.key, required this.windowID});

  @override
  ConsumerState<SelectedWindowScreen> createState() =>
      _SelectedWindowScreenState();
}

class _SelectedWindowScreenState extends ConsumerState<SelectedWindowScreen> {
  //  PRODUCT VARIABLES
  String name = '';
  String description = '';
  bool isAvailable = false;
  num minWidth = 0;
  num maxWidth = 0;
  num minHeight = 0;
  num maxHeight = 0;
  List<dynamic> imageURLs = [];
  String correspondingModel = '';
  List<DocumentSnapshot> orderDocs = [];

  //  USER VARIABLES
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  List<dynamic> mandatoryWindowFields = [];
  List<Map<dynamic, dynamic>> optionalWindowFields = [];
  List<dynamic> accesoryFields = [];
  num totalMandatoryPayment = 0;
  num totalGlassPrice = 0;
  num totalOverallPayment = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        //  GET PRODUCT DATA
        final item = await getThisItemDoc(widget.windowID);
        final itemData = item.data() as Map<dynamic, dynamic>;
        name = itemData[ItemFields.name];
        description = itemData[ItemFields.description];
        isAvailable = itemData[ItemFields.isAvailable];
        imageURLs = itemData[ItemFields.imageURLs];
        minHeight = itemData[ItemFields.minHeight];
        maxHeight = itemData[ItemFields.maxHeight];
        minWidth = itemData[ItemFields.minWidth];
        maxWidth = itemData[ItemFields.maxWidth];
        accesoryFields = itemData[ItemFields.accessoryFields];
        correspondingModel = itemData[ItemFields.correspondingModel];
        //  GET USER DATA
        ref.read(cartProvider).setCartItems(await getCartEntries(context));
        List<dynamic> windowFields = itemData[ItemFields.windowFields];

        mandatoryWindowFields = windowFields
            .where((windowField) => windowField[WindowSubfields.isMandatory])
            .toList();
        List<dynamic> _optionalWindowFields = windowFields
            .where((windowField) => !windowField[WindowSubfields.isMandatory])
            .toList();
        for (var optionalFields in _optionalWindowFields) {
          optionalWindowFields.add({
            OptionalWindowFields.isSelected: false,
            OptionalWindowFields.optionalFields: optionalFields,
            OptionalWindowFields.price: 0
          });
        }
        orderDocs = await getAllItemOrderDocs(widget.windowID);
        orderDocs = orderDocs.where((orderDoc) {
          final orderData = orderDoc.data() as Map<dynamic, dynamic>;
          Map review = orderData[OrderFields.review];
          return review.isNotEmpty;
        }).toList();
        ref.read(cartProvider).setGlassType('');
        ref.read(cartProvider).setSelectedColor('');
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting selected product: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  bool mayProceedToInitialQuotationScreen() {
    return ref.read(cartProvider).selectedGlassType.isNotEmpty &&
        ref.read(cartProvider).selectedColor.isNotEmpty &&
        widthController.text.isNotEmpty &&
        double.tryParse(widthController.text) != null &&
        double.parse(widthController.text.trim()) >= minWidth &&
        double.parse(widthController.text.trim()) <= maxWidth &&
        heightController.text.isNotEmpty &&
        double.tryParse(heightController.text) != null &&
        double.parse(heightController.text.trim()) >= minHeight &&
        double.parse(heightController.text.trim()) <= maxHeight;
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
            ref.read(loadingProvider).isLoading, _windowsContainer()),
      ),
    );
  }

  Widget _windowsContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (imageURLs.isNotEmpty) _itemImagesDisplay(),
          _nameAnd3D(),
          _descriptionAndSize(),
          _actionButtons(),
          quicksandBlackBold('Is Available: ${isAvailable ? 'YES' : 'NO'}',
              fontSize: 16),
          Divider(),
          _itemFieldInputs(),
          if (orderDocs.isNotEmpty) userReviews(orderDocs)
        ],
      ),
    );
  }

  Widget _itemImagesDisplay() {
    List<dynamic> otherImages = [];
    if (imageURLs.length > 1) otherImages = imageURLs.sublist(1);
    return vertical20Pix(
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
          Row(
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
                            height: MediaQuery.of(context).size.width * 0.23,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(otherImage))),
                          ),
                        ),
                      ))
                  .toList())
        ],
      ),
    );
  }

  Widget _nameAnd3D() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
          mainAxisAlignment: correspondingModel.isNotEmpty
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                flex: 2,
                child: all10Pix(
                    child: quicksandBlackBold(name,
                        fontSize: 28, textAlign: TextAlign.left))),
            if (correspondingModel.isNotEmpty)
              Flexible(
                  child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  quicksandEmeraldGreenBold('3D', fontSize: 28),
                  IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  UnityScreen(itemID: widget.windowID))),
                      icon: Icon(Icons.visibility_outlined))
                ],
              ))
          ]),
    );
  }

  Widget _descriptionAndSize() {
    return all10Pix(
        child: Column(
      children: [
        GestureDetector(
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
          child: vertical10Pix(
              child: montserratBlackRegular(description,
                  textAlign: TextAlign.left,
                  fontSize: 18,
                  maxLines: 6,
                  textOverflow: TextOverflow.ellipsis)),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          quicksandDeepCharcoalBold('Minimum Width: ${minWidth.toString()}ft',
              fontSize: 12),
          quicksandDeepCharcoalBold('Minimum Height: ${minHeight.toString()}ft',
              fontSize: 12),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            quicksandDeepCharcoalBold('Maximum Width: ${maxWidth.toString()}ft',
                fontSize: 12),
            quicksandDeepCharcoalBold(
                'Maximum Height: ${maxHeight.toString()}ft',
                fontSize: 12)
          ],
        ),
      ],
    ));
  }

  Widget _actionButtons() {
    return all20Pix(
      child: Row(children: [
        SizedBox(
          height: 60,
          child: ElevatedButton(
              onPressed: () {
                if (mayProceedToInitialQuotationScreen()) {
                  showQuotationDialog(context, ref,
                      width: double.parse(widthController.text),
                      height: double.parse(heightController.text),
                      mandatoryWindowFields: mandatoryWindowFields,
                      optionalWindowFields: optionalWindowFields,
                      accessoryFields: accesoryFields,
                      itemType: ItemTypes.window,
                      imageURLs: imageURLs,
                      hasGlass: true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Please fill up all the required fields first.')));
                }
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(),
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: CustomColors.deepCharcoal),
              child: quicksandWhiteBold('View\nEstimate',
                  fontSize: 16, textAlign: TextAlign.center)),
        ),
        Gap(8),
        SizedBox(
          height: 60,
          child: ElevatedButton(
              onPressed: isAvailable
                  ? () {
                      if (mayProceedToInitialQuotationScreen()) {
                        addFurnitureItemToCart(context, ref,
                            itemID: widget.windowID,
                            itemType: ItemTypes.window,
                            width: double.parse(widthController.text),
                            height: double.parse(heightController.text),
                            mandatoryWindowFields: mandatoryWindowFields,
                            optionalWindowFields: pricedOptionalWindowFields(
                                ref,
                                width: double.parse(widthController.text),
                                height: double.parse(heightController.text),
                                oldOptionalWindowFields: optionalWindowFields));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Please fill up all the required fields first.')));
                      }
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
      ]),
    );
  }

  Widget _itemFieldInputs() {
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //  INPUT FIELDS
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: CustomTextField(
                  text: 'Insert Height',
                  controller: heightController,
                  displayPrefixIcon: null,
                  borderRadius: 4,
                  textInputType: TextInputType.number)),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: dropdownWidget(ref.read(cartProvider).selectedGlassType,
                (newVal) {
              ref.read(cartProvider).setGlassType(newVal!);
            },
                allGlassModels
                    .map((glassModel) => glassModel.glassTypeName)
                    .toList(),
                'Select your glass type',
                false),
          ),
        ]),
        Gap(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: CustomTextField(
                    text: 'Insert Width',
                    controller: widthController,
                    displayPrefixIcon: null,
                    borderRadius: 4,
                    textInputType: TextInputType.number)),
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: dropdownWidget(ref.read(cartProvider).selectedColor,
                  (newVal) {
                ref.read(cartProvider).setSelectedColor(newVal!);
              }, [
                WindowColors.brown,
                WindowColors.white,
                WindowColors.mattBlack,
                WindowColors.mattGray,
                WindowColors.woodFinish
              ], 'Select window color', false),
            )
          ],
        ),
        if (optionalWindowFields.isNotEmpty) _optionalWindowFields(),
        Gap(20)
      ],
    );
  }

  Widget _optionalWindowFields() {
    return all20Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          quicksandBlackBold('Optional Window Fields', fontSize: 16),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: optionalWindowFields.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Checkbox(
                        value: optionalWindowFields[index]
                            [OptionalWindowFields.isSelected],
                        onChanged: (newVal) {
                          setState(() {
                            optionalWindowFields[index]
                                [OptionalWindowFields.isSelected] = newVal;
                          });
                        }),
                    quicksandBlackRegular(
                        optionalWindowFields[index]
                                [OptionalWindowFields.optionalFields]
                            [WindowSubfields.name],
                        fontSize: 14),
                  ],
                );
              }),
        ],
      ),
    );
  }
}
