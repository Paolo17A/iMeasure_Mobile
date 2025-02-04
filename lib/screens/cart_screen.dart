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

class _CartScreenState extends ConsumerState<CartScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  List<DocumentSnapshot> associatedItemDocs = [];
  num paidAmount = 0;
  bool displayCheckout = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
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
      child: DefaultTabController(
        initialIndex: 2,
        length: 3,
        child: Scaffold(
          appBar: appBarWidget(mayPop: true),
          drawer: appDrawer(context, ref, route: NavigatorRoutes.cart),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (displayCheckout) _checkoutBar(),
              bottomNavigationBar(context, ref, index: 2)
            ],
          ),
          body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            Column(
              children: [
                TabBar(
                    onTap: (value) {
                      setState(() {
                        if (value == 2)
                          displayCheckout = true;
                        else
                          displayCheckout = false;
                      });
                    },
                    tabs: [
                      Tab(
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              quicksandBlackBold(
                                  'NO ADDITIONAL\nCOST REQUESTED: ',
                                  fontSize: 12),
                              quicksandCoralRedBold(
                                  ref
                                      .read(cartProvider)
                                      .noAdditionalCostRequestedCartItems
                                      .length
                                      .toString(),
                                  fontSize: 15)
                            ],
                          )),
                      Tab(
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              quicksandBlackBold('PENDING\nADDITIONAL COST: ',
                                  fontSize: 12),
                              quicksandCoralRedBold(
                                  ref
                                      .read(cartProvider)
                                      .pendingAdditionalCostCartItems
                                      .length
                                      .toString(),
                                  fontSize: 15)
                            ],
                          )),
                      Tab(
                          height: 80,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              quicksandBlackBold('FOR\nCHECKOUT: ',
                                  fontSize: 12),
                              quicksandCoralRedBold(
                                  ref
                                      .read(cartProvider)
                                      .forCheckoutCartItems
                                      .length
                                      .toString(),
                                  fontSize: 15)
                            ],
                          ))
                    ]),
                SizedBox(
                  height: displayCheckout
                      ? MediaQuery.of(context).size.height - 335
                      : MediaQuery.of(context).size.height - 320,
                  child: TabBarView(children: [
                    _noAdditionalCostRequested(),
                    _pendingAdditionalCostRequested(),
                    _cartEntries()
                  ]),
                )
              ],
            ),

            // SingleChildScrollView(
            //   child: _cartEntries(),
            // )
          ),
        ),
      ),
    );
  }

  Widget _noAdditionalCostRequested() {
    return ref.read(cartProvider).noAdditionalCostRequestedCartItems.isNotEmpty
        ? SingleChildScrollView(
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref
                    .read(cartProvider)
                    .noAdditionalCostRequestedCartItems
                    .length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _cartEntry(ref
                      .read(cartProvider)
                      .noAdditionalCostRequestedCartItems[index]);
                }))
        : Center(
            child: quicksandBlackBold(
                'YOU HAVE NO CART ITEMS WHICH NEED TO HAVE ADDITIONAL COSTS REQUESTED'));
  }

  Widget _pendingAdditionalCostRequested() {
    return ref.read(cartProvider).pendingAdditionalCostCartItems.isNotEmpty
        ? SingleChildScrollView(
            child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref
                    .read(cartProvider)
                    .pendingAdditionalCostCartItems
                    .length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _cartEntry(ref
                      .read(cartProvider)
                      .pendingAdditionalCostCartItems[index]);
                }))
        : Center(
            child: quicksandBlackBold(
                'YOU HAVE NO CART ITEMS PENDING ADDITIONAL COSTS'));
  }

  Widget _cartEntries() {
    return ref.read(cartProvider).forCheckoutCartItems.isNotEmpty
        ? SingleChildScrollView(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(cartProvider).forCheckoutCartItems.length,
                itemBuilder: (context, index) {
                  return _cartEntry(
                      ref.read(cartProvider).forCheckoutCartItems[index]);
                }),
          )
        : Center(
            child:
                quicksandBlackBold('YOU DO NOT HAVE ANY ITEMS IN YOUR CART'));
  }

  Widget _cartEntry(DocumentSnapshot cartDoc) {
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    String itemType = cartData[CartFields.itemType];
    int quantity = cartData[CartFields.quantity];
    Map<dynamic, dynamic> quotation = {};
    num price = 0;
    num laborPrice = 0;
    String color = '';
    num additionalServicePrice = 0;
    bool isRequestingAdditionalService = false;

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
      quotation = cartData[CartFields.quotation];

      if (itemType == ItemTypes.rawMaterial) {
        price = associatedItemDoc[ItemFields.price];
      } else {
        quotation = cartData[CartFields.quotation];
        price = quotation[QuotationFields.itemOverallPrice];
        laborPrice = quotation[QuotationFields.laborPrice];
        accesoryField = associatedItemDoc[ItemFields.accessoryFields];
        color = quotation[QuotationFields.color];
      }
      additionalServicePrice =
          quotation[QuotationFields.additionalServicePrice];
      isRequestingAdditionalService =
          quotation[QuotationFields.isRequestingAdditionalService];
      String requestStatus = quotation[QuotationFields.requestStatus];
      String requestAddress = quotation[QuotationFields.requestAddress];
      String requestContactNumber =
          quotation[QuotationFields.requestContactNumber];
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
                  if (ref
                      .read(cartProvider)
                      .forCheckoutCartItems
                      .contains(cartDoc))
                    _selectItemCheckbox(
                        cartDoc: cartDoc,
                        laborPrice: laborPrice,
                        itemType: itemType),
                  _orderDataWidgets(
                      imageURLs: imageURLs,
                      name: name,
                      quantity: quantity,
                      price: price,
                      itemType: itemType,
                      laborPrice: laborPrice,
                      isRequestingAdditionalService:
                          isRequestingAdditionalService,
                      requestStatus: requestStatus,
                      cartDoc: cartDoc,
                      address: requestAddress,
                      quotation: quotation,
                      accesoryField: accesoryField,
                      requestContactNumber: requestContactNumber,
                      additionalServicePrice: additionalServicePrice,
                      color: color),
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

  Widget _selectItemCheckbox(
      {required DocumentSnapshot cartDoc,
      required num laborPrice,
      required String itemType}) {
    return Checkbox(
        value: ref.read(cartProvider).selectedCartItemIDs.contains(cartDoc.id),
        onChanged: (itemType == ItemTypes.rawMaterial || laborPrice > 0)
            ? (newVal) {
                if (newVal == null) return;
                setState(() {
                  if (newVal) {
                    ref.read(cartProvider).selectCartItem(cartDoc.id);
                  } else {
                    ref.read(cartProvider).deselectCartItem(cartDoc.id);
                  }
                });
              }
            : null);
  }

  Widget _orderDataWidgets(
      {required List<dynamic> imageURLs,
      required int quantity,
      required String name,
      required num price,
      required String itemType,
      required num laborPrice,
      required bool isRequestingAdditionalService,
      required String requestStatus,
      required DocumentSnapshot cartDoc,
      required Map<dynamic, dynamic> quotation,
      required List<dynamic> accesoryField,
      required num additionalServicePrice,
      required String address,
      required String requestContactNumber,
      required String color}) {
    return Flexible(
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
                    if (itemType != ItemTypes.rawMaterial)
                      quicksandBlackRegular(
                          'Labor Price: PHP ${laborPrice > 0 ? laborPrice : 'TBA'}',
                          fontSize: 14),
                    if (isRequestingAdditionalService) ...[
                      if ((itemType == ItemTypes.window ||
                              itemType == ItemTypes.door) &&
                          (requestStatus == RequestStatuses.pending ||
                              requestStatus == RequestStatuses.approved))
                        quicksandBlackRegular(
                            'Installation Address:\n${address} ',
                            fontSize: 12,
                            textAlign: TextAlign.left)
                      else if (itemType == ItemTypes.rawMaterial &&
                          (requestStatus == RequestStatuses.pending ||
                              requestStatus == RequestStatuses.approved))
                        quicksandBlackRegular('Delivery Address:\n${address}',
                            textAlign: TextAlign.left, fontSize: 12),
                      if (requestStatus == RequestStatuses.pending ||
                          requestStatus == RequestStatuses.approved)
                        quicksandBlackRegular(
                            'Contact Number: ${requestContactNumber}',
                            textAlign: TextAlign.left,
                            fontSize: 14),
                      if ((itemType == ItemTypes.window ||
                              itemType == ItemTypes.door) &&
                          requestStatus == RequestStatuses.approved)
                        quicksandBlackRegular(
                            'Installation Fee: PHP ${formatPrice(additionalServicePrice.toDouble())} ',
                            fontSize: 14)
                      else if (itemType == ItemTypes.rawMaterial &&
                          (requestStatus == RequestStatuses.approved))
                        quicksandBlackRegular(
                            'Delivery Fee: PHP ${formatPrice(additionalServicePrice.toDouble())} ',
                            fontSize: 14)
                      else if (itemType == ItemTypes.rawMaterial &&
                          (requestStatus == RequestStatuses.denied))
                        GestureDetector(
                          onTap: quotation[QuotationFields.requestDenialReason]
                                      .toString()
                                      .length >
                                  30
                              ? () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                            child: SingleChildScrollView(
                                              child: Container(
                                                padding: EdgeInsets.all(20),
                                                child: quicksandBlackRegular(
                                                    'Denial Reason: ${quotation[QuotationFields.requestDenialReason].toString()}',
                                                    textAlign: TextAlign.left,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ));
                                }
                              : null,
                          child: quicksandBlackRegular(
                              'Delivery Request Denied: ${quotation[QuotationFields.requestDenialReason]}',
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                              fontSize: 14),
                        )
                      else if ((itemType == ItemTypes.window ||
                              itemType == ItemTypes.door) &&
                          requestStatus == RequestStatuses.denied)
                        GestureDetector(
                          onTap: quotation[QuotationFields.requestDenialReason]
                                      .toString()
                                      .length >
                                  30
                              ? () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => Dialog(
                                            child: SingleChildScrollView(
                                              child: Container(
                                                padding: EdgeInsets.all(20),
                                                child: quicksandBlackRegular(
                                                    'Denial Reason: ${quotation[QuotationFields.requestDenialReason].toString()}',
                                                    textAlign: TextAlign.left,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ));
                                }
                              : null,
                          child: quicksandBlackRegular(
                              'Installation Request Denied: ${quotation[QuotationFields.requestDenialReason]}',
                              textAlign: TextAlign.left,
                              fontSize: 14),
                        )
                    ],
                    if (itemType != ItemTypes.rawMaterial)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  quicksandBlackRegular(
                                      'Width: ${(quotation[QuotationFields.width] as num).toStringAsFixed(2)}ft',
                                      fontSize: 12),
                                  quicksandBlackRegular(
                                      'Height: ${(quotation[QuotationFields.height] as num).toStringAsFixed(2)}ft',
                                      fontSize: 12)
                                ]),
                            if (itemType != ItemTypes.rawMaterial)
                              _showQuotationButton(itemType, quotation, name,
                                  imageURLs, accesoryField, color)
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
              if (ref.read(cartProvider).forCheckoutCartItems.contains(cartDoc))
                _changeQuantityButtons(quantity: quantity, cartDoc: cartDoc),
              if (ref
                  .read(cartProvider)
                  .noAdditionalCostRequestedCartItems
                  .contains(cartDoc)) ...[
                _requestAdditionalCostButton(
                    itemType: itemType,
                    isRequestingAdditionalService:
                        isRequestingAdditionalService,
                    cartID: cartDoc.id)
              ],
              if (!ref
                  .read(cartProvider)
                  .pendingAdditionalCostCartItems
                  .contains(cartDoc))
                _deleteFromCartButton(name: name, cartDoc: cartDoc)
            ],
          ),
        ],
      ),
    );
  }

  Widget _changeQuantityButtons(
      {required int quantity, required DocumentSnapshot cartDoc}) {
    return Flexible(
      flex: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColors.deepCharcoal)),
              child: TextButton(
                  onPressed: quantity == 1
                      ? null
                      : () => changeCartItemQuantity(context, ref,
                          cartEntryDoc: cartDoc, isIncreasing: false),
                  child: quicksandBlackRegular('-', fontSize: 16))),
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColors.deepCharcoal)),
              child: Center(
                child: quicksandBlackRegular(quantity.toString(), fontSize: 15),
              )),
          Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: CustomColors.deepCharcoal)),
              child: TextButton(
                  onPressed: () => changeCartItemQuantity(context, ref,
                      cartEntryDoc: cartDoc, isIncreasing: true),
                  child: quicksandBlackRegular('+', fontSize: 16)))
        ],
      ),
    );
  }

  Widget _deleteFromCartButton(
      {required String name, required DocumentSnapshot cartDoc}) {
    return Flexible(
      flex: 2,
      child: IconButton(
          onPressed: () => displayDeleteEntryDialog(context,
                  message:
                      'Are you sure you wish to remove ${name} from your cart?',
                  deleteEntry: () {
                if (ref
                    .read(cartProvider)
                    .selectedCartItemIDs
                    .contains(cartDoc.id)) {
                  ref.read(cartProvider).deselectCartItem(cartDoc.id);
                }
                removeCartItem(context, ref, cartDoc: cartDoc);
              }),
          icon: Icon(Icons.delete, color: CustomColors.coralRed)),
    );
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

  Widget _requestAdditionalCostButton(
      {required String itemType,
      required bool isRequestingAdditionalService,
      required String cartID}) {
    bool isFurniture =
        itemType == ItemTypes.window || itemType == ItemTypes.door;
    return all20Pix(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
            onPressed: () =>
                requestForAdditionalCosts(context, ref, cartID: cartID),
            child: isFurniture && isRequestingAdditionalService
                ? quicksandWhiteRegular('REQUEST LABOR &\n INSTALLATION COST',
                    fontSize: 12)
                : isFurniture && !isRequestingAdditionalService
                    ? quicksandWhiteRegular('REQUEST LABOR COST', fontSize: 12)
                    : quicksandWhiteRegular('REQUEST DELIVERY COST',
                        fontSize: 12)),
      ),
    );
  }

  void _viewRequestDetailsDialog(BuildContext context,
      {required String address,
      required requestStatus,
      required String contactNumber}) {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    quicksandBlackBold('REQUEST DETAILS', fontSize: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [],
                    )
                  ],
                ),
              ),
            ));
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
        Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
        num additionalServicePrice =
            quotation[QuotationFields.additionalServicePrice] ?? 0;
        totalAmount += additionalServicePrice;
      } else {
        Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
        totalAmount +=
            (quantity * quotation[QuotationFields.itemOverallPrice]) +
                quotation[QuotationFields.laborPrice];
        num additionalServicePrice =
            quotation[QuotationFields.additionalServicePrice] ?? 0;
        totalAmount += additionalServicePrice;
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
