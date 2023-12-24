import 'package:SMEflow/src/Screens/sales/sales_order_return_transaction.dart';
import 'package:SMEflow/src/Screens/sales/sales_order_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../Models/sales_order.dart';
import '../../Providers/new_sales_order_provider.dart';
import '../../constants.dart';
import 'sales_page_sub_tabs.dart';

class SalesOrderPage extends StatefulWidget {
  const SalesOrderPage({super.key, required this.orderId});

  final int orderId;

  @override
  State<SalesOrderPage> createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage> {
  List<bool> isSelected = [true, false, false];
  List<String> toggleButtons = [('Details'), ('Shipped'), ('Returns')];
  @override
  Widget build(BuildContext context) {
    return Consumer<NSOrderProvider>(builder: (_, sop, __) {
      SalesOrderModel salesorder =
          sop.som.firstWhere((element) => element.orderID == widget.orderId);
      // print(' this is order page items length ${salesorder.items.isEmpty?? 0}');
      return Scaffold(
        backgroundColor: w,
        floatingActionButton: Visibility(
          visible: isSelected[0] ? false : true,
          child: FloatingActionButton(
            onPressed: () {
              if (isSelected[1]) {
                showModalBottomSheet<dynamic>(
                    backgroundColor: t,
                    isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SalesOrderTransactionsShipped(
                        items: salesorder.items,
                        orderId: salesorder.orderID!,
                        customer: salesorder.customerName!,
                      );
                    });
              }
              if (isSelected[2]) {
                final k = salesorder.itemsDelivered ?? [];
                if (k.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: w,
                      content: Text(
                        'No Items Delivered Yet!',
                        style: TextStyle(color: blue, fontSize: 16),
                      )));
                } else {
                  showModalBottomSheet<dynamic>(
                      backgroundColor: t,
                      isScrollControlled: true,
                      context: context,
                      builder: (BuildContext context) {
                        return SalesOrderReturnTransactions(
                          itemsDelivered: salesorder.itemsDelivered ?? [],
                          orderId: salesorder.orderID!,
                          customer: salesorder.customerName!,
                        );
                      });
                }
              }
            },
            backgroundColor: blue,
            child: Icon(
              Icons.add,
              color: w,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.34,
              width: double.maxFinite,
              decoration: BoxDecoration(color: blue),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 0.0, top: 16.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  LineIcons.angleLeft,
                                  color: w,
                                )),
                            const SizedBox(width: 10),
                            Text(
                              'Sales Order',
                              style: TextStyle(
                                  color: w, fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.edit_note_outlined,
                              color: w,
                            ),
                            const SizedBox(width: 15),
                            Icon(
                              FontAwesomeIcons.ellipsisVertical,
                              color: w,
                              size: 18,
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 11,
                                      width: 11,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        color: w,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      salesorder.orderID.toString(),
                                      style: TextStyle(color: w),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  salesorder.customerName!,
                                  style: TextStyle(
                                      color: w,
                                      decoration: TextDecoration.underline,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SvgPicture.asset('lib/icons/attatchment.svg')
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order date : ${salesorder.orderDate}',
                              style: TextStyle(color: w, fontSize: 10),
                            ),
                            Text(
                              'Delivery date : ${salesorder.shipmentDate}',
                              style: TextStyle(color: w, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        // GestureDetector(
                        //   onTap: () {
                        //     //marking status
                        //   },
                        //   child: Container(
                        //     // height: 35,
                        //     width: 115,
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(5),
                        //         border: Border.all(width: 0.7, color: w)),
                        //     child: Center(
                        //         child: Text(
                        //       'Mark as Shipped',
                        //       style: TextStyle(
                        //           fontWeight: FontWeight.w500, color: w),
                        //       textScaleFactor: 0.8,
                        //     )),
                        //   ),
                        // )
                      ]),
                ),
              ),
            ),
            Container(
              // height: MediaQuery.of(context).size.height * 0.66,
              color: w,
              child: Column(
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      for (var i = 0; i < isSelected.length; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              for (var buttonIndex = 0;
                                  buttonIndex < isSelected.length;
                                  buttonIndex++) {
                                if (buttonIndex == i) {
                                  isSelected[buttonIndex] = true;
                                } else {
                                  isSelected[buttonIndex] = false;
                                }
                              }
                            });
                          },
                          child: Container(
                            height: 45,
                            width: 105,
                            decoration: BoxDecoration(
                                color:
                                    isSelected[i] ? blue : b.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              toggleButtons[i],
                              style: TextStyle(
                                  color: isSelected[i] ? w : b,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 14),
                            )),
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected[0])
              SOPDetails(
                orderId: widget.orderId,
              ),
            if (isSelected[1])
              SOPShipped(
                orderId: widget.orderId,
              ),
            if (isSelected[2])
              SOPReturns(
                orderId: widget.orderId,
              ),
          ],
        ),
      );
    });
  }
}