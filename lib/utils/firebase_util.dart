// ignore_for_file: unnecessary_cast

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/bookmarks_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/loading_provider.dart';

import '../providers/orders_provider.dart';
import '../providers/profile_image_url_provider.dart';
import 'navigator_util.dart';
import 'quotation_dialog_util.dart';
import 'string_util.dart';

//==============================================================================
//USERS=========================================================================
//==============================================================================
bool hasLoggedInUser() {
  return FirebaseAuth.instance.currentUser != null;
}

Future registerNewUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController mobileNumberController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        mobileNumberController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please input a valid email address')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('The passwords do not match')));
      return;
    }
    if (passwordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('The password must be at least six characters long')));
      return;
    }
    if (mobileNumberController.text.length != 11 ||
        mobileNumberController.text[0] != '0' ||
        mobileNumberController.text[1] != '9') {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text(
              'The mobile number must be an 11 digit number formatted as: 09XXXXXXXXX')));
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), password: passwordController.text);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      UserFields.email: emailController.text.trim(),
      UserFields.password: passwordController.text,
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.mobileNumber: mobileNumberController.text,
      UserFields.userType: UserTypes.client,
      UserFields.profileImageURL: '',
      UserFields.bookmarks: []
    });
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    await FirebaseAuth.instance.signOut();
    ref.read(loadingProvider.notifier).toggleLoading(false);

    navigator.pushReplacementNamed(NavigatorRoutes.login);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error registering new user: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future logInUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;

    //  reset the password in firebase in case client reset it using an email link.
    if (userData[UserFields.userType] == UserTypes.admin) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('This log-in is for clients only.')));
      ref.read(loadingProvider).toggleLoading(false);
      return;
    }
    if (userData[UserFields.password] != passwordController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.password: passwordController.text});
    }
    if (userData[UserFields.email] != emailController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.email: emailController.text});
    }
    ref
        .read(profileImageURLProvider)
        .setImageURL(userData[UserFields.profileImageURL]);
    ref.read(profileImageURLProvider).setFormattedName(
        '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}');
    ref.read(loadingProvider.notifier).toggleLoading(false);
    emailController.clear();
    passwordController.clear();
    navigator.pushNamed(NavigatorRoutes.home);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Incorrect login credentials')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future sendResetPasswordEmail(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (!emailController.text.contains('@') ||
      !emailController.text.contains('.com')) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please input a valid email address.')));
    return;
  }
  try {
    FocusScope.of(context).unfocus();
    ref.read(loadingProvider.notifier).toggleLoading(true);
    final filteredUsers = await FirebaseFirestore.instance
        .collection(Collections.users)
        .where(UserFields.email, isEqualTo: emailController.text.trim())
        .get();

    if (filteredUsers.docs.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('There is no user with that email address.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    if (filteredUsers.docs.first.data()[UserFields.userType] !=
        UserTypes.client) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('This feature is for clients only.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
    ref.read(loadingProvider.notifier).toggleLoading(false);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully sent password reset email!')));
    navigator.pop();
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future<DocumentSnapshot> getCurrentUserDoc() async {
  return await getThisUserDoc(FirebaseAuth.instance.currentUser!.uid);
}

Future<String> getCurrentUserType() async {
  final userDoc = await getCurrentUserDoc();
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  return userData[UserFields.userType];
}

Future<DocumentSnapshot> getThisUserDoc(String userID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.users)
      .doc(userID)
      .get();
}

Future<List<DocumentSnapshot>> getAllClientDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.client)
      .get();
  return users.docs;
}

