import 'package:ashwani/Models/iq_list.dart';
import 'package:ashwani/Models/purchase_order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _auth = FirebaseAuth.instance.currentUser;
String? uid = _auth!.email;

class NPOrderProvider with ChangeNotifier {
  final List<PurchaseOrderModel> _po = [];
  List<PurchaseOrderModel> get po => _po;
  final List<ItemTrackingPurchaseOrder> _pa = [];
  List<ItemTrackingPurchaseOrder> get pa => _pa;

  final CollectionReference _purchaseOrderCollection = FirebaseFirestore
      .instance
      .collection('UserData')
      .doc(uid)
      .collection('orders')
      .doc('purchases')
      .collection('purchase_orders');
  final _cref = FirebaseFirestore.instance
      .collection('UserData')
      .doc(uid)
      .collection('purchase_activities');

  void clearAll() {
    _po.clear();
    _pa.clear();
    notifyListeners();
  }

  void addPurchaseOrdertoProvider(PurchaseOrderModel po) {
    _po.add(po);
    notifyListeners();
  }

  void updatePurchaseActivityinProvider(ItemTrackingPurchaseOrder activity) {
    _pa.add(activity);
    notifyListeners();
  }

  Future<void> addPurchaseOrder(PurchaseOrderModel puchaseOrder) async {
    try {
      await _purchaseOrderCollection
          .doc((puchaseOrder.orderID.toString()))
          .set({
        'orderId': puchaseOrder.orderID,
        'vendor_name': puchaseOrder.vendorName,
        'purchase_date': puchaseOrder.purchaseDate,
        'delivery_date': puchaseOrder.deliveryDate,
        'notes': puchaseOrder.notes,
        'tandc': puchaseOrder.tandc,
        'payment_terms': puchaseOrder.paymentTerms,
        'delivery_method': puchaseOrder.deliveryMethod,
        'status': puchaseOrder.status,
      });
      final itemsCollection = _purchaseOrderCollection
          .doc(puchaseOrder.orderID.toString())
          .collection('items');

      for (final item in puchaseOrder.items!) {
        await itemsCollection.doc(item.itemName).set({
          'itemName': item.itemName,
          'quantityPurchase': item.quantityPurchase,
          'originalQuantity': item.originalQuantity
        });
      }
      notifyListeners();
    } catch (e) {
      print('error uploading purchase order');
    }
  }

  Future<void> fetchPurchaseOrders() async {
    try {
      final querySnapshot = await _purchaseOrderCollection.get();
      _po.clear();
      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final purchaseOrder = PurchaseOrderModel(
            orderID: data['orderId'],
            vendorName: data['vendor_name'],
            purchaseDate: data['purchase_date'],
            deliveryDate: data['delivery_date'],
            paymentTerms: data['payment_terms'],
            deliveryMethod: data['delivery_method'],
            notes: data['notes'],
            tandc: data['tandc'],
            status: data['status']);

        final itemCollection = doc.reference.collection('items');
        final itemDocs = await itemCollection.get();
        if (itemDocs.docs.isNotEmpty) {
          purchaseOrder.items = itemDocs.docs.map((itemDoc) {
            final itemData = itemDoc.data();
            return Item(
                itemName: itemData['itemName'],
                itemQuantity: itemData['itemQuantity'],
                originalQuantity: itemData['originalQuantity'] ?? 0);
          }).toList();
        }

        final tracksCollection = doc.reference.collection('tracks');
        final trackDocs = await tracksCollection.get();
        if (trackDocs.docs.isNotEmpty) {
          purchaseOrder.tracks = trackDocs.docs.map((tdoc) {
            final trackData = tdoc.data();
            return ItemTrackingPurchaseOrder(
                itemName: trackData['itemName'],
                quantityRecieved: trackData['quantityRecieved'] ?? 0,
                quantityReturned: trackData['quantityReturned'] ?? 0,
                date: trackData['date'] ?? '');
          }).toList();
        }
        final itemsRecievedCollection =
            doc.reference.collection('itemsRecieved');
        final recieveDocs = await itemsRecievedCollection.get();
        if (recieveDocs.docs.isNotEmpty) {
          purchaseOrder.itemsRecieved = recieveDocs.docs.map((recieved) {
            final itemRecievedData = recieved.data();
            return ItemTrackingPurchaseOrder(
              itemName: itemRecievedData['itemName'],
              quantityRecieved: itemRecievedData['quantityRecieved'] ?? 0,
              quantityReturned: itemRecievedData['quantityReturned'] ?? 0,
            );
          }).toList();
        }
        final itemReturnedCollection = doc.reference.collection('returns');
        final itemsReturnedDocs = await itemReturnedCollection.get();
        if (itemsReturnedDocs.docs.isNotEmpty) {
          purchaseOrder.itemsReturned = itemsReturnedDocs.docs.map((e) {
            final itemReturned = e.data();
            return ItemTrackingPurchaseOrder(
              itemName: itemReturned['itemName'],
              quantityReturned: itemReturned['quantityReturned'] ?? 0,
            );
          }).toList();
        }
        _po.add(purchaseOrder);
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching orders");
    }
  }

