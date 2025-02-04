import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/utils/color_util.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_text_field_widget.dart';

class RateItemScreen extends ConsumerStatefulWidget {
  final String orderID;
  const RateItemScreen({super.key, required this.orderID});

  @override
  ConsumerState<RateItemScreen> createState() => _RateItemScreenState();
}

class _RateItemScreenState extends ConsumerState<RateItemScreen> {
  num quantity = 0;
  num itemOverallPrice = 0;
  DateTime datePickedUp = DateTime.now();
  List<dynamic> imageURLs = [];
  String name = '';
  double initialRating = 0;
  final feedbackController = TextEditingController();
  List<File> selectedImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final order = await getThisOrderDoc(widget.orderID);
        final orderData = order.data() as Map<dynamic, dynamic>;
        String itemID = orderData[OrderFields.itemID];
        quantity = orderData[OrderFields.quantity];
        datePickedUp =
            (orderData[OrderFields.datePickedUp] as Timestamp).toDate();
        Map<dynamic, dynamic> quotation = orderData[OrderFields.quotation];
        itemOverallPrice = quotation[QuotationFields.itemOverallPrice];

        final item = await getThisItemDoc(itemID);
        final itemData = item.data() as Map<dynamic, dynamic>;
        imageURLs = itemData[ItemFields.imageURLs];
        name = itemData[ItemFields.name];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting item details: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(),
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  quicksandDeepCharcoalBold('RATE YOUR ORDER', fontSize: 28),
                  Gap(12),
                  _itemDetails(),
                  _feedbackWidgets(),
                  ElevatedButton(
                      onPressed: () => reviewThisOrder(context, ref,
                          orderID: widget.orderID,
                          rating: initialRating.toInt(),
                          reviewController: feedbackController,
                          reviewImageFiles: selectedImages),
                      child: quicksandWhiteBold('SUBMIT REVIEW'))
                ],
              )),
            )),
      ),
    );
  }

  Widget _itemDetails() {
    return Column(children: [
      Row(children: [
        quicksandDeepCharcoalBold('Item: ', fontSize: 16),
        quicksandDeepCharcoalRegular(name, fontSize: 16)
      ]),
      Row(children: [
        quicksandDeepCharcoalBold('Date Completed: ', fontSize: 16),
        quicksandDeepCharcoalRegular(
            DateFormat('MMM dd, yyyy').format(datePickedUp),
            fontSize: 16)
      ]),
      Row(children: [
        quicksandDeepCharcoalBold('Overall Price: ', fontSize: 16),
        quicksandDeepCharcoalRegular(
            'PHP ${formatPrice(itemOverallPrice.toDouble())}',
            fontSize: 16)
      ]),
      if (imageURLs.isNotEmpty)
        vertical10Pix(
            child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                  fit: BoxFit.cover, image: NetworkImage(imageURLs.first))),
        )),
      Divider(color: CustomColors.deepCharcoal)
    ]);
  }

  Widget _feedbackWidgets() {
    return vertical10Pix(
      child: Column(children: [
        starRating(initialRating, onUpdate: (newVal) {
          setState(() {
            initialRating = newVal;
          });
        }, starSize: 40),
        all20Pix(
          child: CustomTextField(
              text: 'Leave additional feedback (optional)',
              controller: feedbackController,
              textInputType: TextInputType.multiline,
              displayPrefixIcon: null),
        ),
        if (selectedImages.isNotEmpty)
          Row(
              children: selectedImages
                  .map((reviewImage) => all4Pix(
                        child: Column(
                          children: [
                            Image.file(reviewImage,
                                width: 80, height: 80, fit: BoxFit.cover),
                            IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.delete_outline))
                          ],
                        ),
                      ))
                  .toList()),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
                onPressed: () async {
                  ImagePicker imagePicker = ImagePicker();
                  List<XFile> selectedXFiles =
                      await imagePicker.pickMultiImage();
                  if (selectedXFiles.length + selectedImages.length > 3) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('You can only select up to three images.')));
                    return;
                  }
                  setState(() {
                    for (XFile image in selectedXFiles) {
                      selectedImages.add(File(image.path));
                    }
                  });
                },
                child: quicksandWhiteBold('ADD IMAGE'))
          ],
        )
      ]),
    );
  }
}