Future editClientProfile(BuildContext context, WidgetRef ref,
    {required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController mobileNumberController,
    required TextEditingController addressController,
    required TextEditingController emailAddressController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      mobileNumberController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please fill up all given fields.')));
    return;
  }
  if (mobileNumberController.text.length != 11 ||
      mobileNumberController.text[0] != '0' ||
      mobileNumberController.text[1] != '9') {
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text(
            'The mobile number must be an 11 digit number formatted as: 09XXXXXXXXX')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.address: addressController.text.trim(),
      UserFields.mobileNumber: mobileNumberController.text.trim()
    });
    ref.read(profileImageURLProvider).setFormattedName(
        '${firstNameController.text.trim()} ${lastNameController.text.trim()}');
    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    if (emailAddressController.text != userData[UserFields.email]) {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userData[UserFields.email],
          password: userData[UserFields.password]);
      await FirebaseAuth.instance.currentUser!
          .verifyBeforeUpdateEmail(emailAddressController.text.trim());

      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(
              'A verification email has been sent to the new email address')));
    }
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pop();
    navigator.pushReplacementNamed(NavigatorRoutes.profile);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error editing client profile : $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future uploadProfilePicture(BuildContext context, WidgetRef ref) async {
  try {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile == null) {
      return;
    }
    //  Upload proof of employment to Firebase Storage
    ref.read(loadingProvider).toggleLoading(true);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child(FirebaseAuth.instance.currentUser!.uid);
    final uploadTask = storageRef.putFile(File(selectedXFile.path));
    final taskSnapshot = await uploadTask;
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: downloadURL});
    ref.read(profileImageURLProvider).setImageURL(downloadURL);
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading new profile picture: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<void> removeProfilePic(BuildContext context, WidgetRef ref) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: ''});

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child(FirebaseAuth.instance.currentUser!.uid);

    await storageRef.delete();
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully removed profile picture.')));
    ref.read(profileImageURLProvider).removeImageURL();
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing current profile pic: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future addBookmarkedProduct(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    if (!hasLoggedInUser()) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please log-in to your account first.')));
      return;
    }
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.bookmarks: FieldValue.arrayUnion([productID])
    });
    ref.read(bookmarksProvider).addProductToBookmarks(productID);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Sucessfully added product to bookmarks.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to bookmarks: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future removeBookmarkedProduct(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    if (!hasLoggedInUser()) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please log-in to your account first.')));
      return;
    }
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.bookmarks: FieldValue.arrayRemove([productID])
    });
    ref.read(bookmarksProvider).removeProductFromBookmarks(productID);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Sucessfully removed product from bookmarks.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing product to bookmarks: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