  Future<void> fetchPurchaseActivity() async {
    try {
      final snapshot = await _cref.get();
      _pa.clear();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final purchaseActivity = ItemTrackingPurchaseOrder(
            itemName: data['itemName'],
            quantityRecieved: data['quantityRecieved'] ?? 0,
            quantityReturned: data['quantityReturned'] ?? 0,
            date: data['date'] ?? '',
            vendor: data['vendor'] ?? '');
        _pa.add(purchaseActivity);
      }
      notifyListeners();
    } catch (e) {
      print('error fetching purhcase activity $e');
    }
  }

  void purchaseReturnProviderUpdate(int orderId, String itemName,
      int quantityReturned, ItemTrackingPurchaseOrder itemReturned) {
    int index = _po.indexWhere((element) => element.orderID == orderId);
    PurchaseOrderModel? foundOrder = _po[index];

    if (foundOrder.orderID != 0) {
      final itemsRecievedList = foundOrder.itemsRecieved;

      int itemIndex = itemsRecievedList!
          .indexWhere((element) => element.itemName == itemName);

      ItemTrackingPurchaseOrder itemRecieved = itemsRecievedList[itemIndex];

      itemRecieved.quantityRecieved -= quantityReturned;
      itemRecieved.quantityReturned += quantityReturned;
      itemsRecievedList[itemIndex] = itemRecieved;

      foundOrder.itemsRecieved = itemsRecievedList;

      if (foundOrder.itemsReturned == null) {
        List<ItemTrackingPurchaseOrder> itemsReturnedList = [itemReturned];
        foundOrder.itemsReturned = itemsReturnedList;
      } else {
        List<ItemTrackingPurchaseOrder> itemsReturnedList =
            foundOrder.itemsReturned!;

        try {
          int itemIndex = itemsReturnedList
              .indexWhere((element) => element.itemName == itemName);

          ItemTrackingPurchaseOrder? itemReturned =
              itemsReturnedList[itemIndex];

          itemReturned.quantityReturned += quantityReturned;
          itemsReturnedList[itemIndex] = itemReturned;

          foundOrder.itemsReturned = itemsReturnedList;
        } catch (e) {
          print('error in return $e');
          itemsReturnedList.add(itemReturned);
          foundOrder.itemsReturned = itemsReturnedList;
        }
      }
    }
    _po[index] = foundOrder;
    notifyListeners();
  }

  void purchaseRecievedProviderUpdate(int orderId, String itemName,
      int quantityRecieved, ItemTrackingPurchaseOrder itemRecieved) {
    try {
      int index = _po.indexWhere((element) => element.orderID == orderId);
      PurchaseOrderModel foundOrder = _po[index];

      if (foundOrder.orderID != 0) {
        final itemsList = foundOrder.items;
        int itemindex =
            itemsList!.indexWhere((element) => element.itemName == itemName);
        Item item = itemsList[itemindex];
        item.quantityPurchase = item.quantityPurchase! - quantityRecieved;
        itemsList[itemindex] = item;
        foundOrder.items = itemsList;

        if (foundOrder.itemsRecieved == null) {
          List<ItemTrackingPurchaseOrder> itemsRecieved = [itemRecieved];
          foundOrder.itemsRecieved = itemsRecieved;
        } else {
          List<ItemTrackingPurchaseOrder> itemsRecievedList =
              foundOrder.itemsRecieved!;
          try {
            int itemIndex = itemsRecievedList
                .indexWhere((element) => element.itemName == itemName);
            ItemTrackingPurchaseOrder? itemRecieved =
                itemsRecievedList[itemIndex];
            itemRecieved.quantityRecieved += quantityRecieved;
            itemsRecievedList[itemIndex] = itemRecieved;
            foundOrder.itemsRecieved = itemsRecievedList;
          } catch (e) {
            print('error in recieved $e');
            itemsRecievedList.add(itemRecieved);
            foundOrder.itemsRecieved = itemsRecievedList;
          }
        }
      }
      _po[index] = foundOrder;
      notifyListeners();
    } catch (e) {
      print('error in main provider update $e');
    }
  }
}


// final itemRecievedList = foundOrder.itemsRecieved;
    // ItemTrackingPurchaseOrder? itemRecieved = itemRecievedList!
    //     .firstWhere((element) => element.itemName == itemName);
    // itemRecieved.quantityRecieved += quantityRecieved;

    // final itemsList = foundOrder.items;
    // Item? item =
    //     itemsList!.firstWhere((element) => element.itemName == itemName);
    // item.itemQuantity = item.itemQuantity! - quantityRecieved;
    // _lastUpdatedPurchaseOrder = foundOrder;
    // _pa.clear();

       // ItemTrackingPurchaseOrder? itemReturned = itemReturnedList!
      //     .firstWhere((element) => element.itemName == itemName);
      // int prevReturnQuantity = itemReturned.quantityReturned;
      // itemReturned.quantityReturned += quantityReturned;

      // final itemRecievedList = foundOrder.itemsRecieved;

      // ItemTrackingPurchaseOrder? itemRecieved = itemRecievedList!
      //     .firstWhere((element) => element.itemName == itemName);

      // itemRecieved.quantityReturned += quantityReturned;

      // _lastUpdatedPurchaseOrder = foundOrder;
      // _pa.clear();