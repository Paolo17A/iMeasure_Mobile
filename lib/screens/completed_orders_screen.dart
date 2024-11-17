import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/screens/rate_item_screen.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../providers/orders_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class CompletedOrdersScreen extends ConsumerStatefulWidget {
  const CompletedOrdersScreen({super.key});

  @override
  ConsumerState<CompletedOrdersScreen> createState() =>
      _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends ConsumerState<CompletedOrdersScreen> {
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
          return orderData[OrderFields.orderStatus] ==
                  OrderStatuses.completed &&
              review.isNotEmpty;
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
        all10Pix(child: quicksandBlackBold('COMPLETED ORDERS', fontSize: 32)),
        ref.read(ordersProvider).orderDocs.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(ordersProvider).orderDocs.length,
                itemBuilder: (context, index) => _orderEntry(
                    ref.read(ordersProvider).orderDocs.toList()[index]))
            : vertical20Pix(
                child: quicksandBlackBold(
                    'YOU HAVE NOT COMPLETED ANY ORDERS YET.'))
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

    return FutureBuilder(
        future: getThisItemDoc(itemID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);

          final itemData = snapshot.data!.data() as Map<dynamic, dynamic>;
          List<dynamic> imageURLs = itemData[ItemFields.imageURLs];
          String name = itemData[ItemFields.name];
          return Container(
            height: 180,
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 120,
                    height: 140,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(imageURLs.first),
                            fit: BoxFit.cover))),
                Gap(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    quicksandBlackBold(name),
                    quicksandBlackRegular('Quantity: $quantity', fontSize: 14),
                    quicksandBlackRegular(
                        'Date Ordered: ${DateFormat('MMM dd, yyyy').format(dateCreated)}',
                        fontSize: 14),
                    quicksandBlackRegular('Status: $orderStatus', fontSize: 14),
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
                                    builder: (_) =>
                                        RateItemScreen(orderID: orderDoc.id))),
                            child: quicksandWhiteBold('LEAVE REVIEW',
                                fontSize: 12)),
                      ),
                    quicksandBlackBold(
                        'PHP ${formatPrice(itemOverallPrice * quantity.toDouble())}')
                  ],
                )
              ],
            ),
          );
        });
  }
}
