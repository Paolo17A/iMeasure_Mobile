import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/screens/order_history_screen.dart';
import 'package:imeasure_mobile/screens/pending_payments_screen.dart';
import 'package:imeasure_mobile/screens/quotation_screen.dart';
import 'package:imeasure_mobile/screens/selected_product_screen.dart';
import 'package:imeasure_mobile/screens/windows_screen.dart';
import '../screens/bookmarks_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/help_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settle_payment_screen.dart';

class NavigatorRoutes {
  static const String home = 'home';
  static const String register = 'register';
  static const String login = 'login';
  static const String forgotPassword = 'forgotPassword';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String windows = 'windows';
  static void selectedWindow(BuildContext context, WidgetRef ref,
      {required String windowID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedWindowScreen(windowID: windowID)));
  }

  static void renterSettlePayment(BuildContext context,
      {required String orderID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SettlePaymentScreen(orderID: orderID)));
  }

  static void quotation(BuildContext context, {required String quotationURL}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => QuotationScreen(quotationURL: quotationURL)));
  }

  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String bookmarks = 'bookmarks';
  static const String help = 'help';
  static const String pendingPayments = 'pendingPayments';
  static const String orderHistory = 'orderHistory';
}

final Map<String, WidgetBuilder> routes = {
  NavigatorRoutes.home: (context) => const HomeScreen(),
  NavigatorRoutes.login: (context) => const LoginScreen(),
  NavigatorRoutes.register: (context) => const RegisterScreen(),
  NavigatorRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  NavigatorRoutes.profile: (context) => const ProfileScreen(),
  NavigatorRoutes.editProfile: (context) => const EditProfileScreen(),
  NavigatorRoutes.windows: (context) => const WindowsScreen(),
  NavigatorRoutes.cart: (context) => const CartScreen(),
  NavigatorRoutes.checkout: (context) => const CheckoutScreen(),
  NavigatorRoutes.bookmarks: (context) => const BookmarksScreen(),
  NavigatorRoutes.help: (context) => const HelpScreen(),
  NavigatorRoutes.pendingPayments: (context) => const PendingPaymentsScreen(),
  NavigatorRoutes.orderHistory: (context) => const OrderHistoryScreen()
};
