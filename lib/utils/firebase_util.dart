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

import '../providers/profile_image_url_provider.dart';
import '../providers/settle_payment_provider.dart';
import 'navigator_util.dart';
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
    ref
        .read(profileImageURLProvider)
        .setImageURL(userData[UserFields.profileImageURL]);
    ref.read(loadingProvider.notifier).toggleLoading(false);
    navigator.pushReplacementNamed(NavigatorRoutes.home);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Error logging in: $error')));
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
    required TextEditingController mobileNumberController}) async {
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
    });
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
//WINDOWS=======================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllWindowDocs() async {
  final products =
      await FirebaseFirestore.instance.collection(Collections.windows).get();
  return products.docs;
}

Future<DocumentSnapshot> getThisWindowDoc(String productID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.windows)
      .doc(productID)
      .get();
}

Future<List<DocumentSnapshot>> getSelectedWindowDocs(
    List<String> windowIDs) async {
  if (windowIDs.isEmpty) {
    return [];
  }
  final products = await FirebaseFirestore.instance
      .collection(Collections.windows)
      .where(FieldPath.documentId, whereIn: windowIDs)
      .get();
  return products.docs.map((doc) => doc as DocumentSnapshot).toList();
}

//==============================================================================
//==CART--======================================================================
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

Future addProductToCart(BuildContext context, WidgetRef ref,
    {required String productID}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (!hasLoggedInUser()) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please log-in to your account first.')));
    return;
  }
  try {
    if (ref.read(cartProvider).cartContainsThisItem(productID)) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('This item is already in your cart.')));
      return;
    }

    final cartDocReference =
        await FirebaseFirestore.instance.collection(Collections.cart).add({
      CartFields.windowID: productID,
      CartFields.clientID: FirebaseAuth.instance.currentUser!.uid
    });
    ref.read(cartProvider.notifier).addCartItem(await cartDocReference.get());
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully added this item to your cart.')));
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error adding product to cart: $error')));
  }
}

Future removeCartItem(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot cartDoc}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await cartDoc.reference.delete();

    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully removed this item from your cart.')));
    ref.read(cartProvider).removeCartItem(cartDoc);
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
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

Future generateOrder(BuildContext context, WidgetRef ref,
    {required num width,
    required num height,
    required List<dynamic> mandatoryWindowFields,
    required List<Map<dynamic, dynamic>> optionalWindowFields,
    required num totalGlassPrice,
    required num totalOverallPayment}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);

    List<Map<dynamic, dynamic>> mandatoryMap = [];
    mandatoryMap.add({
      OrderBreakdownMap.field: 'Glass',
      OrderBreakdownMap.breakdownPrice: totalGlassPrice
    });
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

    //  1. Generate a purchase document for the selected cart item
    final cartDoc =
        await getThisCartEntry(ref.read(cartProvider).selectedCartItem);
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;

    //  1. Generate Order Entry
    await FirebaseFirestore.instance.collection(Collections.orders).add({
      OrderFields.windowID: cartData[CartFields.windowID],
      OrderFields.clientID: cartData[CartFields.clientID],
      OrderFields.width: width,
      OrderFields.height: height,
      OrderFields.glassType: ref.read(cartProvider).selectedGlassType,
      OrderFields.color: ref.read(cartProvider).selectedColor,
      OrderFields.purchaseStatus: OrderStatuses.generated,
      OrderFields.datePickedUp: DateTime(1970),
      OrderFields.rating: '',
      OrderFields.mandatoryMap: mandatoryMap,
      OrderFields.optionalMap: optionalMap,
      OrderFields.windowOverallPrice: totalOverallPayment,
      OrderFields.laborPrice: 0,
      OrderFields.quotationURL: ''
    });

    //  4. Delete cart entry
    await FirebaseFirestore.instance
        .collection(Collections.cart)
        .doc(ref.read(cartProvider).selectedCartItem)
        .delete();
    ref.read(cartProvider).cartItems = await getCartEntries(context);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content:
            Text('Successfully settled payment and created purchase order')));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ref.read(cartProvider).setSelectedCartItem('');
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error generating new order: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future settlePendingPayment(BuildContext context, WidgetRef ref,
    {required String orderID, required num amount}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .doc(orderID)
        .set({
      TransactionFields.clientID: FirebaseAuth.instance.currentUser!.uid,
      TransactionFields.paidAmount: amount,
      TransactionFields.paymentVerified: false,
      TransactionFields.paymentStatus: PaymentStatuses.pending,
      TransactionFields.paymentMethod:
          ref.read(cartProvider).selectedPaymentMethod,
      TransactionFields.dateCreated: DateTime.now(),
      TransactionFields.dateApproved: DateTime(1970),
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${orderID}.png');
    final uploadTask = storageRef
        .putFile(File(ref.read(settlePaymentProvider).paymentImage!.path));
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .doc(orderID)
        .update({TransactionFields.proofOfPayment: downloadURL});

    await FirebaseFirestore.instance
        .collection(Collections.orders)
        .doc(orderID)
        .update({OrderFields.purchaseStatus: OrderStatuses.processing});
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
            'Successfully settled pending payment for this rental request.')));
    ref.read(loadingProvider).toggleLoading(false);
    navigator.pop();
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error settling pending payment: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

