import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/providers/loading_provider.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:intl/intl.dart';

import '../utils/firebase_util.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/text_widgets.dart';

class SetAppointmentScreen extends ConsumerStatefulWidget {
  const SetAppointmentScreen({super.key});

  @override
  ConsumerState<SetAppointmentScreen> createState() =>
      _SetAppointmentScreenState();
}

class _SetAppointmentScreenState extends ConsumerState<SetAppointmentScreen> {
  List<DateTime> proposedDates = [];
  final streetController = TextEditingController();
  final barangayController = TextEditingController();
  final municipalityController = TextEditingController();
  final zipCodeController = TextEditingController();
  final contactNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(),
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  quicksandBlackBold('SELECT UP TO FIVE APPOINTMENT DATES',
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
                              content: Text(
                                  'You have already selected this date.')));
                          return;
                        }
                        setState(() {
                          proposedDates.add(pickedDate);
                        });
                      },
                      child: quicksandWhiteRegular('ADD A DATE')),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: proposedDates
                          .map((proposedDate) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  quicksandBlackBold(DateFormat('MMM dd, yyy')
                                      .format(proposedDate)),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          proposedDates.remove(proposedDate);
                                        });
                                      },
                                      icon: Icon(Icons.delete,
                                          color: Colors.black))
                                ],
                              ))
                          .toList()),
                  addressGroup(context,
                      streetController: streetController,
                      barangayController: barangayController,
                      municipalityController: municipalityController,
                      zipCodeController: zipCodeController),
                  Gap(20),
                  Row(children: [quicksandBlackBold('Mobile Number')]),
                  CustomTextField(
                      text: 'Contact Number',
                      displayPrefixIcon: null,
                      borderRadius: 4,
                      controller: contactNumberController,
                      textInputType: TextInputType.phone),
                  if (proposedDates.isNotEmpty)
                    vertical20Pix(
                        child: ElevatedButton(
                            onPressed: () => requestForAppointment(context, ref,
                                requestedDates: proposedDates,
                                streetController: streetController,
                                barangayController: barangayController,
                                municipalityController: municipalityController,
                                zipCodeController: zipCodeController,
                                contactNumberController:
                                    contactNumberController),
                            child: quicksandWhiteRegular(
                                'REQUEST FOR AN APPOINTMENT')))
                ],
              )),
            )),
      ),
    );
  }
}
