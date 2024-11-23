import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/screens/appointment_history_screen.dart';
import 'package:imeasure_mobile/screens/completed_orders_screen.dart';
import 'package:imeasure_mobile/screens/contact_us_screen.dart';
import 'package:imeasure_mobile/screens/items_screen.dart';
import 'package:imeasure_mobile/screens/order_history_screen.dart';
import 'package:imeasure_mobile/screens/portfolio_screen.dart';
import 'package:imeasure_mobile/screens/quotation_screen.dart';
import 'package:imeasure_mobile/screens/selected_door_screen.dart';
import 'package:imeasure_mobile/screens/selected_raw_material_screen.dart';
import 'package:imeasure_mobile/screens/selected_window_screen.dart';
import 'package:imeasure_mobile/screens/set_appointment_screen.dart';
import 'package:imeasure_mobile/screens/testimonies_screen.dart';
import 'package:imeasure_mobile/screens/transaction_history_screen.dart';
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
  static const String items = 'items';
  static void selectedWindow(BuildContext context, WidgetRef ref,
      {required String windowID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedWindowScreen(windowID: windowID)));
  }

  static void selectedDoor(BuildContext context, WidgetRef ref,
      {required String doorID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SelectedDoorScreen(doorID: doorID)));
  }

  static void selectedRawMaterial(BuildContext context, WidgetRef ref,
      {required String rawMaterialID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SelectedRawMaterialScreen(rawMaterialID: rawMaterialID)));
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
  static const String contactUs = 'contactUs';
  static const String orderHistory = 'orderHistory';
  static const String completedOrders = 'completedOrders';
  static const String testimonies = 'testimonies';
  static const String portfolio = 'portfolio';
  static const String transactionHistory = 'transactionHistory';
  static const String appointmentHistory = 'appointmentHistory';
  static const String setAppointment = 'setAppointment';
}

final Map<String, WidgetBuilder> routes = {
  NavigatorRoutes.home: (context) => const HomeScreen(),
  NavigatorRoutes.login: (context) => const LoginScreen(),
  NavigatorRoutes.register: (context) => const RegisterScreen(),
  NavigatorRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  NavigatorRoutes.profile: (context) => const ProfileScreen(),
  NavigatorRoutes.editProfile: (context) => const EditProfileScreen(),
  NavigatorRoutes.items: (context) => const ItemsScreen(),
  NavigatorRoutes.cart: (context) => const CartScreen(),
  NavigatorRoutes.checkout: (context) => const CheckoutScreen(),
  NavigatorRoutes.bookmarks: (context) => const BookmarksScreen(),
  NavigatorRoutes.help: (context) => const HelpScreen(),
  NavigatorRoutes.contactUs: (context) => const ContactUsScreen(),
  NavigatorRoutes.orderHistory: (context) => const OrderHistoryScreen(),
  NavigatorRoutes.completedOrders: (context) => const CompletedOrdersScreen(),
  NavigatorRoutes.testimonies: (context) => const TestimoniesScreen(),
  NavigatorRoutes.portfolio: (context) => const PortfolioScreen(),
  NavigatorRoutes.transactionHistory: (context) =>
      const TransactionHistoryScreen(),
  NavigatorRoutes.appointmentHistory: (context) =>
      const AppointmentHistoryScreen(),
  NavigatorRoutes.setAppointment: (context) => const SetAppointmentScreen()
};
