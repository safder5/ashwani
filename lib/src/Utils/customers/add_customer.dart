import 'package:ashwani/src/Models/address_model.dart';
import 'package:ashwani/src/Models/customer_model.dart';
import 'package:ashwani/src/Providers/bs_address_provider.dart';
import 'package:ashwani/src/Providers/customer_provider.dart';
import 'package:ashwani/src/Utils/addAddressBillingShipping.dart/add_address.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../Services/helper.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({super.key});

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final _auth = FirebaseAuth.instance.currentUser;
  bool isAddressSaved = false;

  String firstName = '';
  String lastName = '';
  String fullName = '';
  String companyName = '';
  String displayName = '';
  String email = '';
  String phoneNumber = '';
  String remarks = '';
  String type = 'business';
  AddressModel? bill;
  AddressModel? ship;

  bool _business = true;

  void shiftSelectiontobusiness() {
    if (_business != true) {
      setState(() => {_business = true, type = 'business'});
    }
  }

  void shiftSelectiontoindividual() {
    if (_business == true) {
      setState(() => {_business = false, type = 'individual'});
    }
  }

  void setAddresSaved(bool saved) {
    setState(() {
      isAddressSaved = saved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final addressPvdr = Provider.of<BSAddressProvider>(context);
    return Scaffold(
      backgroundColor: w,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 16.0, right: 16.0),
        child: GestureDetector(
          onTap: () async {
            final docRef = FirebaseFirestore.instance
                .collection('UserData')
                .doc('${_auth!.email}')
                .collection('Customers')
                .doc(fullName);
            //submit everything after validation is processed
            final customerdetails = CustomerModel(
                name: fullName,
                displayname: displayName,
                companyName: companyName,
                email: email,
                phone: phoneNumber,
                remarks: remarks,
                business: _business);
            if (addressPvdr.shipping != null) {
              bill = addressPvdr.billing;
              ship = addressPvdr.shipping;
            }
            await customerProvider.addCustomer(
              customerdetails,
              docRef,
              bill,
              ship,
            );
            customerProvider.addCustomerinProvider(
              customerdetails,
              bill,
              ship,
            );
            addressPvdr.clearAddresses();
            if (!context.mounted) return;
            Navigator.pop(context);
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //         builder: (context) => const CustomerPage()));
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
              'Add as Customer',
              style: TextStyle(
                color: w, fontSize: 14
              ),
            )),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(LineIcons.angleLeft)),
                  const SizedBox(width: 10),
                  const Text('Add Customer'),
                  const Spacer(),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              const Text(
                'Customer Name',
                style: TextStyle(fontWeight: FontWeight.w300),
              ),
              const SizedBox(
                height: 28,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        shiftSelectiontobusiness();
                      });
                    },
                    child: AbsorbPointer(
                      child: Row(
                        children: [
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: w,
                                border: Border.all(
                                    width: 1, color: _business ? blue : b32)),
                            child: Center(
                              child: CircleAvatar(
                                maxRadius: 5,
                                backgroundColor: _business ? blue : w,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Business',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, color: b,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        shiftSelectiontoindividual();
                      });
                    },
                    child: AbsorbPointer(
                      child: Row(
                        children: [
                          Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: w,
                                border: Border.all(
                                    width: 1, color: _business ? b32 : blue)),
                            child: Center(
                              child: CircleAvatar(
                                maxRadius: 5,
                                backgroundColor: _business ? w : blue,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Individual',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, color: b,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // toggle ends here
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextFormField(
                    onChanged: (value) {
                      firstName = value;
                      fullName = '$value $lastName';
                    },
                    cursorWidth: 1,
                    cursorColor: blue,
                    validator: validateName,
                    decoration: getInputDecoration(
                            hint: 'First Name', errorColor: Colors.red)
                        .copyWith(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.45)),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      lastName = value;
                      fullName = '$firstName $value';
                      // print(fullName);
                    },
                    cursorColor: blue,
                    cursorWidth: 1,
                    validator: validateName,
                    decoration: getInputDecoration(
                            hint: 'Last Name', errorColor: Colors.red)
                        .copyWith(
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.45)),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                onChanged: (value) {
                  companyName = value;
                },
                cursorWidth: 1,
                cursorColor: blue,
                validator: validateName,
                decoration: getInputDecoration(
                    hint: 'Company Name', errorColor: Colors.red),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                onChanged: (value) {
                  displayName = value;
                },
                cursorWidth: 1,
                cursorColor: blue,
                validator: validateName,
                decoration: getInputDecoration(
                    hint: 'Display Name', errorColor: Colors.red),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                cursorWidth: 1,
                cursorColor: blue,
                validator: validateName,
                decoration:
                    getInputDecoration(hint: 'Email', errorColor: Colors.red),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                onChanged: (value) {
                  phoneNumber = value;
                },
                cursorWidth: 1,
                cursorColor: blue,
                validator: validateOrderNo,
                decoration: getInputDecoration(
                    hint: 'Phone Number', errorColor: Colors.red),
              ),
              const SizedBox(
                height: 24,
              ),
              GestureDetector(
                onTap: () {
                  // add shipping and details somehow
                },
                child: GestureDetector(
                  onTap: () {
                    //add shipping details pop up menu here
                    //do it later
                    showModalBottomSheet<dynamic>(
                        backgroundColor: t,
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return AddBillingShippingAddress(
                            onAddressSaved: setAddresSaved,
                          );
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
                            isAddressSaved
                                ? LineIcons.checkCircleAlt
                                : LineIcons.plusCircle,
                            color: blue,
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Text(
                            isAddressSaved
                                ? 'Adress Saved'
                                : 'Add Billing & Shipping Address',
                            style: TextStyle(
                                color: blue, fontWeight: FontWeight.w300),
                          ),
                        ],
                      )),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TextFormField(
                onChanged: (value) {
                  remarks = value;
                },
                cursorWidth: 1,
                cursorColor: blue,
                // validator: validateName,
                decoration: getInputDecoration(
                    hint: 'Remarks (personal) ', errorColor: Colors.red),
              ),
              // const SizedBox(
              //   height: 24,
              // ),
            ],
          ),
        ),
      )),
    );
  }
}
