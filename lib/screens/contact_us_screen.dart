import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/color_util.dart';
import 'package:imeasure_mobile/widgets/app_bottom_navbar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';
import 'package:imeasure_mobile/widgets/text_widgets.dart';

import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';

class ContactUsScreen extends ConsumerWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBarWidget(mayPop: true),
      drawer: appDrawer(context, ref, route: NavigatorRoutes.help),
      bottomNavigationBar: bottomNavigationBar(context, ref, index: 0),
      body: SingleChildScrollView(
        child: all10Pix(
            child: Column(children: [
          quicksandBlackBold('CONTACT US', fontSize: 28),
          Row(children: [
            Icon(Icons.support_agent_outlined,
                color: CustomColors.emeraldGreen, size: 80),
            all20Pix(
                child: Column(children: [
              quicksandBlackRegular('09985657446'),
              quicksandBlackRegular('09484548667')
            ])),
          ]),
          Gap(20),
          Row(
            children: [
              Icon(Icons.facebook, color: Colors.blue, size: 60),
              Expanded(
                child: all20Pix(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      quicksandBlackBold(
                          'Heritage Aluminum Sales Corporation Los Banos',
                          textAlign: TextAlign.left,
                          fontSize: 16),
                      quicksandBlackRegular('FACEBOOK')
                    ])),
              ),
            ],
          ),
          Gap(20),
          Row(
            children: [
              Icon(Icons.mail, color: CustomColors.emeraldGreen, size: 60),
              Expanded(
                child: all20Pix(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      quicksandBlackBold('heritage.losbanos@gmail.com',
                          textAlign: TextAlign.left, fontSize: 16),
                      quicksandBlackRegular('EMAIL')
                    ])),
              ),
            ],
          ),
          Gap(20),
          Row(
            children: [
              Icon(Icons.home, color: CustomColors.emeraldGreen, size: 60),
              Expanded(
                child: all20Pix(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      quicksandBlackBold(
                          'National Hwy, Los Baños, Philippines, 4030',
                          textAlign: TextAlign.left,
                          fontSize: 16),
                      quicksandBlackRegular('ADDRESS')
                    ])),
              ),
            ],
          ),
        ])),
      ),
    );
  }
}
