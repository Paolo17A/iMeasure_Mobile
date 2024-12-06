import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  List<DocumentSnapshot> transactionDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        transactionDocs = await getAllUserTransactionDocs();
        transactionDocs.sort((a, b) {
          DateTime aTime =
              (a[TransactionFields.dateCreated] as Timestamp).toDate();
          DateTime bTime =
              (b[TransactionFields.dateCreated] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting your transaction history: $error')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: _transactionHistory(),
          )),
    );
  }

  Widget _transactionHistory() {
    return Column(
      children: [
        quicksandBlackBold('TRANSACTION HISTORY', fontSize: 40),
        transactionDocs.isNotEmpty
            ? Column(
                children: transactionDocs
                    .map((transactionDoc) => _transactionEntry(transactionDoc))
                    .toList(),
              )
            : vertical20Pix(
                child: quicksandBlackBold(
                    'You have not yet made any transactions.'))
      ],
    );
  }

  Widget _transactionEntry(DocumentSnapshot transactionDoc) {
    final transactionData = transactionDoc.data() as Map<dynamic, dynamic>;
    String proofOfPayment = transactionData[TransactionFields.proofOfPayment];
    DateTime dateCreated =
        (transactionData[TransactionFields.dateCreated] as Timestamp).toDate();
    DateTime dateApproved =
        (transactionData[TransactionFields.dateApproved] as Timestamp).toDate();
    String transactionStatus =
        transactionData[TransactionFields.transactionStatus];
    num paidAmount = transactionData[TransactionFields.paidAmount];
    String paymentMethod = transactionData[TransactionFields.paymentMethod];
    String denialReason =
        transactionData[TransactionFields.denialReason] ?? 'N/A';
    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 250,
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        padding: EdgeInsets.all(10),
        child: Row(children: [
          GestureDetector(
            onTap: () => showEnlargedPics(context, imageURL: proofOfPayment),
            child: Container(
                width: 150,
                height: 180,
                decoration: BoxDecoration(
                    border: Border.all(),
                    image: DecorationImage(
                        image: NetworkImage(proofOfPayment),
                        fit: BoxFit.cover))),
          ),
          Gap(12),
          SizedBox(
            width: MediaQuery.of(context).size.width - 150 - 20 - 15,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                quicksandBlackBold('Paid Amount: ', fontSize: 15),
                quicksandBlackRegular(
                    'PHP ${formatPrice(paidAmount.toDouble())}',
                    fontSize: 15)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                quicksandBlackBold('Payment Method: ', fontSize: 15),
                quicksandBlackRegular(paymentMethod, fontSize: 15)
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                quicksandBlackBold('Date Created: ', fontSize: 15),
                quicksandBlackRegular(
                    DateFormat('MMM dd, yyyy').format(dateCreated),
                    fontSize: 15)
              ]),
              if (transactionStatus == TransactionStatuses.approved)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  quicksandBlackBold('Date Approved: ', fontSize: 15),
                  quicksandBlackRegular(
                      DateFormat('MMM dd, yyyy').format(dateApproved),
                      fontSize: 15)
                ]),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                quicksandBlackBold('Status:  ', fontSize: 15),
                quicksandBlackRegular(transactionStatus, fontSize: 15)
              ]),
              if (transactionStatus == TransactionStatuses.denied)
                GestureDetector(
                  onTap: denialReason.length > 30
                      ? () => showDialog(
                          context: context,
                          builder: (_) => Dialog(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      quicksandBlackBold('DENIAL REASION'),
                                      quicksandBlackRegular(denialReason)
                                    ],
                                  ),
                                ),
                              ))
                      : null,
                  child: quicksandBlackRegular('Denial Reason: $denialReason',
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      fontSize: 14),
                )
            ]),
          )
        ]));
  }
}