/*Future purchaseSelectedCartItem(BuildContext context, WidgetRef ref,
    {required TextEditingController widthController,
    required TextEditingController heightController,
    required num minHeight,
    required num maxHeight,
    required num minWidth,
    required num maxWidth}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  if (widthController.text.isEmpty || heightController.text.isEmpty) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
            'Please input your desired window width and height (in cm).')));
    return;
  }
  if (double.tryParse(widthController.text.trim()) == null ||
      double.parse(widthController.text.trim()) < minWidth ||
      double.parse(widthController.text.trim()) > maxWidth) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
            'Please input a valid width value between ${minWidth}cm and ${maxWidth}cm.')));
    return;
  }
  if (double.tryParse(heightController.text.trim()) == null ||
      double.parse(heightController.text.trim()) < minHeight ||
      double.parse(heightController.text.trim()) > maxHeight) {
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
            'Please input a valid height value between ${minHeight}cm and ${maxHeight}cm.')));
    return;
  }
  ImagePicker imagePicker = ImagePicker();
  final selectedXFile =
      await imagePicker.pickImage(source: ImageSource.gallery);
  if (selectedXFile == null) {
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);

    //  1. Generate a purchase document for the selected cart item
    final cartDoc =
        await getThisCartEntry(ref.read(cartProvider).selectedCartItem);
    final cartData = cartDoc.data() as Map<dynamic, dynamic>;
    //final productID = cartData[CartFields.productID];
    //final window = await getThisWindowDoc(productID);
    //final windowData = window.data() as Map<dynamic, dynamic>;

    final orderReference =
        await FirebaseFirestore.instance.collection(Collections.orders).add({
      OrderFields.windowID: cartData[CartFields.windowID],
      OrderFields.clientID: cartData[CartFields.clientID],
      OrderFields.glassType: ref.read(cartProvider).selectedGlassType,
      OrderFields.purchaseStatus: OrderStatuses.pending,
      OrderFields.datePickedUp: DateTime(1970),
      OrderFields.rating: ''
    });

    //  2. Generate a payment document in Firestore
    await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .doc(orderReference.id)
        .set({
      TransactionFields.clientID: cartData[CartFields.clientID],
      TransactionFields.paidAmount: 5000,
      TransactionFields.paymentVerified: false,
      TransactionFields.paymentStatus: PaymentStatuses.pending,
      TransactionFields.paymentMethod:
          ref.read(cartProvider).selectedPaymentMethod,
      TransactionFields.dateCreated: DateTime.now(),
      TransactionFields.dateApproved: DateTime(1970),
    });

    //  3. Upload the proof of payment image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${orderReference.id}.png');
    final uploadTask = storageRef.putFile(File(selectedXFile.path));
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection(Collections.transactions)
        .doc(orderReference.id)
        .update({TransactionFields.proofOfPayment: downloadURL});

    //  4. Delete cart entry
    await cartDoc.reference.delete();
    ref.read(cartProvider).cartItems = await getCartEntries(context);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content:
            Text('Successfully settled payment and created purchase order')));
    Navigator.of(context).pop();
    ref.read(cartProvider).setSelectedCartItem('');
    ref.read(loadingProvider.notifier).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error purchasing this cart item: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}*/
