import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class AppointmentHistoryScreen extends ConsumerStatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  ConsumerState<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState
    extends ConsumerState<AppointmentHistoryScreen> {
  List<DocumentSnapshot> appointmentDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        appointmentDocs = await getAllUserAppointments();
        appointmentDocs.sort((a, b) {
          DateTime aTime =
              (a[AppointmentFields.dateCreated] as Timestamp).toDate();
          DateTime bTime =
              (b[AppointmentFields.dateCreated] as Timestamp).toDate();
          return bTime.compareTo(aTime);
        });
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting your appointment history: $error')));
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
            child: Column(
              children: [_appointmentHistory()],
            ),
          )),
    );
  }

  Widget _appointmentHistory() {
    return Column(
      children: [
        vertical20Pix(
            child: quicksandBlackBold('APPOINTMENT HISTORY', fontSize: 32)),
        appointmentDocs.isNotEmpty
            ? Column(
                children: appointmentDocs
                    .map((appointmentDoc) => _appointmentEntry(appointmentDoc))
                    .toList(),
              )
            : vertical20Pix(
                child: quicksandBlackBold(
                    'You have not yet made any appointments.'))
      ],
    );
  }

  Widget _appointmentEntry(DocumentSnapshot appointmentDoc) {
    final appointmentData = appointmentDoc.data() as Map<dynamic, dynamic>;
    List<dynamic> proposedDates =
        appointmentData[AppointmentFields.proposedDates];
    DateTime selectedDate =
        (appointmentData[AppointmentFields.selectedDate] as Timestamp).toDate();
    String appointmentStatus =
        appointmentData[AppointmentFields.appointmentStatus];
    String denialReason = appointmentData[AppointmentFields.denialReason];
    return Container(
        width: MediaQuery.of(context).size.width,
        //height: 150,
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        padding: EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (appointmentStatus == AppointmentStatuses.approved)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              quicksandBlackBold('Selected Date: '),
              quicksandBlackRegular(
                  DateFormat('MMM dd, yyyy').format(selectedDate))
            ])
          else ...[
            quicksandBlackBold('Requested Dates: '),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: proposedDates
                    .map((proposedDate) => quicksandBlackRegular(
                        '\t\t${DateFormat('MMM dd, yyyy').format((proposedDate as Timestamp).toDate())}',
                        textAlign: TextAlign.left))
                    .toList())
          ],
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            quicksandBlackBold('Status: '),
            quicksandBlackRegular(appointmentStatus)
          ]),
          if (appointmentStatus == AppointmentStatuses.denied)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              quicksandBlackBold('Denial Reason: '),
              quicksandBlackRegular(denialReason,
                  textAlign: TextAlign.left,
                  textOverflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  fontSize: 14)
            ])
        ]));
  }
}
