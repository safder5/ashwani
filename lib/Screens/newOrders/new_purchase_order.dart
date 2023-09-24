import 'package:ashwani/Models/purchase_order.dart';
import 'package:ashwani/Providers/iq_list_provider.dart';
import 'package:ashwani/Providers/new_purchase_order_provider.dart';
import 'package:ashwani/Screens/newOrders/addItemto%20Order/add_purchase_order_item.dart';
import 'package:ashwani/constantWidgets/boxes.dart';
import 'package:ashwani/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../Services/helper.dart';
import '../../main.dart';

class NewPurchaseOrder extends StatefulWidget {
  const NewPurchaseOrder({super.key});

  @override
  State<NewPurchaseOrder> createState() => _NewPurchaseOrderState();
}

class _NewPurchaseOrderState extends State<NewPurchaseOrder> {
  final GlobalKey<FormState> npoForm = GlobalKey<FormState>();
  final AutovalidateMode _npoAVM = AutovalidateMode.onUserInteraction;
  DateTime cdate = DateTime.now();

  final TextEditingController _vendorName = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _termsController = TextEditingController();
  final TextEditingController _npodateController = TextEditingController();
  final TextEditingController _npoDelDateController = TextEditingController();
  final TextEditingController _paymentController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();
  final String status = 'Order Placed';
  final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  Widget build(BuildContext context) {
    final poItemsProvider = Provider.of<ItemsProvider>(context);
    final purchaseProvider = Provider.of<NPOrderProvider>(context);
    return Scaffold(
      backgroundColor: w,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0),
        child: GestureDetector(
          onTap: () async {
            final newPurchaseOrder = PurchaseOrderModel(
                orderID: int.parse(orderId),
                vendorName: _vendorName.text,
                purchaseDate: _npodateController.text,
                deliveryDate: _npoDelDateController.text,
                paymentTerms: _paymentController.text,
                deliveryMethod: _deliveryController.text,
                notes: _notesController.text,
                tandc: _termsController.text,
                status: status,
                items: poItemsProvider.items);
            await purchaseProvider.addPurchaseOrder(newPurchaseOrder);
            poItemsProvider.clearItems();
            // submit final purchase order
            if (!context.mounted) return;
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MyApp()));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: blue,
            ),
            width: double.infinity,
            height: 48,
            child: Center(
                child: Text(
              'Create Purchase Order',
              style: TextStyle(
                color: w,
              ),
              textScaleFactor: 1.2,
            )),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // itemProvider.clearItems();
                      },
                      child: const Icon(LineIcons.angleLeft)),
                  const SizedBox(width: 10),
                  const Text('New Purchase Order'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      //submit everything after validation is processed
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.transparent,
                          border: Border.all(width: 0.6, color: blue)),
                      // width: double.infinity,
                      // height: 48,
                      child: Center(
                          child: Text(
                        'Save Draft',
                        style:
                            TextStyle(color: blue, fontWeight: FontWeight.w300),
                        textScaleFactor: 1,
                      )),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Form(
                  key: npoForm,
                  autovalidateMode: _npoAVM,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                            controller: _vendorName,
                            cursorColor: blue,
                            cursorWidth: 1,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            decoration: getInputDecoration(
                                hint: 'Vendor Name', errorColor: Colors.red)),
                        const SizedBox(
                          height: 24,
                        ),
                        SizedBox(
                          height: poItemsProvider.items.length * 80,
                          child: ListView.builder(
                              itemCount: poItemsProvider.items.length,
                              itemBuilder: (context, index) {
                                final item = poItemsProvider.items[index];
                                return NewSalesOrderItemsTile(
                                  index: index,
                                  name: item.itemName ?? '',
                                  quantity: item.itemQuantity.toString(),
                                );
                              }),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await poItemsProvider.getItems();
                            // print(poItemsProvider.poItems[0].itemName);
                            //show BottomModalSheet
                            if (!context.mounted) return;
                            showModalBottomSheet<dynamic>(
                                backgroundColor: t,
                                isScrollControlled: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return const AddPurchaseOrderItem();
                                });
                          },
                          child: AbsorbPointer(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.transparent,
                                  border: Border.all(width: 0.6, color: blue)),
                              width: double.infinity,
                              height: 48,
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LineIcons.plusCircle,
                                    color: blue,
                                  ),
                                  Text(
                                    '  Add Items ',
                                    style: TextStyle(
                                        color: blue,
                                        fontWeight: FontWeight.w300),
                                    textScaleFactor: 1,
                                  ),
                                ],
                              )),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                         TextFormField(
                            cursorColor: blue,
                            cursorWidth: 1,
                            readOnly: true,
                            initialValue: '#$orderId',
                            textInputAction: TextInputAction.next,
                            decoration: getInputDecoration(
                                hint: 'Order No. #2304',
                                errorColor: Colors.red)),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          controller: _npodateController,
                          readOnly: true,
                          // validator: validateDate,
                          textInputAction: TextInputAction.next,
                          decoration: getInputDecoration(
                                  hint: 'Purchase Order Date',
                                  errorColor: Colors.red)
                              .copyWith(
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                                context: context,
                                                initialEntryMode:
                                                    DatePickerEntryMode
                                                        .calendarOnly,
                                                initialDate: cdate,
                                                firstDate:
                                                    DateTime.utc(1965, 1, 1),
                                                lastDate:
                                                    DateTime(cdate.year + 1));
                                        if (pickedDate != null) {
                                          //get the picked date in the format => 2022-07-04 00:00:00.000
                                          String formattedDate =
                                              DateFormat('dd-MM-yyyy').format(
                                                  pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                          //formatted date output using intl package =>  2022-07-04
                                          setState(() {
                                            _npodateController.text =
                                                formattedDate; //set foratted date to TextField value.
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        LineIcons.calendarWithDayFocus,
                                        color: b25,
                                      ))),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          controller: _npoDelDateController,
                          readOnly: true,
                          // validator: validateDate,
                          textInputAction: TextInputAction.next,
                          decoration: getInputDecoration(
                                  hint: 'Purchase Order Date',
                                  errorColor: Colors.red)
                              .copyWith(
                                  suffixIcon: IconButton(
                                      onPressed: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                                context: context,
                                                initialEntryMode:
                                                    DatePickerEntryMode
                                                        .calendarOnly,
                                                initialDate: cdate,
                                                firstDate:
                                                    DateTime.utc(1965, 1, 1),
                                                lastDate:
                                                    DateTime(cdate.year + 1));
                                        if (pickedDate != null) {
                                          //get the picked date in the format => 2022-07-04 00:00:00.000
                                          String formattedDate =
                                              DateFormat('dd-MM-yyyy').format(
                                                  pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                          //formatted date output using intl package =>  2022-07-04
                                          setState(() {
                                            _npoDelDateController.text =
                                                formattedDate; //set foratted date to TextField value.
                                          });
                                        }
                                      },
                                      icon: Icon(
                                        LineIcons.calendarWithDayFocus,
                                        color: b25,
                                      ))),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                            controller: _paymentController,
                            cursorColor: blue,
                            cursorWidth: 1,
                            decoration: getInputDecoration(
                                hint: 'Payment Terms', errorColor: Colors.red)),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                            controller: _deliveryController,
                            cursorColor: blue,
                            cursorWidth: 1,
                            decoration: getInputDecoration(
                                    hint: 'Delivery Method',
                                    errorColor: Colors.red)
                                .copyWith(
                                    suffix: Icon(
                              LineIcons.angleDown,
                              color: b25,
                              size: 18,
                            ))),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                            controller: _notesController,
                            cursorColor: blue,
                            cursorWidth: 1,
                            decoration: getInputDecoration(
                                    hint: 'Notes', errorColor: Colors.red)
                                .copyWith(
                                    suffix: Icon(
                              LineIcons.angleDown,
                              color: b25,
                              size: 18,
                            ))),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                            controller: _termsController,
                            cursorColor: blue,
                            cursorWidth: 1,
                            decoration: getInputDecoration(
                                hint: 'Terms and Conditions',
                                errorColor: Colors.red)),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      )),
    );
  }
}
