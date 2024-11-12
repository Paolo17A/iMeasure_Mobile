import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imeasure_mobile/utils/string_util.dart';

class OrdersNotifier extends ChangeNotifier {
  List<DocumentSnapshot> _orderDocs = [];
  List<DocumentSnapshot> get orderDocs => _orderDocs;

  void setOrderDocs(List<DocumentSnapshot> orders) {
    _orderDocs = orders;
    _orderDocs.sort((a, b) {
      DateTime aTime = (a[OrderFields.dateCreated] as Timestamp).toDate();
      DateTime bTime = (b[OrderFields.dateCreated] as Timestamp).toDate();
      return bTime.compareTo(aTime);
    });
    notifyListeners();
  }

  void sortOrdersByDate() {
    orderDocs.sort((a, b) {
      DateTime aTime = (a[OrderFields.dateCreated] as Timestamp).toDate();
      DateTime bTime = (b[OrderFields.dateCreated] as Timestamp).toDate();
      return bTime.compareTo(aTime);
    });
    notifyListeners();
  }
}

final ordersProvider =
    ChangeNotifierProvider<OrdersNotifier>((ref) => OrdersNotifier());
