import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/models/glass_model.dart';
import 'package:imeasure_mobile/providers/cart_provider.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';

import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/text_widgets.dart';

class InitialQuotationScreen extends ConsumerStatefulWidget {
  final String windowID;
  final num width;
  final num height;
  const InitialQuotationScreen(
      {super.key,
      required this.windowID,
      required this.width,
      required this.height});

  @override
  ConsumerState<InitialQuotationScreen> createState() =>
      _InitialQuotationScreenState();
}

class _InitialQuotationScreenState
    extends ConsumerState<InitialQuotationScreen> {
  List<dynamic> mandatoryWindowFields = [];
  List<Map<dynamic, dynamic>> optionalWindowFields = [];

  //  PAYMENT VARIABLES
  num totalMandatoryPayment = 0;
  num totalGlassPrice = 0;
  num totalOverallPayment = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);

        final window = await getThisWindowDoc(widget.windowID);
        final windowData = window.data() as Map<dynamic, dynamic>;

        List<dynamic> windowFields = windowData[WindowFields.windowFields];

        mandatoryWindowFields = windowFields
            .where((windowField) => windowField[WindowSubfields.isMandatory])
            .toList();
        List<dynamic> _optionalWindowFields = windowFields
            .where((windowField) => !windowField[WindowSubfields.isMandatory])
            .toList();
        for (var optionalFields in _optionalWindowFields) {
          num price = 0;
          if (optionalFields[WindowSubfields.priceBasis] == 'HEIGHT') {
            switch (ref.read(cartProvider).selectedColor) {
              case WindowColors.brown:
                price = (optionalFields[WindowSubfields.brownPrice] / 21) *
                    widget.height;
                break;
              case WindowColors.white:
                price = (optionalFields[WindowSubfields.whitePrice] / 21) *
                    widget.height;
                break;
              case WindowColors.mattBlack:
                price = (optionalFields[WindowSubfields.mattBlackPrice] / 21) *
                    widget.height;
                break;
              case WindowColors.mattGray:
                price = (optionalFields[WindowSubfields.mattGrayPrice] / 21) *
                    widget.height;
                break;
              case WindowColors.woodFinish:
                price = (optionalFields[WindowSubfields.woodFinishPrice] / 21) *
                    widget.height;
                break;
            }
          } else if (optionalFields[WindowSubfields.priceBasis] == 'WIDTH') {
            switch (ref.read(cartProvider).selectedColor) {
              case WindowColors.brown:
                price = (optionalFields[WindowSubfields.brownPrice] / 21) *
                    widget.width;
                break;
              case WindowColors.white:
                price = (optionalFields[WindowSubfields.whitePrice] / 21) *
                    widget.width;
                break;
              case WindowColors.mattBlack:
                price = (optionalFields[WindowSubfields.mattBlackPrice] / 21) *
                    widget.width;
                break;
              case WindowColors.mattGray:
                price = (optionalFields[WindowSubfields.mattGrayPrice] / 21) *
                    widget.width;
                break;
              case WindowColors.woodFinish:
                price = (optionalFields[WindowSubfields.woodFinishPrice] / 21) *
                    widget.width;
                break;
            }
          }
          optionalWindowFields.add({
            OptionalWindowFields.isSelected: false,
            OptionalWindowFields.optionalFields: optionalFields,
            OptionalWindowFields.price: price
          });
        }

        for (var windowSubField in mandatoryWindowFields) {
          if (windowSubField[WindowSubfields.priceBasis] == 'HEIGHT') {
            switch (ref.read(cartProvider).selectedColor) {
              case WindowColors.brown:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.brownPrice] / 21) *
                        widget.height;
                break;
              case WindowColors.white:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.whitePrice] / 21) *
                        widget.height;
                break;
              case WindowColors.mattBlack:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.mattBlackPrice] / 21) *
                        widget.height;
                break;
              case WindowColors.mattGray:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.mattGrayPrice] / 21) *
                        widget.height;
                break;
              case WindowColors.woodFinish:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
                        widget.height;
                break;
            }
          } else if (windowSubField[WindowSubfields.priceBasis] == 'WIDTH') {
            switch (ref.read(cartProvider).selectedColor) {
              case WindowColors.brown:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.brownPrice] / 21) *
                        widget.width;
                break;
              case WindowColors.white:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.whitePrice] / 21) *
                        widget.width;
                break;
              case WindowColors.mattBlack:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.mattBlackPrice] / 21) *
                        widget.width;
                break;
              case WindowColors.mattGray:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.mattGrayPrice] / 21) *
                        widget.width;
                break;
              case WindowColors.woodFinish:
                totalMandatoryPayment +=
                    (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
                        widget.width;
                break;
            }
          }
        }

        totalGlassPrice =
            getProperGlass(ref.read(cartProvider).selectedGlassType) != null
                ? (getProperGlass(ref.read(cartProvider).selectedGlassType)!
                        .pricePerSFT) *
                    widget.width *
                    widget.height
                : 0;
        totalMandatoryPayment = totalMandatoryPayment + totalGlassPrice;
        totalOverallPayment = totalMandatoryPayment;

        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error getting window for checkout: $error')));
        ref.read(loadingProvider).toggleLoading(false);
        Navigator.of(context).pop();
      }
    });
  }

  void setTotalOverallPayment() {
    num totalOptionalPayments = 0;
    for (var optionalFields in optionalWindowFields) {
      if (optionalFields['isSelected']) {
        totalOptionalPayments += optionalFields['price'];
      }
    }
    setState(() {
      totalOverallPayment = totalMandatoryPayment + totalOptionalPayments;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
              child: Column(
            children: [
              _selectedDetails(),
              _paymentBreakdownWidget(),
              if (optionalWindowFields.isNotEmpty) _optionalWindowFields(),
              all10Pix(
                child: Row(children: [
                  montserratBlackBold(
                      'Total Overall Quatation: PHP ${formatPrice(totalOverallPayment.toDouble())}',
                      fontSize: 16)
                ]),
              ),
              ElevatedButton(
                  onPressed: () => generateOrder(context, ref,
                      width: widget.width,
                      height: widget.height,
                      mandatoryWindowFields: mandatoryWindowFields,
                      optionalWindowFields: optionalWindowFields,
                      totalGlassPrice: totalGlassPrice,
                      totalOverallPayment: totalOverallPayment),
                  child: montserratMidnightBlueBold('GENERATE ORDER')),
              Gap(20),
            ],
          ))),
    );
  }

  Widget _selectedDetails() {
    return all10Pix(
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          montserratBlackBold('Inputted Window Details'),
          montserratBlackRegular('Width: ${widget.width} ft', fontSize: 14),
          montserratBlackRegular('Height: ${widget.height} ft', fontSize: 14),
          montserratBlackRegular(
              'Glass Type: ${ref.read(cartProvider).selectedGlassType}',
              fontSize: 14),
          montserratBlackRegular(
              'Color: ${ref.read(cartProvider).selectedColor}',
              fontSize: 14),
          Gap(10),
        ]),
      ]),
    );
  }

  Widget _paymentBreakdownWidget() {
    return all10Pix(
      child: Container(
        decoration: BoxDecoration(border: Border.all()),
        padding: EdgeInsets.all(5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mandatoryWindowFields
                  .toList()
                  .map((windowFieldModel) =>
                      _mandatoryWindowSubfield(windowFieldModel))
                  .toList()),
          Gap(10),
          montserratBlackRegular(
              'Glass: PHP ${totalGlassPrice.toStringAsFixed(2)}',
              fontSize: 12),
          Divider(),
          montserratBlackBold(
              'Total Inital Quotation: PHP ${formatPrice(totalMandatoryPayment.toDouble())}',
              fontSize: 16)
        ]),
      ),
    );
  }

  Widget _mandatoryWindowSubfield(Map<dynamic, dynamic> windowSubField) {
    num price = 0;
    if (windowSubField[WindowSubfields.priceBasis] == 'HEIGHT') {
      switch (ref.read(cartProvider).selectedColor) {
        case WindowColors.brown:
          price =
              (windowSubField[WindowSubfields.brownPrice] / 21) * widget.height;
          break;
        case WindowColors.white:
          price =
              (windowSubField[WindowSubfields.whitePrice] / 21) * widget.height;
          break;
        case WindowColors.mattBlack:
          price = (windowSubField[WindowSubfields.mattBlackPrice] / 21) *
              widget.height;
          break;
        case WindowColors.mattGray:
          price = (windowSubField[WindowSubfields.mattGrayPrice] / 21) *
              widget.height;
          break;
        case WindowColors.woodFinish:
          price = (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
              widget.height;
          break;
      }
    } else if (windowSubField[WindowSubfields.priceBasis] == 'WIDTH') {
      switch (ref.read(cartProvider).selectedColor) {
        case WindowColors.brown:
          price =
              (windowSubField[WindowSubfields.brownPrice] / 21) * widget.width;
          break;
        case WindowColors.white:
          price =
              (windowSubField[WindowSubfields.whitePrice] / 21) * widget.width;
          break;
        case WindowColors.mattBlack:
          price = (windowSubField[WindowSubfields.mattBlackPrice] / 21) *
              widget.width;
          break;
        case WindowColors.mattGray:
          price = (windowSubField[WindowSubfields.mattGrayPrice] / 21) *
              widget.width;
          break;
        case WindowColors.woodFinish:
          price = (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
              widget.width;
          break;
      }
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        montserratBlackRegular('${windowSubField[WindowSubfields.name]}: ',
            fontSize: 14),
        montserratBlackRegular(' PHP ${formatPrice(price.toDouble())}',
            fontSize: 14),
      ],
    );
  }

  Widget _optionalWindowFields() {
    return all10Pix(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          montserratBlackBold('Optional Window Fields', fontSize: 16),
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: optionalWindowFields.length,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                        value: optionalWindowFields[index]
                            [OptionalWindowFields.isSelected],
                        onChanged: (newVal) {
                          optionalWindowFields[index]
                              [OptionalWindowFields.isSelected] = newVal;

                          setTotalOverallPayment();
                        }),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          montserratBlackRegular(
                              optionalWindowFields[index]
                                      [OptionalWindowFields.optionalFields]
                                  [WindowSubfields.name],
                              fontSize: 14),
                          montserratBlackRegular(
                              'PHP ${formatPrice(optionalWindowFields[index][OptionalWindowFields.price].toDouble())}',
                              fontSize: 14),
                        ],
                      ),
                    ),
                  ],
                );
              }),
          Divider()
        ],
      ),
    );
  }
}
