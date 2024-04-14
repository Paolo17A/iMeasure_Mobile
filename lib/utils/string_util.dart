import 'dart:math';

class ImagePaths {
  static const String logo = 'assets/images/imeasure.png';
}

class StorageFields {
  static const String profilePics = 'profilePics';
  static const String windows = 'windows';
  static const String payments = 'payments';
}

class UserTypes {
  static const String client = 'CLIENT';
  static const String admin = 'ADMIN';
}

class Collections {
  static const String users = 'users';
  static const String faqs = 'faqs';
  static const String windows = 'windows';
  static const String payments = 'payments';
  static const String orders = 'orders';
}

class UserFields {
  static const String email = 'email';
  static const String password = 'password';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String mobileNumber = 'mobileNumber';
  static const String userType = 'userType';
  static const String profileImageURL = 'profileImageURL';
  static const String address = 'address';
  static const String bookmarks = 'bookmarks';
}

class Windows {
  static const String name = 'name';
  static const String price = 'price';
  static const String description = 'description';
  static const String imageURL = 'imageURL';
  static const String minWidth = 'minWidth';
  static const String maxWidth = 'maxWidth';
  static const String minHeight = 'minHeight';
  static const String maxHeight = 'maxHeight';
}

class FAQFields {
  static const String question = 'question';
  static const String answer = 'answer';
}

class PurchaseFields {
  static const String clientID = 'clientID';
  static const String productID = 'productID';
  static const String quantity = 'quantity';
  static const String purchaseStatus = 'purchaseStatus';
  static const String datePickedUp = 'datePickedUp';
  static const String rating = 'rating';
}

class PaymentStatuses {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String denied = 'DENIED';
}

class PathParameters {
  static const String userID = 'userID';
  static const String windowID = 'windowID';
}

String generateRandomHexString(int length) {
  final random = Random();
  final codeUnits = List.generate(length ~/ 2, (index) {
    return random.nextInt(255);
  });

  final hexString =
      codeUnits.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}
