import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/providers/orders_provider.dart';
import 'package:imeasure_mobile/widgets/app_bottom_navbar_widget.dart';
import 'package:imeasure_mobile/widgets/custom_button_widgets.dart';

import '../providers/loading_provider.dart';
import '../providers/profile_image_url_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String formattedName = '';

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
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        formattedName =
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
        ref
            .read(profileImageURLProvider)
            .setImageURL(userData[UserFields.profileImageURL]);
        ref.read(ordersProvider).setOrderDocs(await getUserOrderHistory());
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting user profile: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(profileImageURLProvider);
    ref.watch(ordersProvider);
    return Scaffold(
      appBar: appBarWidget(mayPop: false),
      bottomNavigationBar: bottomNavigationBar(context, index: 3),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(children: [
              profileDetails(),
              _actionButtons(),
              _logoutButton()
            ])),
          )),
    );
  }

  Widget profileDetails() {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildProfileImage(
            profileImageURL: ref.read(profileImageURLProvider).profileImageURL,
            radius: MediaQuery.of(context).size.width * 0.15),
        quicksandBlackBold(formattedName, fontSize: 22),
      ],
    );
  }

  Widget _actionButtons() {
    return vertical20Pix(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          roundedLavenderMistButton(
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.editProfile),
              child: quicksandBlackRegular('EDIT PROFILE INFO', fontSize: 12)),
          roundedLavenderMistButton(
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.orderHistory),
              child: quicksandBlackRegular('ORDER HISTORY', fontSize: 12))
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton(
        onPressed: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        },
        style: ElevatedButton.styleFrom(backgroundColor: CustomColors.coralRed),
        child: quicksandWhiteRegular('LOG-OUT', fontSize: 12));
  }
}
