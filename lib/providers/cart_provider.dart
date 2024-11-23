import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/string_util.dart';

class CartNotifier extends ChangeNotifier {
  List<DocumentSnapshot> _cartItems = [];
  List<DocumentSnapshot> _noAdditionalCostRequestedCartItems = [];
  List<DocumentSnapshot> _pendingAdditionalCostCartItems = [];
  List<DocumentSnapshot> _forCheckoutCartItems = [];
  //List<DocumentSnapshot> _itemDocs = [];
  String _selectedPaymentMethod = '';
  List<String> _selectedCartItemIDs = [];
  String _selectedGlassType = '';
  String _selectedColor = '';
  File? _proofOfPaymentFile;

  List<DocumentSnapshot> get cartItems => _cartItems;
  List<DocumentSnapshot> get noAdditionalCostRequestedCartItems =>
      _noAdditionalCostRequestedCartItems;
  List<DocumentSnapshot> get pendingAdditionalCostCartItems =>
      _pendingAdditionalCostCartItems;
  List<DocumentSnapshot> get forCheckoutCartItems => _forCheckoutCartItems;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  List<String> get selectedCartItemIDs => _selectedCartItemIDs;
  String get selectedGlassType => _selectedGlassType;
  String get selectedColor => _selectedColor;
  File? get proofOfPaymentFile => _proofOfPaymentFile;

  void setProofOfPaymentFile() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile == null) {
      return;
    }
    _proofOfPaymentFile = File(selectedXFile.path);
    notifyListeners();
  }

  void resetProofOfPaymentFile() async {
    _proofOfPaymentFile = null;
    notifyListeners();
  }

  void setCartItems(List<DocumentSnapshot> items) {
    _cartItems = items;
    updateCartSubLists();
    notifyListeners();
  }

  void updateCartSubLists() {
    _noAdditionalCostRequestedCartItems = _cartItems.where((cart) {
      final cartData = cart.data() as Map<dynamic, dynamic>;
      String itemType = cartData[CartFields.itemType];
      Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
      String requestStatus = quotation[QuotationFields.requestStatus];
      bool isRequestingAdditionalService =
          quotation[QuotationFields.isRequestingAdditionalService];
      bool isFurniture =
          (itemType == ItemTypes.window || itemType == ItemTypes.door);
      return (isFurniture && requestStatus.isEmpty) ||
          (!isFurniture &&
              isRequestingAdditionalService &&
              requestStatus.isEmpty);
    }).toList();

    _pendingAdditionalCostCartItems = _cartItems.where((cart) {
      final cartData = cart.data() as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
      String requestStatus = quotation[QuotationFields.requestStatus];
      return requestStatus == RequestStatuses.pending;
    }).toList();

    _forCheckoutCartItems = _cartItems.where((cart) {
      final cartData = cart.data() as Map<dynamic, dynamic>;
      String itemType = cartData[CartFields.itemType];
      Map<dynamic, dynamic> quotation = cartData[CartFields.quotation];
      String requestStatus = quotation[QuotationFields.requestStatus];
      bool isRequestingAdditionalService =
          quotation[QuotationFields.isRequestingAdditionalService];
      bool isFurniture =
          (itemType == ItemTypes.window || itemType == ItemTypes.door);
      return (isFurniture &&
              (requestStatus == RequestStatuses.approved ||
                  requestStatus == RequestStatuses.denied)) ||
          (!isFurniture && !isRequestingAdditionalService) ||
          (!isFurniture &&
              isRequestingAdditionalService &&
              (requestStatus == RequestStatuses.approved ||
                  requestStatus == RequestStatuses.denied));
    }).toList();
    notifyListeners();
  }

  void addCartItem(dynamic item) {
    cartItems.add(item);
    notifyListeners();
  }

  void removeCartItem(DocumentSnapshot item) {
    _cartItems.remove(item);
    updateCartSubLists();
    notifyListeners();
  }

  bool cartContainsThisItem(String itemID) {
    return cartItems.any((cartItem) {
      final cartData = cartItem.data() as Map<dynamic, dynamic>;
      return cartData[CartFields.itemID] == itemID;
    });
  }

  void setSelectedPaymentMethod(String paymentMethod) {
    _selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  void setSelectedColor(String color) {
    _selectedColor = color;
    notifyListeners();
  }

  void selectCartItem(String item) {
    if (selectedCartItemIDs.contains(item)) return;
    _selectedCartItemIDs.add(item);
    notifyListeners();
  }

  void deselectCartItem(String item) {
    if (!selectedCartItemIDs.contains(item)) return;
    _selectedCartItemIDs.remove(item);
    notifyListeners();
  }

  void setGlassType(String glass) {
    _selectedGlassType = glass;
    notifyListeners();
  }

  void resetSelectedCartItems() {
    _selectedCartItemIDs.clear();
    notifyListeners();
  }
}

final cartProvider =
    ChangeNotifierProvider<CartNotifier>((ref) => CartNotifier());
