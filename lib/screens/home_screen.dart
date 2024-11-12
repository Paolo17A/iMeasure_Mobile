import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/widgets/app_drawer_widget.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
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
  List<DocumentSnapshot> itemDocs = [];

  //  USER
  List<DocumentSnapshot> testimonialDocs = [];
  List<DocumentSnapshot> portfolioDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);

      final userDoc = await getCurrentUserDoc();
      final userData = userDoc.data() as Map<dynamic, dynamic>;
      ref.read(bookmarksProvider).bookmarkedProducts =
          userData[UserFields.bookmarks];
      testimonialDocs = await getAllTestimonialGalleryDocs();
      testimonialDocs.shuffle();
      portfolioDocs = await getAllPortfolioGalleryDocs();
      portfolioDocs.shuffle();
      itemDocs = await getAllItemDocs();
      itemDocs.shuffle();
      ref.read(loadingProvider.notifier).toggleLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: appBarWidget(mayPop: true),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.home),
        bottomNavigationBar: bottomNavigationBar(context, ref, index: 0),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: Column(
                children: [
                  _gallery(),
                  const Divider(color: Colors.black, thickness: 4),
                  _topProducts(),
                ],
              ),
            )),
      ),
    );
  }

  Widget _gallery() {
    String testimonialURL = '';
    String portfolioURL = '';
    String testimonialURL2 = '';
    String portfolioURL2 = '';

    if (testimonialDocs.isNotEmpty) {
      final testimonialData =
          testimonialDocs.first.data() as Map<dynamic, dynamic>;
      testimonialURL = testimonialData[GalleryFields.imageURL];
      if (testimonialDocs.length > 1) {
        final testimonialData =
            testimonialDocs[1].data() as Map<dynamic, dynamic>;
        testimonialURL2 = testimonialData[GalleryFields.imageURL];
      }
    }
    if (portfolioDocs.isNotEmpty) {
      final portfolioData = portfolioDocs.first.data() as Map<dynamic, dynamic>;
      portfolioURL = portfolioData[GalleryFields.imageURL];
      if (portfolioDocs.length > 1) {
        final portfolioData = portfolioDocs[1].data() as Map<dynamic, dynamic>;
        portfolioURL2 = portfolioData[GalleryFields.imageURL];
      }
    }
    return vertical20Pix(
        child: Column(
      children: [
        if (testimonialURL.isNotEmpty)
          Column(children: [
            quicksandBlackBold('CLIENT TESTIMONIALS', fontSize: 16),
            Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                            content: square80PercentNetworkImage(
                                context, testimonialURL))),
                    child: square150NetworkImage(testimonialURL)),
                if (testimonialDocs.length > 1)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(testimonialURL2))),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                            child: quicksandWhiteBold(
                                '+${testimonialDocs.length}')),
                      ),
                    ),
                  )
              ],
            )
          ]),
        Gap(30),
        if (portfolioURL.isNotEmpty)
          Column(children: [
            quicksandBlackBold('PORTFOLIO', fontSize: 16),
            Gap(4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                            content: square80PercentNetworkImage(
                                context, portfolioURL))),
                    child: square150NetworkImage(portfolioURL)),
                if (portfolioDocs.length > 1)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(portfolioURL2))),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                            child:
                                quicksandWhiteBold('+${portfolioDocs.length}')),
                      ),
                    ),
                  )
              ],
            )
          ]),
      ],
    ));
  }

  Widget _topProducts() {
    itemDocs.shuffle();
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            quicksandBlackBold('PRODUCTS & ITEMS'),
            itemDocs.isNotEmpty
                ? Wrap(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: itemDocs.isNotEmpty
                    //     ? MainAxisAlignment.start
                    //     : MainAxisAlignment.center,

                    children: itemDocs
                        .map((item) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: itemEntry(context, ref, productDoc: item,
                                  onPress: () {
                                final itemData =
                                    item.data() as Map<dynamic, dynamic>;
                                String itemType = itemData[ItemFields.itemType];
                                if (itemType == ItemTypes.window) {
                                  NavigatorRoutes.selectedWindow(context, ref,
                                      windowID: item.id);
                                }
                              }, fontColor: Colors.white),
                            ))
                        .toList())
                : all20Pix(
                    child:
                        quicksandBlackBold('NO AVAILABLE PRODUCTS TO DISPLAY')),
          ],
        ));
  }
}
