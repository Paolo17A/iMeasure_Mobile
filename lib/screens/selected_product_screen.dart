import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class SelectedWindowScreen extends ConsumerStatefulWidget {
  final String windowID;
  const SelectedWindowScreen({super.key, required this.windowID});

  @override
  ConsumerState<SelectedWindowScreen> createState() =>
      _SelectedWindowScreenState();
}

class _SelectedWindowScreenState extends ConsumerState<SelectedWindowScreen> {
  //  PRODUCT VARIABLES
  String name = '';
  String description = '';
  bool isAvailable = false;
  num minWidth = 0;
  num maxWidth = 0;
  num minHeight = 0;
  num maxHeight = 0;
  String imageURL = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        //  GET PRODUCT DATA
        final window = await getThisWindowDoc(widget.windowID);
        final windowData = window.data() as Map<dynamic, dynamic>;
        name = windowData[WindowFields.name];
        description = windowData[WindowFields.description];
        isAvailable = windowData[WindowFields.isAvailable];
        imageURL = windowData[WindowFields.imageURL];
        minHeight = windowData[WindowFields.minHeight];
        maxHeight = windowData[WindowFields.maxHeight];
        minWidth = windowData[WindowFields.minWidth];
        maxWidth = windowData[WindowFields.maxWidth];
        //  GET USER DATA
        if (hasLoggedInUser()) {
          final user = await getCurrentUserDoc();
          final userData = user.data() as Map<dynamic, dynamic>;
          ref
              .read(bookmarksProvider)
              .setBookmarkedProducts(userData[UserFields.bookmarks]);

          ref.read(cartProvider).setCartItems(await getCartEntries(context));
        }

        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting selected product: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(bookmarksProvider);
    ref.watch(cartProvider);
    return Scaffold(
      appBar: appBarWidget(),
      bottomNavigationBar: bottomNavigationBar(context, index: 1),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all10Pix(child: _windowsContainer()),
          )),
    );
  }

  Widget _windowsContainer() {
    return Column(
      children: [
        montserratBlackBold(name, fontSize: 32),
        _itemImagesDisplay(),
        //montserratBlackBold('PHP ${price.toStringAsFixed(2)}', fontSize: 20),
        //Divider(color: CustomColors.midnightBlue),
        Gap(20),
        SizedBox(
          height: 40,
          child: ElevatedButton(
              onPressed: isAvailable
                  ? () =>
                      addProductToCart(context, ref, productID: widget.windowID)
                  : null,
              style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  disabledBackgroundColor: Colors.blueGrey),
              child: montserratMidnightBlueRegular('ADD TO CART',
                  textAlign: TextAlign.center)),
        ),
        vertical10Pix(
            child: montserratBlackBold(
                'Is Available: ${isAvailable ? 'YES' : 'NO'}',
                fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () => ref
                        .read(bookmarksProvider)
                        .bookmarkedProducts
                        .contains(widget.windowID)
                    ? removeBookmarkedProduct(context, ref,
                        productID: widget.windowID)
                    : addBookmarkedProduct(context, ref,
                        productID: widget.windowID),
                icon: Icon(ref
                        .read(bookmarksProvider)
                        .bookmarkedProducts
                        .contains(widget.windowID)
                    ? Icons.bookmark
                    : Icons.bookmark_outline)),
            montserratBlackRegular(ref
                    .read(bookmarksProvider)
                    .bookmarkedProducts
                    .contains(widget.windowID)
                ? 'Remove from Bookmarks'
                : 'Add to Bookmarks')
          ],
        ),
        Divider(color: CustomColors.midnightBlue),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          montserratMidnightBlueRegular(
              'Minimum Width: ${minWidth.toString()}ft',
              fontSize: 12),
          Gap(40),
          montserratMidnightBlueRegular(
              'Minimum Height: ${minHeight.toString()}ft',
              fontSize: 12),
        ]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            montserratMidnightBlueRegular(
                'Maximum Width: ${maxWidth.toString()}ft',
                fontSize: 12),
            Gap(40),
            montserratMidnightBlueRegular(
                'Maximum Height: ${maxHeight.toString()}ft',
                fontSize: 12)
          ],
        ),

        vertical20Pix(
            child:
                montserratBlackRegular(description, textAlign: TextAlign.left))
      ],
    );
  }

  Widget _itemImagesDisplay() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
          border: Border.all(),
          image:
              DecorationImage(fit: BoxFit.fill, image: NetworkImage(imageURL))),
    );
  }
}
