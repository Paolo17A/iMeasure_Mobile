import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/providers/orders_provider.dart';
import 'package:imeasure_mobile/widgets/app_bottom_navbar_widget.dart';

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
      /*floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ElevatedButton(
          onPressed: () {
            FirebaseAuth.instance.signOut().then((value) {
              Navigator.popUntil(context, (route) => route.isFirst);
            });
          },
          child: montserratMidnightBlueBold('LOG-OUT')),*/
      bottomNavigationBar: bottomNavigationBar(context, index: 3),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              children: [
                profileDetails(),
                // /const Divider(color: CustomColors.deepNavyBlue),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                )
                //orderHistory()
              ],
            )),
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: CustomColors.azure, shape: BoxShape.circle),
              child: TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.editProfile),
                  child: Icon(
                    Icons.mode_edit_outline,
                    color: Colors.white,
                  )),
            ),
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  montserratBlackBold(formattedName, fontSize: 22),
                  TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        });
                      },
                      child: quicksandRedBold('LOG-OUT', fontSize: 12))
                ],
              ),
            ),
            Flexible(
              child: TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.orderHistory),
                  child: Icon(
                    Icons.visibility_outlined,
                    color: Colors.black,
                    size: 40,
                  )),
            )
          ],
        )
      ],
    );
  }
}
