import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';

import '../providers/loading_provider.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/item_entry_widget.dart';
import '../widgets/text_widgets.dart';

class WindowsScreen extends ConsumerStatefulWidget {
  const WindowsScreen({super.key});

  @override
  ConsumerState<WindowsScreen> createState() => _WindowsScreenState();
}

class _WindowsScreenState extends ConsumerState<WindowsScreen> {
  List<DocumentSnapshot> allWindowDocs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ref.read(loadingProvider.notifier).toggleLoading(true);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        allWindowDocs = await getAllWindowDocs();

        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all windows: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      drawer: appDrawer(context, route: NavigatorRoutes.windows),
      bottomNavigationBar: bottomNavigationBar(context, index: 1),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [windowsHeader(), _availableWindows()],
            )),
          )),
    );
  }

  Widget windowsHeader() {
    return Row(
        children: [montserratBlackBold('ALL AVAILABLE WINDOWS', fontSize: 24)]);
  }

  Widget _availableWindows() {
    return vertical10Pix(
      child: Column(
        children: [
          allWindowDocs.isNotEmpty
              ? Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 10,
                  runSpacing: 10,
                  children: allWindowDocs.map((item) {
                    return itemEntry(context,
                        productDoc: item,
                        onPress: () => NavigatorRoutes.selectedWindow(
                            context, ref,
                            windowID: item.id));
                  }).toList())
              : montserratBlackBold('NO WINDOWS AVAILABLE', fontSize: 44),
        ],
      ),
    );
  }
}
