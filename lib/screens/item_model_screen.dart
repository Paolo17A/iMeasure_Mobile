import 'package:flutter/material.dart';
import 'package:imeasure_mobile/utils/color_util.dart';
import 'package:imeasure_mobile/widgets/app_bar_widget.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ItemModelScreen extends StatelessWidget {
  final String modelPath;
  const ItemModelScreen({super.key, required this.modelPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(),
      body: ModelViewer(
        src: modelPath,
        autoRotate: true,
        backgroundColor: CustomColors.lavenderMist,
      ),
    );
  }
}
