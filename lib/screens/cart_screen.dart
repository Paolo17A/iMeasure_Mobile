import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/quotation_dialog_util.dart';
import 'package:imeasure_mobile/widgets/app_bottom_navbar_widget.dart';
import 'package:imeasure_mobile/widgets/app_drawer_widget.dart';

import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  List<DocumentSnapshot> associatedItemDocs = [];
  num paidAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        ref.read(cartProvider).setCartItems(await getCartEntries(context));
        associatedItemDocs = await getSelectedItemDocs(
            ref.read(cartProvider).cartItems.map((cartDoc) {
          final cartData = cartDoc.data() as Map<dynamic, dynamic>;
          return cartData[CartFields.itemID].toString();
        }).toList());
        setState(() {});
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting cart entries: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) => ref.read(cartProvider).resetSelectedCartItems(),
      child: Scaffold(
        appBar: appBarWidget(mayPop: true),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.cart),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _checkoutBar(),
            bottomNavigationBar(context, ref, index: 2)
          ],
        ),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: _cartEntries(),
            )),
      ),
    );
  }

  Widget _cartEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        all10Pix(child: quicksandBlackBold('CART', fontSize: 40)),
        ref.read(cartProvider).cartItems.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(cartProvider).cartItems.length,
                itemBuilder: (context, index) {
                  return _cartEntry(ref.read(cartProvider).cartItems[index]);
                })
            : vertical20Pix(
                child: quicksandBlackBold(
                    'YOU DO NOT HAVE ANY ITEMS IN YOUR CART'))
      ],
    );
  }

  Widget _cartEntry(DocumentSnapshot cartDoc) {
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    String itemType = cartData[CartFields.itemType];
    int quantity = cartData[CartFields.quantity];
    Map<dynamic, dynamic> quotation = {};
    num price = 0;
    num laborPrice = 0;
    String color = '';
    DocumentSnapshot? associatedItemDoc =
        associatedItemDocs.where((productDoc) {
      return productDoc.id == cartData[CartFields.itemID].toString();
    }).firstOrNull;
    if (associatedItemDoc == null)
      return Container();
    else {
      String name = associatedItemDoc[ItemFields.name];
      List<dynamic> imageURLs = associatedItemDoc[ItemFields.imageURLs];
      List<dynamic> accesoryField = [];
      if (itemType == ItemTypes.rawMaterial) {
        price = associatedItemDoc[ItemFields.price];
      } else {
        quotation = cartData[CartFields.quotation];
        price = quotation[QuotationFields.itemOverallPrice];
        laborPrice = quotation[QuotationFields.laborPrice];
        accesoryField = associatedItemDoc[ItemFields.accessoryFields];
        color = quotation[QuotationFields.color];
      }
      //num price = associatedItemDoc[ItemFields.price];
      return Stack(
        children: [
          Container(
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColors.deepCharcoal)),
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  //  CHECKBOX
                  Checkbox(
                      value: ref
                          .read(cartProvider)
                          .selectedCartItemIDs
                          .contains(cartDoc.id),
                      onChanged:
                          (itemType == ItemTypes.rawMaterial || laborPrice > 0)
                              ? (newVal) {
                                  if (newVal == null) return;
                                  setState(() {
                                    if (newVal) {
                                      ref
                                          .read(cartProvider)
                                          .selectCartItem(cartDoc.id);
                                    } else {
                                      ref
                                          .read(cartProvider)
                                          .deselectCartItem(cartDoc.id);
                                    }
                                  });
                                }
                              : null),
                  Flexible(
                    flex: 4,
                    child: Column(
                      children: [
                        //ITEM DATA
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(imageURLs.first))),
                              ),
                            ),
                            Gap(24),
                            Flexible(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  quicksandBlackBold(name),
                                  Row(
                                    children: [
                                      quicksandBlackRegular(
                                          'PHP ${formatPrice(price.toDouble())}',
                                          fontSize: 16),
                                    ],
                                  ),
                                  if (itemType != ItemTypes.rawMaterial ||
                                      laborPrice > 0)
                                    quicksandBlackRegular(
                                        'Labor Price: PHP ${laborPrice > 0 ? laborPrice : 'TBA'}',
                                        fontSize: 14),
                                  if (itemType != ItemTypes.rawMaterial)
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                quicksandBlackRegular(
                                                    'Width: ${(quotation[QuotationFields.width] as num).toStringAsFixed(2)}ft',
                                                    fontSize: 12),
                                                quicksandBlackRegular(
                                                    'Height: ${(quotation[QuotationFields.height] as num).toStringAsFixed(2)}ft',
                                                    fontSize: 12)
                                              ]),
                                          if (itemType != ItemTypes.rawMaterial)
                                            _showQuotationButton(
                                                itemType,
                                                cartData[CartFields.quotation],
                                                name,
                                                imageURLs,
                                                accesoryField,
                                                color)
                                        ])
                                ],
                              ),
                            )
                          ],
                        ),
                        //  CART DATA
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // QUANTITY
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  CustomColors.deepCharcoal)),
                                      child: TextButton(
                                          onPressed: quantity == 1
                                              ? null
                                              : () => changeCartItemQuantity(
                                                  context, ref,
                                                  cartEntryDoc: cartDoc,
                                                  isIncreasing: false),
                                          child: quicksandBlackRegular('-',
                                              fontSize: 16))),
                                  Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  CustomColors.deepCharcoal)),
                                      child: Center(
                                        child: quicksandBlackRegular(
                                            quantity.toString(),
                                            fontSize: 15),
                                      )),
                                  Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  CustomColors.deepCharcoal)),
                                      child: TextButton(
                                          onPressed: () =>
                                              changeCartItemQuantity(
                                                  context, ref,
                                                  cartEntryDoc: cartDoc,
                                                  isIncreasing: true),
                                          child: quicksandBlackRegular('+',
                                              fontSize: 16)))
                                ],
                              ),
                            ),

                            Flexible(
                              flex: 2,
                              child: IconButton(
                                  onPressed: () => displayDeleteEntryDialog(
                                          context,
                                          message:
                                              'Are you sure you wish to remove ${name} from your cart?',
                                          deleteEntry: () {
                                        if (ref
                                            .read(cartProvider)
                                            .selectedCartItemIDs
                                            .contains(cartDoc.id)) {
                                          ref
                                              .read(cartProvider)
                                              .deselectCartItem(cartDoc.id);
                                        }
                                        removeCartItem(context, ref,
                                            cartDoc: cartDoc);
                                      }),
                                  icon: Icon(Icons.delete,
                                      color: CustomColors.coralRed)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          if (laborPrice > 0)
            Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                ))
        ],
      );
    }
  }

  Widget _showQuotationButton(
      String itemType,
      Map<dynamic, dynamic> quotation,
      String itemName,
      List<dynamic> imageURLs,
      List<dynamic> accessoryFields,
      String color) {
    final mandatoryWindowFields = quotation[QuotationFields.mandatoryMap];
    final optionalWindowFields =
        quotation[QuotationFields.optionalMap] as List<dynamic>;
    return ElevatedButton(
        onPressed: () => showCartQuotationDialog(context, ref,
            laborPrice: quotation[QuotationFields.laborPrice],
            totalOverallPayment: quotation[QuotationFields.itemOverallPrice],
            mandatoryWindowFields: mandatoryWindowFields,
            optionalWindowFields: optionalWindowFields,
            width: quotation[QuotationFields.width],
            height: quotation[QuotationFields.height],
            color: color,
            itemName: itemName,
            accessoryFields: accessoryFields,
            imageURLs: imageURLs),
        child: montserratWhiteRegular('VIEW\nQUOTATION', fontSize: 10));
  }

  Widget _totalAmountWidget() {
    //  1. Get every associated cart DocumentSnapshot
    List<DocumentSnapshot> selectedCartDocs = [];
    for (var cartID in ref.read(cartProvider).selectedCartItemIDs) {
      selectedCartDocs.add(ref
          .read(cartProvider)
          .cartItems
          .where((element) => element.id == cartID)
          .first);
    }
    //  2. get list of associated products
    num totalAmount = 0;
    //  Go through every selected cart item
    for (var cartDoc in selectedCartDocs) {
      final cartData = cartDoc.data() as Map<dynamic, dynamic>;
      String itemID = cartData[CartFields.itemID];
      num quantity = cartData[CartFields.quantity];
      DocumentSnapshot? itemDoc =
          associatedItemDocs.where((item) => item.id == itemID).firstOrNull;
      if (itemDoc == null) {
        continue;
      }
      final itemData = itemDoc.data() as Map<dynamic, dynamic>;
      if (itemData[ItemFields.itemType] == ItemTypes.rawMaterial) {
        num price = itemData[ItemFields.price];
        totalAmount += quantity * price;
      } else {
        Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
        totalAmount +=
            (quantity * quotation[QuotationFields.itemOverallPrice]) +
                quotation[QuotationFields.laborPrice];
      }
    }
    paidAmount = totalAmount;
    return quicksandWhiteBold('PHP ${formatPrice(totalAmount.toDouble())}',
        textAlign: TextAlign.left);
  }

  Widget _checkoutBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
          border:
              Border.symmetric(horizontal: BorderSide(color: Colors.white))),
      child: BottomAppBar(
        color: CustomColors.deepCharcoal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(flex: 2, child: _totalAmountWidget()),
            Flexible(
                //flex: 2,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: CustomColors.lavenderMist,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                BorderSide(color: CustomColors.lavenderMist))),
                    onPressed:
                        ref.read(cartProvider).selectedCartItemIDs.isEmpty
                            ? null
                            : () => Navigator.of(context)
                                .pushNamed(NavigatorRoutes.checkout),
                    child: quicksandWhiteRegular('CHECKOUT', fontSize: 10)))
          ],
        ),
      ),
    );
  }
}
