import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';

import '../providers/settle_payment_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/text_widgets.dart';

class PendingPaymentsScreen extends ConsumerStatefulWidget {
  const PendingPaymentsScreen({super.key});

  @override
  ConsumerState<PendingPaymentsScreen> createState() =>
      _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends ConsumerState<PendingPaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(),
      bottomNavigationBar: bottomNavigationBar(context, index: 2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            montserratBlackBold('PENDING PAYMENTS', fontSize: 32),
            _pendingPaymentRentalRequestsContainer()
          ],
        ),
      ),
    );
  }

  Widget _pendingPaymentRentalRequestsContainer() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Collections.orders)
          .where(OrderFields.purchaseStatus, isEqualTo: OrderStatuses.pending)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);
        List<DocumentSnapshot> availableRentalRequests = snapshot.data!.docs;
        return availableRentalRequests.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: availableRentalRequests.length,
                itemBuilder: (context, index) {
                  return pendingOrderEntry(availableRentalRequests[index]);
                })
            : vertical20Pix(child: montserratBlackBold('NO PENDING PAYMENTS'));
      },
    );
  }

  Widget pendingOrderEntry(DocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<dynamic, dynamic>;
    String windowID = orderData[OrderFields.windowID];
    num totalPrice = orderData[OrderFields.windowOverallPrice] +
        orderData[OrderFields.laborPrice];
    return FutureBuilder(
        future: getThisWindowDoc(windowID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final windowData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String windowName = windowData[WindowFields.name];
          String windowImage = windowData[WindowFields.imageURL];
          return Container(
            decoration: BoxDecoration(border: Border.all()),
            padding: EdgeInsets.all(10),
            child: Row(
              //crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Image.network(
                        windowImage,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Gap(10),
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          montserratBlackBold(windowName),
                          montserratBlackRegular(
                              'Total: PHP ${formatPrice(totalPrice.toDouble())}',
                              fontSize: 16),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                    onPressed: () {
                      ref.read(settlePaymentProvider).resetProvider();
                      NavigatorRoutes.renterSettlePayment(context,
                          orderID: orderDoc.id);
                    },
                    child: montserratMidnightBlueBold('SETTLE\nPAYMENT',
                        fontSize: 12))
              ],
            ),
          );
        });
  }
}
