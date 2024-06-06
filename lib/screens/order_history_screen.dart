import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';

import '../providers/loading_provider.dart';
import '../providers/orders_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
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

        ref.read(ordersProvider).setOrderDocs(await getUserOrderHistory());
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
        all10Pix(child: montserratBlackBold('ORDER HISTORY', fontSize: 32)),
        ref.read(ordersProvider).orderDocs.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    ref.read(ordersProvider).orderDocs.reversed.toList().length,
                itemBuilder: (context, index) {
                  return _orderHistoryEntry(ref
                      .read(ordersProvider)
                      .orderDocs
                      .reversed
                      .toList()[index]);
                })
            : vertical20Pix(
                child: montserratBlackBold('YOU HAVE NOT MADE ANY ORDERS YET.'))
      ],
    );
  }

  Widget _orderHistoryEntry(DocumentSnapshot orderDoc) {
    final orderData = orderDoc.data() as Map<dynamic, dynamic>;
    String status = orderData[OrderFields.purchaseStatus];
    String windowID = orderData[OrderFields.windowID];
    String glassType = orderData[OrderFields.glassType];

    return FutureBuilder(
      future: getThisWindowDoc(windowID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);

        final productData = snapshot.data!.data() as Map<dynamic, dynamic>;
        String imageURL = productData[WindowFields.imageURL];
        String name = productData[WindowFields.name];
        return GestureDetector(
            onTap: () => NavigatorRoutes.selectedWindow(context, ref,
                windowID: windowID),
            child: Container(
              decoration: BoxDecoration(
                  color: CustomColors.lavenderMist, border: Border.all()),
              padding: EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(imageURL, width: 60),
                  Gap(4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      montserratBlackBold(name, fontSize: 15),
                      /*m('SRP: ${price.toStringAsFixed(2)}',
                          fontSize: 15),*/
                      montserratBlackRegular('Glass Type: $glassType',
                          fontSize: 12),
                      montserratBlackRegular('Status: $status', fontSize: 12),
                      /*montserratWhiteBold(
                          'PHP ${(price * quantity).toStringAsFixed(2)}'),*/
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
