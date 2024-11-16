import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:imeasure_mobile/widgets/text_widgets.dart';

import '../utils/color_util.dart';
import '../widgets/dropdown_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  List<Map<dynamic, dynamic>> productEntries = [];
  num totalAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        ref.read(loadingProvider).toggleLoading(true);
        //  1. Get every associated cart DocumentSnapshot
        List<DocumentSnapshot> selectedCartDocs = [];
        for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
          selectedCartDocs.add(ref
              .read(cartProvider)
              .cartItems
              .where((element) => element.id == cartID)
              .first);
        }

        //  Get product details
        for (var cartDoc in selectedCartDocs) {
          final cartData = cartDoc.data() as Map<dynamic, dynamic>;
          String itemID = cartData[CartFields.itemID];
          final item = await getThisItemDoc(itemID);
          final itemData = item.data() as Map<dynamic, dynamic>;
          String itemType = itemData[ItemFields.itemType];
          num quantity = cartData[CartFields.quantity];
          if (itemType == ItemTypes.rawMaterial) {
            Map<dynamic, dynamic> productEntry = {
              ItemFields.imageURLs: itemData[ItemFields.imageURLs],
              ItemFields.name: itemData[ItemFields.name],
              ItemFields.price: itemData[ItemFields.price],
              CartFields.quantity: cartData[CartFields.quantity]
            };
            productEntries.add(productEntry);
            totalAmount +=
                cartData[CartFields.quantity] * itemData[ItemFields.price];
          } else {
            Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
            num itemPrice =
                (quantity * quotation[QuotationFields.itemOverallPrice]) +
                    quotation[QuotationFields.laborPrice];
            Map<dynamic, dynamic> productEntry = {
              ItemFields.imageURLs: itemData[ItemFields.imageURLs],
              ItemFields.name: itemData[ItemFields.name],
              ItemFields.price: itemPrice,
              CartFields.quantity: cartData[CartFields.quantity]
            };
            productEntries.add(productEntry);
            totalAmount += itemPrice;
          }
        }
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
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) {
        ref.read(cartProvider).setSelectedPaymentMethod('');
        ref.read(cartProvider).resetProofOfPaymentFile();
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
                      quicksandBlackBold('PRODUCT CHECKOUT', fontSize: 28),
                      Column(
                          children: productEntries
                              .map(
                                  (productEntry) => _productEntry(productEntry))
                              .toList()),
                      quicksandBlackRegular(
                          'TOTAL: PHP ${formatPrice(totalAmount.toDouble())}'),
                      Divider(color: CustomColors.deepCharcoal),
                      paymentWidgets(),
                      _checkoutButton()
                    ],
                  )),
                ),
              )),
        ),
      ),
    );
  }

  Widget _productEntry(Map<dynamic, dynamic> productEntry) {
    List<dynamic> imageURLs = productEntry[ItemFields.imageURLs];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(4)),
          padding: EdgeInsets.all(4),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(imageURLs.first,
                  width: 50, height: 50, fit: BoxFit.cover),
              Gap(4),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                quicksandBlackBold(productEntry[ItemFields.name],
                    fontSize: 16, textOverflow: TextOverflow.ellipsis),
                quicksandBlackRegular(
                    'Quanitity: ${productEntry[CartFields.quantity]}',
                    fontSize: 12,
                    textAlign: TextAlign.left),
                quicksandBlackRegular(
                    'SRP: PHP ${formatPrice(productEntry[ItemFields.price].toDouble())}',
                    fontSize: 12,
                    textAlign: TextAlign.left),
              ]),
            ],
          )),
    );
  }

  Widget paymentWidgets() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: CustomColors.deepCharcoal,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Column(children: [
        _paymentMethod(),
        if (ref.read(cartProvider).selectedPaymentMethod.isNotEmpty)
          _uploadPayment(),
      ]),
    );
  }

  Widget _paymentMethod() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [quicksandWhiteBold('PAYMENT METHOD')],
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: dropdownWidget(ref.read(cartProvider).selectedPaymentMethod,
              (newVal) {
            ref.read(cartProvider).setSelectedPaymentMethod(newVal!);
          }, ['GCASH', 'PAYMAYA'], 'Select your payment method', false),
        ),
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
                quicksandWhiteBold('SEND YOUR PAYMENT HERE'),
                if (ref.read(cartProvider).selectedPaymentMethod == 'GCASH')
                  quicksandWhiteBold('GCASH:\n09484548667\nJonas Banca',
                      fontSize: 14)
                else if (ref.read(cartProvider).selectedPaymentMethod ==
                    'PAYMAYA')
                  quicksandWhiteBold('PAYMAYA:\n09484548667\nJonas Banca',
                      fontSize: 14)
              ],
            )
          ],
        ),
        if (ref.read(cartProvider).proofOfPaymentFile != null) ...[
          Divider(),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: MemoryImage(ref
                        .read(cartProvider)
                        .proofOfPaymentFile!
                        .readAsBytesSync()))),
          ),
          Gap(8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
                onPressed: () =>
                    ref.read(cartProvider).resetProofOfPaymentFile(),
                icon: Icon(Icons.delete, color: Colors.white)),
          )
        ],
        all10Pix(
          child: ElevatedButton(
              onPressed: () => ref.read(cartProvider).setProofOfPaymentFile(),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white))),
              child: quicksandWhiteRegular('UPLOAD PROOF OF PAYMENT',
                  fontSize: 12)),
        )
      ],
    ));
  }

  Widget _checkoutButton() {
    return Builder(builder: (context) {
      return vertical10Pix(
        child: Container(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
              onPressed: ref.read(cartProvider).selectedPaymentMethod.isEmpty
                  ? null
                  : () => purchaseSelectedCartItems(context, ref,
                      paidAmount: totalAmount),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.4)),
              child: quicksandWhiteRegular('MAKE PAYMENT')),
        ),
      );
    });
  }
}
