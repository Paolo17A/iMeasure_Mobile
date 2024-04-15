import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
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
                  _topProducts(),
                  const Divider(color: CustomColors.midnightBlue),
                ],
              )),
            )),
      ),
    );
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
