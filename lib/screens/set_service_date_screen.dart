import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:intl/intl.dart';

import '../widgets/text_widgets.dart';

class SetServiceDateScreen extends ConsumerStatefulWidget {
  final orderID;
  const SetServiceDateScreen({super.key, required this.orderID});

  @override
  ConsumerState<SetServiceDateScreen> createState() =>
      _SetServiceDateScreenState();
}

class _SetServiceDateScreenState extends ConsumerState<SetServiceDateScreen> {
  List<DateTime> proposedDates = [];
  String orderStatus = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final order = await getThisOrderDoc(widget.orderID);
        final orderData = order.data() as Map<dynamic, dynamic>;
        orderStatus = orderData[OrderFields.orderStatus];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting order status: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                quicksandBlackBold(
                    'SELECT UP TO FIVE ${orderStatus == OrderStatuses.pendingDelivery ? 'DELIVERY' : 'INSTALLATION'} DATES',
                    fontSize: 28),
                Gap(20),
                ElevatedButton(
                    onPressed: () async {
                      if (proposedDates.length == 5) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'You can only select a maximum of 5 dates')));
                        return;
                      }
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().add(Duration(days: 1)),
                          lastDate: DateTime.now().add(Duration(days: 14)));
                      if (pickedDate == null) return null;
                      if (proposedDates
                              .where((proposedDate) =>
                                  proposedDate.day == pickedDate.day &&
                                  proposedDate.month == pickedDate.month &&
                                  pickedDate.year == pickedDate.year)
                              .firstOrNull !=
                          null) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('You have already selected this date.')));
                        return;
                      }
                      setState(() {
                        proposedDates.add(pickedDate);
                      });
                    },
                    child: quicksandWhiteRegular('ADD A DATE')),
                Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: proposedDates
                        .map((proposedDate) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                quicksandBlackBold(DateFormat('MMM dd, yyy')
                                    .format(proposedDate)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        proposedDates.remove(proposedDate);
                                      });
                                    },
                                    icon:
                                        Icon(Icons.delete, color: Colors.black))
                              ],
                            ))
                        .toList()),
                if (proposedDates.isNotEmpty)
                  vertical20Pix(
                      child: ElevatedButton(
                          onPressed: () {
                            if (orderStatus == OrderStatuses.pendingDelivery)
                              markOrderAsPendingDeliveryApproval(context, ref,
                                  orderID: widget.orderID,
                                  requestedDates: proposedDates);
                            else
                              markOrderAsPendingInstallationApproval(
                                  context, ref,
                                  orderID: widget.orderID,
                                  requestedDates: proposedDates);
                          },
                          child: quicksandWhiteRegular(
                              'REQUEST FOR ${orderStatus == OrderStatuses.pendingDelivery ? 'DELIVERY' : 'INSTALLATION'}')))
              ],
            )),
          )),
    );
  }
}
