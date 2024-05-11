import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:imeasure_mobile/utils/string_util.dart';
import 'text_widgets.dart';

PreferredSizeWidget appBarWidget({bool mayPop = true, List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: mayPop,
      toolbarHeight: 60,
      elevation: 5,
      title: Row(
        children: [
          Image.asset(ImagePaths.heritageIcon, scale: 5),
          const Gap(8),
          if (actions == null)
            itcBaumansDeepNavyBlueBold('iMeasure', fontSize: 20)
        ],
      ),
      actions: actions);
}
