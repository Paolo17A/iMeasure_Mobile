import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/string_util.dart';

class CartNotifier extends ChangeNotifier {
  List<DocumentSnapshot> cartItems = [];
  List<DocumentSnapshot> windowDocs = [];
  String selectedPaymentMethod = '';
  String selectedCartItem = '';

  void setCartItems(List<DocumentSnapshot> items) {
    cartItems = items;
    notifyListeners();
  }

  void setCartDocs(List<DocumentSnapshot> windows) {
    windowDocs = windows;
    notifyListeners();
  }

  void addCartItem(dynamic item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeCartItem(DocumentSnapshot item) {
    cartItems.remove(item);
    if (item.id == selectedCartItem) {
      setSelectedCartItem('');
    }
    notifyListeners();
  }

  bool cartContainsThisItem(String itemID) {
    return cartItems.any((cartItem) {
      final cartData = cartItem.data() as Map<dynamic, dynamic>;
      return cartData[CartFields.productID] == itemID;
    });
  }

  void setSelectedPaymentMethod(String paymentMethod) {
    selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  void setSelectedCartItem(String cartID) {
    selectedCartItem = cartID;
    notifyListeners();
  }

  DocumentSnapshot? getSelectedCartDoc() {
    return cartItems
        .where((element) => element.id == selectedCartItem)
        .firstOrNull;
  }
}

final cartProvider =
    ChangeNotifierProvider<CartNotifier>((ref) => CartNotifier());
