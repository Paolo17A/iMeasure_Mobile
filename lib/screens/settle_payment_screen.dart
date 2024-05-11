import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/navigator_util.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../providers/settle_payment_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/dropdown_widget.dart';

class SettlePaymentScreen extends ConsumerStatefulWidget {
  final String orderID;
  const SettlePaymentScreen({super.key, required this.orderID});

  @override
  ConsumerState<SettlePaymentScreen> createState() =>
      _RenterSettlePaymentScreenState();
}

class _RenterSettlePaymentScreenState
    extends ConsumerState<SettlePaymentScreen> {
  num width = 0;
  num height = 0;
  String glassType = '';
  String color = '';
  List<dynamic> mandatoryMap = [];
  List<dynamic> optionalMap = [];
  num orderPrice = 0;
  String quotationURL = '';

  //  WINDOW VARIABLES
  String windowName = '';
  String windowImageURL = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final orderDoc = await getThisOrderDoc(widget.orderID);
        final orderData = orderDoc.data() as Map<dynamic, dynamic>;

        width = orderData[OrderFields.width];
        height = orderData[OrderFields.height];
        glassType = orderData[OrderFields.glassType];
        color = orderData[OrderFields.color];
        mandatoryMap = orderData[OrderFields.mandatoryMap];
        optionalMap = orderData[OrderFields.optionalMap];
        orderPrice = orderData[OrderFields.windowOverallPrice] +
            orderData[OrderFields.laborPrice];
        quotationURL = orderData[OrderFields.quotationURL];

        //  Window Data
        String windowID = orderData[OrderFields.windowID];
        final windowDoc = await getThisWindowDoc(windowID);
        final windowData = windowDoc.data() as Map<dynamic, dynamic>;
        windowName = windowData[WindowFields.name];
        windowImageURL = windowData[WindowFields.imageURL];

        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting generated order: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(settlePaymentProvider);
    return Scaffold(
      appBar: appBarWidget(mayPop: true, actions: [
        if (quotationURL.isNotEmpty)
          TextButton(
              onPressed: () => NavigatorRoutes.quotation(context,
                  quotationURL: quotationURL),
              child:
                  montserratMidnightBlueBold('VIEW\nBREAKDOWN', fontSize: 10))
      ]),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all10Pix(
                child: Column(
              children: [_settleRentHeader(), Divider(), paymentWidgets()],
            )),
          )),
    );
  }

  Widget _settleRentHeader() {
    return Column(children: [
      montserratBlackBold('SETTLE PENDING PAYMENT', fontSize: 26),
      vertical20Pix(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              montserratBlackRegular('Window: $windowName'),
              montserratBlackRegular('Width: ${width.toStringAsFixed(1)} ft',
                  fontSize: 14),
              montserratBlackRegular('Height: ${height.toStringAsFixed(1)} ft',
                  fontSize: 14),
              montserratBlackRegular('Glass Type: $glassType', fontSize: 14),
              montserratBlackRegular('Color: $color', fontSize: 14),
            ]),
            if (windowImageURL.isNotEmpty)
              Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Image.network(
                  windowImageURL,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.3,
                  fit: BoxFit.cover,
                ),
              )
          ],
        ),
      )
    ]);
  }

  Widget paymentWidgets() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: CustomColors.deepNavyBlue,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Column(children: [
            montserratWhiteBold(
                'TOTAL: PHP ${formatPrice(orderPrice.toDouble())}',
                fontSize: 24),
            _paymentMethod(),
            if (ref
                .read(settlePaymentProvider)
                .selectedPaymentMethod
                .isNotEmpty)
              _uploadPayment(),
          ]),
        ),
        _checkoutButton()
      ],
    );
  }

  Widget _paymentMethod() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [montserratWhiteBold('PAYMENT METHOD')],
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: dropdownWidget(
              ref.read(settlePaymentProvider).selectedPaymentMethod, (newVal) {
            ref.read(settlePaymentProvider).setSelectedPaymentMethod(newVal!);
          }, ['GCASH', 'PAYMAYA'], 'Select your payment method', false),
        )
      ],
    ));
  }

  Widget _uploadPayment() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                montserratWhiteBold('SEND YOUR PAYMENT HERE', fontSize: 18),
                if (ref.read(settlePaymentProvider).selectedPaymentMethod ==
                    'GCASH')
                  montserratWhiteBold('GCASH: +639221234567', fontSize: 14)
                else if (ref
                        .read(settlePaymentProvider)
                        .selectedPaymentMethod ==
                    'PAYMAYA')
                  montserratWhiteBold('PAYMAYA: +639221234567', fontSize: 14)
              ],
            )
          ],
        ),
        if (ref.read(settlePaymentProvider).paymentImage != null)
          Image.file(ref.read(settlePaymentProvider).paymentImage!,
              width: 200, height: 200),
        ElevatedButton(
            onPressed: () async =>
                ref.read(settlePaymentProvider).setPaymentImage(),
            child: montserratMidnightBlueBold('UPLOAD PAYMENT IMAGE'))
      ],
    ));
  }

  Widget _checkoutButton() {
    return Container(
      child: ElevatedButton(
          onPressed:
              ref.read(settlePaymentProvider).selectedPaymentMethod.isEmpty ||
                      ref.read(settlePaymentProvider).paymentImage == null
                  ? null
                  : () => settlePendingPayment(context, ref,
                      orderID: widget.orderID, amount: orderPrice),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: CustomColors.lavenderMist),
          child: montserratMidnightBlueBold('PROCESS PAYMENT')),
    );
  }
}
