import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';

import '../providers/loading_provider.dart';
import '../providers/settle_payment_provider.dart';
import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/item_entry_widget.dart';
import '../widgets/text_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<DocumentSnapshot> windowDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);

      windowDocs = await getAllWindowDocs();

      ref.read(loadingProvider.notifier).toggleLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: appBarWidget(),
        drawer: appDrawer(context, route: NavigatorRoutes.home),
        bottomNavigationBar: bottomNavigationBar(context, index: 0),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _pendingPaymentRentalRequestsContainer(),
                  _topProducts(),
                  const Divider(color: CustomColors.midnightBlue),
                ],
              )),
            )),
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
            ? ExpansionTile(
                title: montserratWhiteBold('PENDING PAYMENTS'),
                backgroundColor: CustomColors.slateBlue,
                collapsedBackgroundColor: CustomColors.slateBlue,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableRentalRequests.length,
                      itemBuilder: (context, index) {
                        return pendingOrderEntry(
                            availableRentalRequests[index]);
                      })
                ],
              )
            : Container();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: CustomColors.midnightBlue)),
                      child: Image.network(
                        windowImage,
                        height: 100,
                        fit: BoxFit.cover,
                      )),
                ),
                Gap(10),
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      montserratWhiteBold(windowName),
                      montserratWhiteRegular(
                          'Total: PHP ${formatPrice(totalPrice.toDouble())}',
                          fontSize: 16),
                      Gap(21),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                ref.read(settlePaymentProvider).resetProvider();
                                NavigatorRoutes.renterSettlePayment(context,
                                    orderID: orderDoc.id);
                              },
                              child: montserratMidnightBlueBold(
                                  'SETTLE PAYMENT',
                                  fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _topProducts() {
    windowDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        all20Pix(child: montserratBlackBold('LATEST WINDOWS', fontSize: 26)),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: windowDocs.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: windowDocs.isNotEmpty
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.center,
                        children: windowDocs.reversed
                            .take(6)
                            .toList()
                            .map((item) => Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: itemEntry(context,
                                          productDoc: item,
                                          onPress: () =>
                                              NavigatorRoutes.selectedWindow(
                                                  context, ref,
                                                  windowID: item.id),
                                          fontColor: Colors.white),
                                    ),
                                  ],
                                ))
                            .toList()))
                : all20Pix(
                    child:
                        montserratBlackBold('NO AVAILABLE PRODUCTS TO DISPLAY'),
                  )),
      ],
    );
  }
}
