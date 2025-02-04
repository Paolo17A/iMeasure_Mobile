import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/navigator_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:imeasure_mobile/widgets/app_drawer_widget.dart';
import 'package:imeasure_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:imeasure_mobile/widgets/custom_padding_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/text_widgets.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  List<DocumentSnapshot> itemDocs = [];
  List<DocumentSnapshot> filteredDocs = [];
  String currentItemType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        itemDocs = await getAllItemDocs();
        filterDocsByItemType();
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting item docs: $error')));
      }
    });
  }

  void filterDocsByItemType() {
    if (currentItemType.isEmpty) {
      setState(() {
        filteredDocs = itemDocs;
      });
      return;
    }
    setState(() {
      filteredDocs = itemDocs.where((itemDoc) {
        final itemData = itemDoc.data() as Map<dynamic, dynamic>;
        return itemData[ItemFields.itemType] == currentItemType;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
        appBar: appBarWidget(mayPop: true),
        drawer: appDrawer(context, ref, route: ''),
        bottomNavigationBar: bottomNavigationBar(context, ref, index: 1),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            Column(
              children: [
                itemTypeNavigator(context),
                Divider(),
                filteredItemEntriesDisplay()
              ],
            )));
  }

  Widget itemTypeNavigator(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            itemButton(context, label: 'ALL', itemType: ''),
            itemButton(context, label: 'WINDOWS', itemType: ItemTypes.window),
            itemButton(context, label: 'DOORS', itemType: ItemTypes.door),
            itemButton(context,
                label: 'RAW MATERIALS', itemType: ItemTypes.rawMaterial),
          ],
        ),
      ),
    );
  }

  Widget itemButton(BuildContext context,
      {required String label, required String itemType}) {
    return all10Pix(
      child: ElevatedButton(
          onPressed: () {
            setState(() {
              currentItemType = itemType;
            });
            filterDocsByItemType();
          },
          child: itemType == currentItemType
              ? quicksandEmeraldGreenBold(label, fontSize: 10)
              : quicksandWhiteBold(label, fontSize: 10)),
    );
  }

  Widget filteredItemEntriesDisplay() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 270,
      //decoration: BoxDecoration(border: Border.all()),
      child: filteredDocs.isNotEmpty
          ? SingleChildScrollView(
              child: Wrap(
              spacing: 20,
              runSpacing: 20,
              children: filteredDocs
                  .map((itemDoc) => _filteredItemEntry(itemDoc))
                  .toList(),
            ))
          : Center(
              child: quicksandBlackBold('NO ITEMS AVAILABLE', fontSize: 28)),
    );
  }

  Widget _filteredItemEntry(DocumentSnapshot itemDoc) {
    final itemData = itemDoc.data() as Map<dynamic, dynamic>;
    List<dynamic> imageURLs = itemData[ItemFields.imageURLs];
    String name = itemData[ItemFields.name];
    String itemType = itemData[ItemFields.itemType];
    return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          GestureDetector(
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                      content: square80PercentNetworkImage(
                          context, imageURLs.first))),
              child: square150NetworkImage(imageURLs.first)),
          vertical10Pix(
              child: quicksandBlackBold(name,
                  textOverflow: TextOverflow.ellipsis)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (itemType == ItemTypes.window) {
                      NavigatorRoutes.selectedWindow(context, ref,
                          windowID: itemDoc.id);
                    } else if (itemType == ItemTypes.door) {
                      NavigatorRoutes.selectedDoor(context, ref,
                          doorID: itemDoc.id);
                    } else if (itemType == ItemTypes.rawMaterial) {
                      NavigatorRoutes.selectedRawMaterial(context, ref,
                          rawMaterialID: itemDoc.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Icon(Icons.visibility_outlined, size: 20)),
            ],
          )
        ],
      ),
    );
  }
}
