import 'package:ashwani/Models/iq_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InventorySummaryProvider with ChangeNotifier {
  int _inHand = 0;
  int _toRecieve = 0;
  List<Item> _inventoryItems = [];
  List<Item> _purchaseOrderItems = [];

  int get inHand => _inHand;
  int get toRecieve => _toRecieve;
  List<Item> get inventoryItems => _inventoryItems;
  List<Item> get purchaseOrderItems => _purchaseOrderItems;

  final inHandRef = FirebaseFirestore.instance
      .collection('UserData')
      .doc(FirebaseAuth.instance.currentUser?.email)
      .collection('Items');

  // another reference for to be recieved items
  final tobeRecieved = FirebaseFirestore.instance
      .collection('UserData')
      .doc(FirebaseAuth.instance.currentUser?.email)
      .collection('orders')
      .doc('purchases')
      .collection('purchase_orders');

  Future<void> totalInHand() async {
    try {
      // sotre all items in inventory items
      final querySnapshot = await inHandRef.get();
      if (querySnapshot.docs.isNotEmpty) {
        _inventoryItems = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Item(
            itemName: data['itemName'],
            itemQuantity: data['itemQuantity'],
          );
        }).toList();

        // calculate sum of all items
        _inHand = _inventoryItems
            .map((item) => item.itemQuantity ?? 0)
            .reduce((sum, quantity) => sum + quantity);
        // print(_inHand);}
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching in hand items: $e');
    }
  }

  Future<void> totalTobeRecieved() async {
    try {
      // sotre all items in inventory items
      final querySnapshot = await tobeRecieved.get();
      for (final doc in querySnapshot.docs) {
        final itemsCollection = doc.reference.collection('items');
        final itemDocs = await itemsCollection.get();
        for (final itemDoc in itemDocs.docs) {
          final itemData = itemDoc.data();
          final itemQuantity = itemData['itemQuantity'] as int;
          _toRecieve += itemQuantity;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }
}