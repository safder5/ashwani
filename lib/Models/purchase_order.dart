import 'package:ashwani/Models/iq_list.dart';

class PurchaseOrderModel {
  final int orderID;
  final String? vendorName;
  final String? purchaseDate;
  final String? deliveryDate;
  final String? notes;
  final String? tandc;
  final String? paymentTerms;
  final String? deliveryMethod;
  final String? status;
  List<Item>? items;
    List<ItemTrackingPurchaseOrder>? tracks;
  List<ItemTrackingPurchaseOrder>? itemsRecieved;
  List<ItemTrackingPurchaseOrder>? itemsReturned;

  PurchaseOrderModel({
    required this.orderID,
    required this.vendorName,
    required this.purchaseDate,
    required this.deliveryDate,
    required this.paymentTerms,
    required this.deliveryMethod,
    required this.notes,
    required this.tandc,
    required this.status,
    this.items,
    this.itemsRecieved,
    this.itemsReturned,
    this.tracks,
  });
}
