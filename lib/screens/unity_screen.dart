import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:imeasure_mobile/utils/firebase_util.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import '../providers/loading_provider.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class UnityScreen extends ConsumerStatefulWidget {
  final String itemID;
  const UnityScreen({super.key, required this.itemID});

  @override
  ConsumerState<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends ConsumerState<UnityScreen> {
  UnityWidgetController? unityWidgetController;
  String itemType = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final item = await getThisItemDoc(widget.itemID);
        final itemData = item.data() as Map<dynamic, dynamic>;
        itemType = itemData[ItemFields.itemType];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ref.read(loadingProvider).toggleLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting user data: $error')));
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            UnityWidget(
              unloadOnDispose: true,
              fullscreen: true,
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage,
            )),
      ),
    );
  }

  void onUnityMessage(message) async {
    print('pressed');
    if (message == 'QUIT') {
      Navigator.of(context).pop();
      return;
    }
    if (message == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No messag founde')));
      Navigator.of(context).pop();
      return;
    }
    String serialized = message.toString();

    Map<dynamic, dynamic> deserializedOutput = await jsonDecode(serialized);
    addFurnitureItemToCartFromUnity(context, ref,
        itemID: widget.itemID,
        itemType: itemType,
        width: deserializedOutput[QuotationFields.width],
        height: deserializedOutput[QuotationFields.height],
        mandatoryMap: deserializedOutput[QuotationFields.mandatoryMap],
        optionalMap: [],
        glassType: deserializedOutput[QuotationFields.glassType],
        color: deserializedOutput[QuotationFields.color],
        itemOverallPrice: deserializedOutput[QuotationFields.itemOverallPrice]);
  }

  void onUnityCreated(controller) async {
    unityWidgetController = controller;
    await unityWidgetController!
        .postMessage("GameManager", "SetItem", widget.itemID);
  }
}
