import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/screens/rate_item_screen.dart';
import 'package:imeasure_mobile/screens/set_service_date_screen.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../providers/orders_provider.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        if (!hasLoggedInUser()) {
          navigator.pop();
          return;
        }
        List<DocumentSnapshot> orderDocs = await getUserOrderHistory();
        orderDocs = orderDocs.where((orderDoc) {
          final orderData = orderDoc.data() as Map<dynamic, dynamic>;
          Map<dynamic, dynamic> review = orderData[OrderFields.review];

          return (orderData[OrderFields.orderStatus] !=
                  OrderStatuses.completed) ||
              (orderData[OrderFields.orderStatus] == OrderStatuses.completed &&
                  review.isEmpty);
        }).toList();
        ref.read(ordersProvider).setOrderDocs(orderDocs);
        ref.read(ordersProvider).sortOrdersByDate();
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting user order history: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(ordersProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: switchedLoadingContainer(ref.read(loadingProvider).isLoading,
          SingleChildScrollView(child: orderHistory())),
    );
  }

  Widget orderHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        all10Pix(child: quicksandBlackBold('ORDER HISTORY', fontSize: 32)),
        ref.read(ordersProvider).orderDocs.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    ref.read(ordersProvider).orderDocs.reversed.toList().length,
                itemBuilder: (context, index) => _orderEntry(ref
                    .read(ordersProvider)
                    .orderDocs
                    .reversed
                    .toList()[index]))
            : vertical20Pix(
                child: quicksandBlackBold('YOU HAVE NOT MADE ANY ORDERS YET.'))
      ],
    );
  }

  Widget _orderEntry(DocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<dynamic, dynamic>;
    String itemID = orderData[OrderFields.itemID];
    String orderStatus = orderData[OrderFields.orderStatus];
    num quantity = orderData[OrderFields.quantity];
    DateTime dateCreated =
        (orderData[OrderFields.dateCreated] as Timestamp).toDate();
    Map<dynamic, dynamic> quotation = orderData[OrderFields.quotation];
    num itemOverallPrice = quotation[QuotationFields.itemOverallPrice];
    Map<dynamic, dynamic> review = orderData[OrderFields.review];
    bool isRequestingAdditionalService =
        quotation[QuotationFields.isRequestingAdditionalService] ?? false;
    String requestStatus = quotation[QuotationFields.requestStatus] ?? '';

    String requestAddress = quotation[QuotationFields.requestAddress] ?? '';
    String requestContactNumber =
        quotation[QuotationFields.requestContactNumber] ?? '';
    String requestDenialReason =
        quotation[QuotationFields.requestDenialReason] ?? 'N/A';
    return FutureBuilder(
        future: getThisItemDoc(itemID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);

          final itemData = snapshot.data!.data() as Map<dynamic, dynamic>;
          List<dynamic> imageURLs = itemData[ItemFields.imageURLs];
          String name = itemData[ItemFields.name];
          bool isFurniture =
              itemData[ItemFields.itemType] != ItemTypes.rawMaterial;
          return Stack(
            children: [
              Container(
                //width: 400,
                //height: 220,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                padding: EdgeInsets.all(12),
                child: Row(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 120,
                        height: 140,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: NetworkImage(imageURLs.first),
                                fit: BoxFit.cover))),
                    Gap(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width - 160,
                            child: quicksandBlackBold(name,
                                textAlign: TextAlign.left)),
                        quicksandBlackRegular('Quantity: $quantity',
                            fontSize: 14),
                        quicksandBlackRegular(
                            'Date Ordered: ${DateFormat('MMM dd, yyyy').format(dateCreated)}',
                            fontSize: 14),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 160,
                          child: quicksandBlackRegular('Status: $orderStatus',
                              textAlign: TextAlign.left, fontSize: 14),
                        ),
                        if (isRequestingAdditionalService) ...[
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(),
                                quicksandBlackRegular(
                                    '${isFurniture ? 'Installation' : 'Delivery'} Address: $requestAddress',
                                    textAlign: TextAlign.left,
                                    fontSize: 14),
                                quicksandBlackRegular(
                                    'Contact Number: ${requestContactNumber}',
                                    fontSize: 14),
                                if (requestStatus == RequestStatuses.denied)
                                  GestureDetector(
                                    onTap: requestDenialReason.length > 30
                                        ? () => showDialog(
                                            context: context,
                                            builder: (_) => Dialog(
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        quicksandBlackBold(
                                                            'DENIAL REASION'),
                                                        quicksandBlackRegular(
                                                            requestDenialReason)
                                                      ],
                                                    ),
                                                  ),
                                                ))
                                        : null,
                                    child: quicksandWhiteRegular(
                                        'Denial Reason: $requestDenialReason',
                                        maxLines: 2,
                                        textOverflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        fontSize: 14),
                                  ),
                                Divider(),
                              ],
                            ),
                          )
                        ],
                        if (orderStatus == OrderStatuses.completed &&
                            review.isNotEmpty)
                          Row(children: [
                            quicksandBlackRegular('Rating: ', fontSize: 14),
                            starRating(
                                (review[ReviewFields.rating] as num).toDouble(),
                                onUpdate: (newVal) {},
                                mayMove: false)
                          ])
                        else if (orderStatus == OrderStatuses.completed)
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => RateItemScreen(
                                            orderID: orderDoc.id))),
                                child: quicksandWhiteBold('LEAVE REVIEW',
                                    fontSize: 12)),
                          )
                        else if (orderStatus == OrderStatuses.forPickUp)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              vertical10Pix(
                                child: SizedBox(
                                  height: 24,
                                  child: ElevatedButton(
                                      onPressed: () => markOrderAsPickedUp(
                                          context, ref, orderID: orderDoc.id),
                                      child: quicksandWhiteBold(
                                          'MARK AS PICKED UP',
                                          fontSize: 12)),
                                ),
                              ),
                            ],
                          )
                        else if (orderStatus == OrderStatuses.forPickUp)
                          vertical10Pix(
                              child: SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => markOrderAsPickedUp(
                                    context, ref, orderID: orderDoc.id),
                                child: quicksandWhiteBold('MARK AS PICKED UP',
                                    fontSize: 12)),
                          ))
                        else if (orderStatus == OrderStatuses.forDelivery)
                          vertical10Pix(
                              child: SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => markOrderAsDelivered(
                                    context, ref, orderID: orderDoc.id),
                                child: quicksandWhiteBold('MARK AS DELIVERED',
                                    fontSize: 12)),
                          ))
                        else if (orderStatus == OrderStatuses.forInstallation)
                          vertical10Pix(
                              child: SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => markOrderAsInstalled(
                                    context, ref, orderID: orderDoc.id),
                                child: quicksandWhiteBold('MARK AS INSTALLED',
                                    fontSize: 12)),
                          ))
                        else if (orderStatus == OrderStatuses.pendingDelivery ||
                            orderStatus ==
                                OrderStatuses.pendingInstallation) ...[
                          vertical10Pix(
                              child: SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => SetServiceDateScreen(
                                            orderID: orderDoc.id))),
                                child: quicksandWhiteBold(
                                    'SELECT ${orderStatus == OrderStatuses.pendingDelivery ? 'DELIVERY' : 'INSTALLATION'} DATES',
                                    fontSize: 10)),
                          )),
                          SizedBox(
                            height: 24,
                            child: ElevatedButton(
                                onPressed: () => displayDeleteEntryDialog(
                                    context,
                                    message:
                                        'Are you sure you wish to cancel ${orderStatus == OrderStatuses.pendingDelivery ? 'delivery' : 'installation'} services and pick up your order instead?',
                                    deleteWord: 'Yes',
                                    deleteEntry: () =>
                                        cancelOrderDeliveryService(context, ref,
                                            orderID: orderDoc.id)),
                                child: quicksandWhiteBold(
                                    'CANCEL ${orderStatus == OrderStatuses.pendingDelivery ? 'DELIVERY' : 'INSTALLATION'} SERVICE',
                                    fontSize: 10)),
                          )
                        ],
                        quicksandBlackBold(
                            'PHP ${formatPrice(itemOverallPrice * quantity.toDouble())}')
                      ],
                    )
                  ],
                ),
              ),
              if ((orderStatus == OrderStatuses.forPickUp) ||
                  orderStatus == OrderStatuses.pendingDelivery ||
                  orderStatus == OrderStatuses.pendingInstallation ||
                  orderStatus == OrderStatuses.forDelivery ||
                  orderStatus == OrderStatuses.forInstallation ||
                  (orderStatus == OrderStatuses.completed && review.isEmpty))
                Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ))
            ],
          );
        });
  }
}
