import 'package:flutter/material.dart';
import 'text_widgets.dart';

PreferredSizeWidget appBarWidget({bool mayPop = true, List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: mayPop,
      toolbarHeight: 60,
      elevation: 5,
      centerTitle: true,
      title: itcBaumansDeepNavyBlueBold('iMeasure', fontSize: 20),
      actions: actions);
}