//==============================================================================
//ITEMS=========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllItemDocs() async {
  final items =
      await FirebaseFirestore.instance.collection(Collections.items).get();
  return items.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getSelectedItemDocs(
    List<dynamic> itemIDs) async {
  if (itemIDs.isEmpty) return [];
  final items = await FirebaseFirestore.instance
      .collection(Collections.items)
      .where(FieldPath.documentId, whereIn: itemIDs)
      .get();
  return items.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllWindowDocs() async {
  final items = await FirebaseFirestore.instance
      .collection(Collections.items)
      .where(ItemFields.itemType, isEqualTo: ItemTypes.window)
      .get();
  return items.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllDoorDocs() async {
  final items = await FirebaseFirestore.instance
      .collection(Collections.items)
      .where(ItemFields.itemType, isEqualTo: ItemTypes.door)
      .get();
  return items.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllRawMaterialDocs() async {
  final items = await FirebaseFirestore.instance
      .collection(Collections.items)
      .where(ItemFields.itemType, isEqualTo: ItemTypes.rawMaterial)
      .get();
  return items.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisItemDoc(String itemID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.items)
      .doc(itemID)
      .get();
}

//==============================================================================
//==CART========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getCartEntries(BuildContext context) async {
  final cartProducts = await FirebaseFirestore.instance
      .collection(Collections.cart)
      .where(CartFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return cartProducts.docs.map((doc) => doc as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisCartEntry(String cartID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.cart)
      .doc(cartID)
      .get();
}

Future addFurnitureItemToCart(BuildContext context, WidgetRef ref,
    {required String itemID,
    required String itemType,
    required double width,
    required double height,
    required List<dynamic> mandatoryWindowFields,
    required List<dynamic> optionalWindowFields}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (!hasLoggedInUser()) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please log-in to your account first.')));
    return;
  }
  try {
    List<Map<dynamic, dynamic>> mandatoryMap = [];
    if (itemType == ItemTypes.window) {
      mandatoryMap.add({
        OrderBreakdownMap.field: 'Glass',
        OrderBreakdownMap.breakdownPrice: calculateGlassPrice(ref,
            width: width.toDouble(), height: height.toDouble())
      });
    }

    for (var windowSubField in mandatoryWindowFields) {
      if (windowSubField[WindowSubfields.priceBasis] == 'HEIGHT') {
        switch (ref.read(cartProvider).selectedColor) {
          case WindowColors.brown:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.brownPrice] / 21) * height
            });
            break;
          case WindowColors.white:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.whitePrice] / 21) * height
            });
            break;
          case WindowColors.mattBlack:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.mattBlackPrice] / 21) * height
            });
            break;
          case WindowColors.mattGray:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.mattGrayPrice] / 21) * height
            });
            break;
          case WindowColors.woodFinish:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.woodFinishPrice] / 21) *
                      height
            });
            break;
        }
      } else if (windowSubField[WindowSubfields.priceBasis] == 'WIDTH') {
        switch (ref.read(cartProvider).selectedColor) {
          case WindowColors.brown:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.brownPrice] / 21) * width
            });
            break;
          case WindowColors.white:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.whitePrice] / 21) * width
            });
            break;
          case WindowColors.mattBlack:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.mattBlackPrice] / 21) * width
            });
            break;
          case WindowColors.mattGray:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.mattGrayPrice] / 21) * width
            });
            break;
          case WindowColors.woodFinish:
            mandatoryMap.add({
              OrderBreakdownMap.field: windowSubField[WindowSubfields.name],
              OrderBreakdownMap.breakdownPrice:
                  (windowSubField[WindowSubfields.woodFinishPrice] / 21) * width
            });
            break;
        }
      }
    }

    List<Map<dynamic, dynamic>> optionalMap = [];
    for (var windowSubField in optionalWindowFields) {
      if (windowSubField[OptionalWindowFields.isSelected]) {
        optionalMap.add({
          OrderBreakdownMap.field:
              windowSubField[OptionalWindowFields.optionalFields]
                  [WindowFields.name],
          OrderBreakdownMap.breakdownPrice:
              windowSubField[OptionalWindowFields.price]
        });
      }
    }

    await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.itemID: itemID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1,
      CartFields.itemType: itemType,
      CartFields.quotation: {
        QuotationFields.width: width,
        QuotationFields.height: height,
        QuotationFields.glassType: ref.read(cartProvider).selectedGlassType,
        QuotationFields.color: ref.read(cartProvider).selectedColor,
        QuotationFields.mandatoryMap: mandatoryMap,
        QuotationFields.optionalMap: optionalMap,
        QuotationFields.itemOverallPrice:
            calculateGlassPrice(ref, width: width, height: height) +
                calculateTotalMandatoryPayment(ref,
                    width: width,
                    height: height,
                    mandatoryWindowFields: mandatoryWindowFields) +
                calculateOptionalPrice(optionalWindowFields),
        QuotationFields.laborPrice: 0,
        QuotationFields.quotationURL: ''
      }
    });

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added this item to your cart.')));
  } catch (error) {
    ref.read(loadingProvider).toggleLoading(false);
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to cart: $error')));
  }
}

Future addFurnitureItemToCartFromUnity(BuildContext context, WidgetRef ref,
    {required String itemID,
    required String itemType,
    required double width,
    required double height,
    required String glassType,
    required String color,
    required List<dynamic> mandatoryMap,
    required List<dynamic> optionalMap,
    required double itemOverallPrice}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.itemID: itemID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1,
      CartFields.itemType: itemType,
      CartFields.quotation: {
        QuotationFields.width: width,
        QuotationFields.height: height,
        QuotationFields.glassType: glassType,
        QuotationFields.color: color,
        QuotationFields.mandatoryMap: mandatoryMap,
        QuotationFields.optionalMap: optionalMap,
        QuotationFields.itemOverallPrice: itemOverallPrice,
        QuotationFields.laborPrice: 0,
        QuotationFields.quotationURL: ''
      }
    });

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added this item to your cart.')));
  } catch (error) {
    ref.read(loadingProvider).toggleLoading(false);
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to cart: $error')));
  }
}

Future addRawMaterialToCart(BuildContext context, WidgetRef ref,
    {required String itemID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    if (ref.read(cartProvider).cartContainsThisItem(itemID)) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('This item is already in your cart.')));
      return;
    }
    final cartDocReference =
        await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.itemID: itemID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      CartFields.quantity: 1,
      CartFields.itemType: ItemTypes.rawMaterial
    });
    ref.read(cartProvider.notifier).addCartItem(await cartDocReference.get());
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Successfully added raw material to cart.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding raw material to cart: $error')));
  }
}

