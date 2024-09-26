import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileImageURLNotifier extends ChangeNotifier {
  String profileImageURL = '';
  String _formattedName = '';

  String get formattedName => _formattedName;

  void removeImageURL() {
    profileImageURL = '';
    notifyListeners();
  }

  void setImageURL(String image) {
    profileImageURL = image;
    notifyListeners();
  }

  void setFormattedName(String name) {
    _formattedName = name;
    notifyListeners();
  }
}

final profileImageURLProvider =
    ChangeNotifierProvider<ProfileImageURLNotifier>((ref) {
  return ProfileImageURLNotifier();
});
