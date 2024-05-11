import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/widgets/app_bottom_navbar_widget.dart';
import 'package:imeasure_mobile/widgets/app_drawer_widget.dart';

import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/delete_entry_dialog_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/text_widgets.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(cartProvider).setCartItems(await getCartEntries(context));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting cart entries: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(cartProvider);
    return PopScope(
      onPopInvoked: (didPop) => ref.read(cartProvider).setSelectedCartItem(''),
      child: Scaffold(
        appBar: appBarWidget(),
        drawer: appDrawer(context, route: NavigatorRoutes.cart),
        bottomNavigationBar: bottomNavigationBar(context, index: 2),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(child: _cartEntries()),
            )),
      ),
    );
  }

  Widget _cartEntries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        montserratBlackBold('CART', fontSize: 40),
        ref.read(cartProvider).cartItems.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ref.read(cartProvider).cartItems.length,
                itemBuilder: (context, index) {
                  return _cartEntry(ref.read(cartProvider).cartItems[index]);
                })
            : vertical20Pix(
                child: montserratBlackBold(
                    'YOU DO NOT HAVE ANY ITEMS IN YOUR CART'))
      ],
    );
  }

  Widget _cartEntry(DocumentSnapshot cartDoc) {
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    return FutureBuilder(
        future: getThisWindowDoc(cartData[CartFields.windowID]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError)
            return Container(
                color: CustomColors.lavenderMist,
                height: 60,
                child: snapshotHandler(snapshot));
          final windowData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String name = windowData[WindowFields.name];
          String imageURL = windowData[WindowFields.imageURL];
          bool isAvailable = windowData[WindowFields.isAvailable];
          num minHeight = windowData[WindowFields.minHeight];
          num maxHeight = windowData[WindowFields.maxHeight];
          num minWidth = windowData[WindowFields.minWidth];
          num maxWidth = windowData[WindowFields.maxWidth];

          return vertical10Pix(
              child: Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.horizontal,
            background: Container(
              color: CustomColors.emeraldGreen,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: montserratBlackBold('\t\tPURCHASE')),
            ),
            secondaryBackground: Container(
                color: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.delete, color: Colors.white))),
            dismissThresholds: {
              DismissDirection.endToStart: 0.2,
              DismissDirection.startToEnd: 0.3
            },
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                displayDeleteEntryDialog(context,
                    message:
                        'Are you sure you wish to remove ${name} from your cart?',
                    deleteEntry: () =>
                        removeCartItem(context, ref, cartDoc: cartDoc));
              } else if (direction == DismissDirection.startToEnd) {
                if (isAvailable) {
                  ref.read(cartProvider).setSelectedCartItem(cartDoc.id);
                  Navigator.of(context).pushNamed(NavigatorRoutes.checkout);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('This window is currently not available.')));
                }
              }
              return false;
            },
            child: Container(
                decoration: BoxDecoration(
                    color: CustomColors.lavenderMist, border: Border.all()),
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => NavigatorRoutes.selectedWindow(context, ref,
                          windowID: cartData[CartFields.windowID]),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              backgroundImage: NetworkImage(imageURL),
                              backgroundColor: Colors.transparent,
                              radius: 30),
                          Gap(20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                montserratBlackBold(name,
                                    textAlign: TextAlign.left,
                                    textOverflow: TextOverflow.ellipsis),
                                montserratBlackRegular(
                                    'Width: ${minWidth.toString()} - ${maxWidth.toString()}ft',
                                    fontSize: 12),
                                montserratBlackRegular(
                                    'Height: ${minHeight.toString()} - ${maxHeight.toString()}ft',
                                    fontSize: 12)
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          ));
        });
  }
}