void removeCartItem(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot cartDoc}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    await cartDoc.reference.delete();

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully removed this item from your cart.')));
    ref.read(cartProvider).removeCartItem(cartDoc);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future changeCartItemQuantity(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot cartEntryDoc,
    required bool isIncreasing}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    final cartEntryData = cartEntryDoc.data() as Map<dynamic, dynamic>;
    int quantity = cartEntryData[CartFields.quantity];
    if (isIncreasing) {
      quantity++;
    } else {
      quantity--;
    }
    await FirebaseFirestore.instance
        .collection(Collections.cart)
        .doc(cartEntryDoc.id)
        .update({CartFields.quantity: quantity});
    ref.read(cartProvider).setCartItems(await getCartEntries(context));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error changing item quantity: $error')));
  }
}

//==============================================================================
//==FAQS========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllFAQs() async {
  final faqs =
      await FirebaseFirestore.instance.collection(Collections.faqs).get();
  return faqs.docs;
}

Future<DocumentSnapshot> getThisFAQDoc(String faqID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.faqs)
      .doc(faqID)
      .get();
}

//==============================================================================
//==ORDERS======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllOrderDocs() async {
  final orders =
      await FirebaseFirestore.instance.collection(Collections.orders).get();
  return orders.docs.reversed.toList();
}

