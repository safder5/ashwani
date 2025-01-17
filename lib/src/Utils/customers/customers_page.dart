import 'package:ashwani/src/Providers/customer_provider.dart';
import 'package:ashwani/src/constantWidgets/boxes.dart';
import 'package:ashwani/src/constants.dart';
import 'package:ashwani/src/Utils/customers/add_customer.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'customer_page.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerProvider>(builder: (context, customerP, child) {
      final customers = customerP.customers
          .where((customer) =>
              customer.name.toLowerCase().contains(_searchQuery))
          .toList()
          .reversed
          .toList();
      // if (customers.length == 0) {
      //   customerP.fetchAllCustomers();
      // }
     
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddCustomer()));
          },
          backgroundColor: blue,
          child: const Center(
            child: Icon(
              LineIcons.plus,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(LineIcons.angleLeft)),
                    const SizedBox(width: 10),
                    const Text('Customers'),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 32),
                // Add the search bar here
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    suffixIcon: Icon(LineIcons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 0.5),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(
                  height: 32,
                ),

                // print(customers.length);

                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => CustomerPage(
                                        customerName:
                                            customers[index].name))));
                          },
                          child: CustomersPageContainer(
                              fullname: customers[index].name,
                              companyname: customers[index].companyName!),
                        );
                      }),
                )
              ],
            ),
          ),
        )),
      );
    });
  }
}


// SizedBox(
              //   height: MediaQuery.of(context).size.height,
              //   child: StreamBuilder<QuerySnapshot>(
              //       stream: FirebaseFirestore.instance
              //           .collection('UserData')
              //           .doc('${_auth!.email}')
              //           .collection('Customers')
              //           .snapshots(),
              //       builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
              //         if (snapshot.connectionState == ConnectionState.waiting) {
              //           return const CircularProgressIndicator();
              //         }
              //         final userCustomerSnapshot = snapshot.data?.docs;
              //         if (userCustomerSnapshot!.isEmpty) {
              //           return const Center(
              //             child: Text('No Customers yet, Add Below '),
              //           );
              //         }
              //         return ListView.builder(
              //             itemCount: userCustomerSnapshot.length,
              //             itemBuilder: (context, index) {
              //               return CustomersPageContainer(
              //                   fullname: userCustomerSnapshot[index]['name'],
              //                   companyname: userCustomerSnapshot[index]
              //                       ['companyName']);
              //             });
              //       })),
              // ),