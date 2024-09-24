import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';

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
  List<DocumentSnapshot> serviceDocs = [];
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
      serviceDocs = await getAllServiceGalleryDocs();
      serviceDocs.shuffle();
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
        appBar: appBarWidget(mayPop: false),
        bottomNavigationBar: bottomNavigationBar(context, index: 0),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  _gallery(),
                  const Divider(color: Colors.black, thickness: 4),
                  _topProducts(),
                ],
              )),
            )),
      ),
    );
  }

  Widget _gallery() {
    String serviceURL = '';
    String testimonialURL = '';
    String portfolioURL = '';
    if (serviceDocs.isNotEmpty) {
      final serviceData = serviceDocs.first.data() as Map<dynamic, dynamic>;
      serviceURL = serviceData[GalleryFields.imageURL];
    }
    if (testimonialDocs.isNotEmpty) {
      final testimonialData =
          testimonialDocs.first.data() as Map<dynamic, dynamic>;
      testimonialURL = testimonialData[GalleryFields.imageURL];
    }
    if (portfolioDocs.isNotEmpty) {
      final portfolioData = portfolioDocs.first.data() as Map<dynamic, dynamic>;
      portfolioURL = portfolioData[GalleryFields.imageURL];
    }
    return vertical20Pix(
        child: Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          if (serviceURL.isNotEmpty)
            Column(children: [
              quicksandBlackBold('SERVICES', fontSize: 12),
              Gap(4),
              square100NetworkImage(serviceURL)
            ]),
          if (testimonialURL.isNotEmpty)
            Column(children: [
              quicksandBlackBold('CLIENT TESTIMONIALS', fontSize: 12),
              Gap(4),
              square100NetworkImage(testimonialURL)
            ]),
        ]),
        Gap(30),
        if (portfolioURL.isNotEmpty)
          Column(children: [
            quicksandBlackBold('PORTFOLIO', fontSize: 12),
            Gap(4),
            square300NetworkImage(portfolioURL)
          ]),
      ],
    ));
  }

  Widget _topProducts() {
    itemDocs.shuffle();
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: itemDocs.isNotEmpty
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: itemDocs.isNotEmpty
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: itemDocs.reversed
                        .take(6)
                        .toList()
                        .map((item) => Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: itemEntry(context, productDoc: item,
                                      onPress: () {
                                    final itemData =
                                        item.data() as Map<dynamic, dynamic>;
                                    String itemType =
                                        itemData[ItemFields.itemType];
                                    if (itemType == ItemTypes.window) {
                                      NavigatorRoutes.selectedWindow(
                                          context, ref,
                                          windowID: item.id);
                                    }
                                  }, fontColor: Colors.white),
                                ),
                              ],
                            ))
                        .toList()))
            : all20Pix(
                child: quicksandBlackBold('NO AVAILABLE PRODUCTS TO DISPLAY'),
              ));
  }
}
