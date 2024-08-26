import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import 'text_widgets.dart';

Color bottomNavButtonColor = CustomColors.lavenderMist;

void _processPress(BuildContext context, int selectedIndex, int currentIndex) {
  //  Do nothing if we are selecting the same bottom bar
  if (selectedIndex == currentIndex) {
    return;
  }
  switch (selectedIndex) {
    case 0:
      //Navigator.of(context).pushNamed(NavigatorRoutes.home);
      Navigator.of(context).pushNamedAndRemoveUntil(
          NavigatorRoutes.home, (route) => route is HomeScreen);
      break;
    case 1:
      Navigator.of(context).pushNamed(NavigatorRoutes.windows);
      break;
    case 2:
      Navigator.of(context).pushNamed(NavigatorRoutes.cart);
      break;
    case 3:
      Navigator.of(context).pushNamed(NavigatorRoutes.profile);
      break;
  }
}

Widget bottomNavigationBar(BuildContext context, {required int index}) {
  return Container(
    height: 80,
    decoration:
        BoxDecoration(border: Border.all(color: CustomColors.deepCharcoal)),
    child: BottomNavigationBar(
      currentIndex: index,
      selectedFontSize: 0,
      backgroundColor: bottomNavButtonColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      items: [
        //  Self-Assessment
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.home_outlined, 'HOME', index, 0),
            backgroundColor: bottomNavButtonColor,
            label: ''),
        BottomNavigationBarItem(
            icon: _buildIcon(Icons.window_outlined, 'WINDOWS', index, 1),
            backgroundColor: bottomNavButtonColor,
            label: ''),
        if (hasLoggedInUser())
          BottomNavigationBarItem(
              icon: _buildIcon(Icons.shopping_cart_outlined, 'CART', index, 2),
              backgroundColor: bottomNavButtonColor,
              label: ''),
        if (hasLoggedInUser())
          BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_4_outlined, 'PROFILE', index, 3),
              backgroundColor: bottomNavButtonColor,
              label: '')
      ],
      onTap: (int tappedIndex) {
        _processPress(context, tappedIndex, index);
      },
    ),
  );
}

Widget _buildIcon(
    IconData iconData, String label, int currentIndex, int thisIndex) {
  return Column(
    children: [
      Icon(
        iconData,
        size: currentIndex == thisIndex ? 30 : 20,
        color: currentIndex == thisIndex
            ? CustomColors.emeraldGreen
            : CustomColors.deepCharcoal,
      ),
      currentIndex == thisIndex
          ? quicksandEmeraldGreenBold(label, fontSize: 12)
          : quicksandDeepCharcoalRegular(label, fontSize: 12)
    ],
  );
}