Future<List<DocumentSnapshot>> getAllItemOrderDocs(String itemID) async {
  final orders = await FirebaseFirestore.instance
      .collection(Collections.orders)
      .where(OrderFields.itemID, isEqualTo: itemID)
      .get();
  return orders.docs.map((order) => order as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisOrderDoc(String orderID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.orders)
      .doc(orderID)
      .get();
}

Future<List<DocumentSnapshot>> getUserOrderHistory() async {
  final orders = await FirebaseFirestore.instance
      .collection(Collections.orders)
      .where(OrderFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return orders.docs.reversed
      .map((order) => order as DocumentSnapshot)
      .toList();
}

Future<List<DocumentSnapshot>> getUserPendingPickUpOrderHistory() async {
  final orders = await FirebaseFirestore.instance
      .collection(Collections.orders)
      .where(OrderFields.clientID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where(OrderFields.orderStatus, isEqualTo: OrderStatuses.forPickUp)
      .get();
  return orders.docs.reversed
      .map((order) => order as DocumentSnapshot)
      .toList();
}

Future purchaseSelectedCartItems(BuildContext context, WidgetRef ref,
    {required num paidAmount}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    //  1. Generate a purchase document for the selected cart item
    List<String> orderIDs = [];
    for (var cartItem in ref.read(cartProvider).selectedCartItemIDs) {
      final cartDoc = await getThisCartEntry(cartItem);
      final cartData = cartDoc.data() as Map<dynamic, dynamic>;
      Map<dynamic, dynamic> quotation = {};
      num price = 0;
      if (cartData[CartFields.itemType] != ItemTypes.rawMaterial) {
        quotation = cartData[CartFields.quotation];
        quotation[QuotationFields.laborPrice] = 0;
      } else {
        String itemID = cartData[CartFields.itemID];
        final item = await getThisItemDoc(itemID);
        final itemData = item.data() as Map<dynamic, dynamic>;
        price = itemData[ItemFields.price];
      }

      DocumentReference orderReference =
          await FirebaseFirestore.instance.collection(Collections.orders).add({
        OrderFields.itemID: cartData[CartFields.itemID],
        OrderFields.clientID: cartData[CartFields.clientID],
        OrderFields.quantity: cartData[CartFields.quantity],
        OrderFields.orderStatus: OrderStatuses.pending,
        OrderFields.dateCreated: DateTime.now(),
        OrderFields.quotation:
            cartData[CartFields.itemType] != ItemTypes.rawMaterial
                ? quotation
                : {QuotationFields.itemOverallPrice: price},
        OrderFields.review: {}
      });

      orderIDs.add(orderReference.id);

      await FirebaseFirestore.instance
          .collection(Collections.cart)
          .doc(cartItem)
          .delete();
    }

    //  2. Generate a payment document in Firestore
    DocumentReference transactionReference = await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .add({
      TransactionFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      TransactionFields.paidAmount: paidAmount,
      TransactionFields.paymentVerified: false,
      TransactionFields.transactionStatus: TransactionStatuses.pending,
      TransactionFields.paymentMethod:
          ref.read(cartProvider).selectedPaymentMethod,
      TransactionFields.dateCreated: DateTime.now(),
      TransactionFields.dateApproved: DateTime(1970),
      TransactionFields.orderIDs: orderIDs
    });

    //  2. Upload the proof of payment image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${transactionReference.id}.png');
    final uploadTask =
        storageRef.putFile(ref.read(cartProvider).proofOfPaymentFile!);
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .doc(transactionReference.id)
        .update({TransactionFields.proofOfPayment: downloadURL});

    ref.read(cartProvider).setCartItems(await getCartEntries(context));
    ref.read(cartProvider).resetSelectedCartItems();
    ref.read(cartProvider).resetProofOfPaymentFile();
    ref.read(cartProvider).setSelectedPaymentMethod('');
    scaffoldMessenger.showSnackBar(const SnackBar(
        content:
            Text('Successfully settled payment and created purchase order')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pop();
    Navigator.of(context).pushReplacementNamed(NavigatorRoutes.cart);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error purchasing this cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future markOrderAsPickedUp(BuildContext context, WidgetRef ref,
    {required String orderID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    await FirebaseFirestore.instance
        .collection(Collections.orders)
        .doc(orderID)
        .update({
      OrderFields.orderStatus: OrderStatuses.pickedUp,
      OrderFields.datePickedUp: DateTime.now()
    });
    ref.read(ordersProvider).setOrderDocs(await getUserOrderHistory());
    ref.read(ordersProvider).sortOrdersByDate();
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Successfully marked order as picked up')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error marking order as picked up: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future reviewThisOrder(BuildContext context, WidgetRef ref,
    {required String orderID,
    required int rating,
    required TextEditingController reviewController,
    required List<File> reviewImageFiles}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (rating <= 0 || rating > 6) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please input a rating between 1 to 5.')));
      return;
    }

    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.orders)
        .doc(orderID)
        .update({
      OrderFields.review: {
        ReviewFields.rating: rating,
        ReviewFields.review: reviewController.text.trim()
      }
    });

    if (reviewImageFiles.isNotEmpty) {
      List<dynamic> downloadURLs = [];
      for (var imageFile in reviewImageFiles) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child(StorageFields.reviews)
            .child(orderID)
            .child('${generateRandomHexString(6)}.png');
        final uploadTask = storageRef.putFile(imageFile);
        final taskSnapshot = await uploadTask;
        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        downloadURLs.add(downloadURL);
      }

      await FirebaseFirestore.instance
          .collection(Collections.orders)
          .doc(orderID)
          .update({
        OrderFields.review: {
          ReviewFields.imageURLs: downloadURLs,
          ReviewFields.rating: rating,
          ReviewFields.review: reviewController.text.trim()
        }
      });
    }
    ref.read(loadingProvider).toggleLoading(false);
    navigator.pop();
    navigator.pushReplacementNamed(NavigatorRoutes.orderHistory);
  } catch (error) {
    ref.read(loadingProvider).toggleLoading(false);
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding a review to this order: $error')));
  }
}
//==============================================================================
//==GALLERY=====================================================================
//==============================================================================

Future<List<DocumentSnapshot>> getAllServiceGalleryDocs() async {
  final gallery = await FirebaseFirestore.instance
      .collection(Collections.galleries)
      .where(GalleryFields.galleryType, isEqualTo: GalleryTypes.service)
      .get();

  return gallery.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllTestimonialGalleryDocs() async {
  final gallery = await FirebaseFirestore.instance
      .collection(Collections.galleries)
      .where(GalleryFields.galleryType, isEqualTo: GalleryTypes.testimonial)
      .get();

  return gallery.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllPortfolioGalleryDocs() async {
  final gallery = await FirebaseFirestore.instance
      .collection(Collections.galleries)
      .where(GalleryFields.galleryType, isEqualTo: GalleryTypes.portfolio)
      .get();

  return gallery.docs.map((e) => e as DocumentSnapshot).toList();
}
