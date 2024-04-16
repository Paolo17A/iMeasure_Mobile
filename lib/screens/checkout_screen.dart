import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/providers/cart_provider.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_text_field_widget.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

import '../utils/color_util.dart';
import '../widgets/dropdown_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String name = '';
  String imageURL = '';
  num minHeight = 0;
  num maxHeight = 0;
  num minWidth = 0;
  num maxWidth = 0;

  final widthController = TextEditingController();
  final heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final cartEntry =
            await getThisCartEntry(ref.read(cartProvider).selectedCartItem);
        final cartData = cartEntry.data() as Map<dynamic, dynamic>;

        final window = await getThisWindowDoc(cartData[CartFields.windowID]);
        final windowData = window.data() as Map<dynamic, dynamic>;
        name = windowData[WindowFields.name];
        imageURL = windowData[WindowFields.imageURL];
        minHeight = windowData[WindowFields.minHeight];
        maxHeight = windowData[WindowFields.maxHeight];
        minWidth = windowData[WindowFields.minWidth];
        maxWidth = windowData[WindowFields.maxWidth];
        ref.read(cartProvider).setSelectedPaymentMethod('');
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error getting window for checkout: $error')));
        ref.read(loadingProvider).toggleLoading(false);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    widthController.dispose();
    heightController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) {
        ref.read(cartProvider).setSelectedCartItem('');
        ref.read(cartProvider).setGlassType('');
        ref.read(cartProvider).setSelectedPaymentMethod('');
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: appBarWidget(),
          body: stackedLoadingContainer(
              context,
              ref.read(loadingProvider).isLoading,
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  child: all20Pix(
                      child: Column(
                    children: [
                      windowDetails(),
                      Divider(color: CustomColors.midnightBlue),
                      measurementWidgets(),
                      paymentWidgets()
                    ],
                  )),
                ),
              )),
        ),
      ),
    );
  }

  Widget windowDetails() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (imageURL.isNotEmpty)
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Image.network(imageURL,
              width: MediaQuery.of(context).size.width * 0.3),
        ),
      Gap(20),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            montserratBlackBold(name),
            montserratMidnightBlueRegular(
                'Available Width: ${minWidth.toString()} - ${maxWidth.toString()}cm',
                fontSize: 12),
            montserratMidnightBlueRegular(
                'Available Height: ${minHeight.toString()} - ${maxHeight.toString()}cm',
                fontSize: 12),
          ],
        ),
      )
    ]);
  }

  Widget measurementWidgets() {
    return vertical20Pix(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: CustomColors.slateBlue,
            borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          montserratWhiteBold('INPUT YOUR WINDOW DETAILS', fontSize: 18),
          Gap(20),
          montserratWhiteRegular('WIDTH', fontSize: 16),
          CustomTextField(
              text: 'Width',
              controller: widthController,
              textInputType: TextInputType.numberWithOptions(decimal: true),
              fillColor: Colors.white,
              displayPrefixIcon: null),
          Gap(10),
          montserratWhiteRegular('HEIGHT', fontSize: 16),
          CustomTextField(
              text: 'Height',
              controller: heightController,
              textInputType: TextInputType.numberWithOptions(decimal: true),
              fillColor: Colors.white,
              displayPrefixIcon: null),
          Gap(10),
          montserratWhiteRegular('GLASS TYPE', fontSize: 16),
          Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: dropdownWidget(ref.read(cartProvider).selectedPaymentMethod,
                (newVal) {
              ref.read(cartProvider).setGlassType(newVal!);
            }, ['REGULAR', 'TEMPERED'], 'Select your glass type', false),
          )
        ]),
      ),
    );
  }

  Widget paymentWidgets() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: CustomColors.slateBlue,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Column(children: [
        _paymentMethod(),
        if (ref.read(cartProvider).selectedPaymentMethod.isNotEmpty)
          _uploadPayment(),
        _checkoutButton()
      ]),
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
          child: dropdownWidget(ref.read(cartProvider).selectedPaymentMethod,
              (newVal) {
            ref.read(cartProvider).setSelectedPaymentMethod(newVal!);
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
                montserratWhiteBold('SEND YOUR PAYMENT HERE'),
                if (ref.read(cartProvider).selectedPaymentMethod == 'GCASH')
                  montserratWhiteBold('GCASH: +639221234567', fontSize: 14)
                else if (ref.read(cartProvider).selectedPaymentMethod ==
                    'PAYMAYA')
                  montserratWhiteBold('PAYMAYA: +639221234567', fontSize: 14)
              ],
            )
          ],
        ),
      ],
    ));
  }

  Widget _checkoutButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
          onPressed: ref.read(cartProvider).selectedPaymentMethod.isEmpty ||
                  ref.read(cartProvider).selectedGlassType.isEmpty
              ? null
              : () => purchaseSelectedCartItem(context, ref,
                  widthController: widthController,
                  heightController: heightController,
                  minWidth: minWidth,
                  maxWidth: maxWidth,
                  minHeight: minHeight,
                  maxHeight: maxHeight),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.blueGrey),
          child: montserratMidnightBlueBold('MAKE PAYMENT')),
    );
  }
}
