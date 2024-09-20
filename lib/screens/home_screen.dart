import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
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
    ref.watch(bookmarksProvider);
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
                  _topProducts(),
                  const Divider(),
                  //bookmarksContainer(),
                  //const Divider(color: CustomColors.deepNavyBlue),
                ],
              )),
            )),
      ),
    );
  }

  Widget _topProducts() {
    itemDocs.shuffle();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        quicksandBlackBold('LATEST WINDOWS', fontSize: 30),
        SizedBox(
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
                        quicksandBlackBold('NO AVAILABLE PRODUCTS TO DISPLAY'),
                  )),
      ],
    );
  }

  Widget bookmarksContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        quicksandBlackBold('BOOKMARKS', fontSize: 30),
        if (ref.read(bookmarksProvider).bookmarkedProducts.isNotEmpty)
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: ref.read(bookmarksProvider).bookmarkedProducts.length,
              itemBuilder: (context, index) {
                return _bookmarkedProductEntry(
                    ref.read(bookmarksProvider).bookmarkedProducts[index]);
              })
        else
          vertical20Pix(
              child: quicksandBlackBold('YOU HAVE NO\nBOOKMARKED ITEMS',
                  fontSize: 16))
      ],
    );
  }

  Widget _bookmarkedProductEntry(String windowID) {
    return FutureBuilder(
        future: getThisItemDoc(windowID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final windowData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String name = windowData[WindowFields.name];
          String imageURL = windowData[WindowFields.imageURL];
          num minHeight = windowData[WindowFields.minHeight];
          num maxHeight = windowData[WindowFields.maxHeight];
          num minWidth = windowData[WindowFields.minWidth];
          num maxWidth = windowData[WindowFields.maxWidth];
          return GestureDetector(
            onTap: () => NavigatorRoutes.selectedWindow(context, ref,
                windowID: windowID),
            child: all10Pix(
                child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                  color: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.delete, color: Colors.white)])),
              dismissThresholds: {DismissDirection.endToStart: 0.2},
              confirmDismiss: (direction) async {
                displayDeleteEntryDialog(context,
                    message:
                        'Are you sure you wish to remove this product from your bookmarks?',
                    deleteEntry: () => removeBookmarkedProduct(context, ref,
                        productID: windowID));
                return false;
              },
              child: Container(
                  decoration: BoxDecoration(
                      color: CustomColors.lavenderMist, border: Border.all()),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              backgroundImage: NetworkImage(imageURL),
                              backgroundColor: Colors.transparent,
                              radius: 30),
                          Gap(20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              quicksandBlackBold(name,
                                  textOverflow: TextOverflow.ellipsis,
                                  fontSize: 16),
                              montserratBlackRegular(
                                  'Width: ${minWidth.toString()} - ${maxWidth.toString()}ft',
                                  fontSize: 12),
                              montserratBlackRegular(
                                  'Height: ${minHeight.toString()} - ${maxHeight.toString()}ft',
                                  fontSize: 12)
                            ],
                          )
                        ],
                      ),
                    ],
                  )),
            )),
          );
        });
  }
}
