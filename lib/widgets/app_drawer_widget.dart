import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/providers/profile_image_url_provider.dart';
import 'package:imeasure_mobile/utils/color_util.dart';
import 'package:imeasure_mobile/utils/navigator_util.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';

import 'text_widgets.dart';

Drawer appDrawer(BuildContext context, WidgetRef ref, {required String route}) {
  return Drawer(
    backgroundColor: CustomColors.deepCharcoal,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(children: [
          const Gap(40),
          if (ref.read(profileImageURLProvider).profileImageURL.isNotEmpty)
            all20Pix(
              child: Image.network(
                ref.read(profileImageURLProvider).profileImageURL,
                width: 120,
                height: 120,
                fit: BoxFit.fill,
              ),
            ),
          quicksandWhiteBold(ref.read(profileImageURLProvider).formattedName),
          Divider(),
          _drawerTile(context,
              label: 'HOME',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.home)),
          _drawerTile(context,
              label: 'Set an Appointment',
              onPress: () => Navigator.of(context)
                  .pushNamed(NavigatorRoutes.setAppointment)),
          _drawerTile(context,
              label: 'Contact Us',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.contactUs)),
          _drawerTile(context,
              label: 'FAQs',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.help)),
        ]),
        _drawerTile(context, label: 'Log-Out', onPress: () {
          FirebaseAuth.instance.signOut().then((value) =>
              Navigator.of(context).popUntil((route) => route.isFirst));
        })
      ],
    ),
  );
}

Widget _drawerTile(BuildContext context,
    {required String label, required Function onPress}) {
  return ListTile(
    title: quicksandWhiteBold(label, fontSize: 16),
    onTap: () {
      Navigator.of(context).pop();
      onPress();
    },
  );
}
