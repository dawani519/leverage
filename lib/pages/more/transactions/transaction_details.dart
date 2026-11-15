import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsPage({super.key, required this.transactionId});

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  bool showPaymentDialog = false; // To toggle payment dialog visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(color: Color(0xFFF2F7FA)),
        ),
        backgroundColor: const Color(0xFF2F4170),
      ),
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('transactions')
                .doc(widget.transactionId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Transaction not found.'));
              }

              final transaction = snapshot.data!.data() as Map<String, dynamic>;

              // Extracting values and calculations
              final String itemName = transaction['itemName'] ?? 'No Item Name';
              final int itemQuantity = transaction['itemQuantity'] ?? 1;
              final double itemPrice = (transaction['itemPrice'] ?? 0).toDouble();
              final String customerName = transaction['name'] ?? 'No Name';
              final String customerRole = transaction['role'] ?? 'No Role';
              final String status = customerRole == 'buyer'
                  ? 'Awaiting Payment'
                  : transaction['status'] ?? 'Make payment';
              final DateTime createdAt =
              (transaction['createdAt'] as Timestamp).toDate();

              // Calculations
              final double escrowFee =
              itemPrice * 0.02 >= 500 ? itemPrice * 0.02 : 500;
              final double vat = itemPrice * 0.015;

              // Formatters
              final currencyFormatter =
              NumberFormat.currency(symbol: 'NGN ', decimalDigits: 0);
              final dateFormatter = DateFormat('dd-MM-yyyy HH:mm');

              return Opacity(
                opacity: showPaymentDialog ? 0.3 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Displaying Item Name as Title and Status
                          ListTile(
                            title: Text(
                              itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            subtitle: Text(
                              'Status: $status',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Divider(),

                          // Display fields with label on the left and value on the right
                          buildRow("Item Quantity", itemQuantity.toString()),
                          buildRow("Amount", currencyFormatter.format(itemPrice)),
                          buildRow("Escrow Fee", currencyFormatter.format(escrowFee)),
                          buildRow("VAT", currencyFormatter.format(vat)),
                          buildRow("Customer Name", customerName),
                          buildRow("Customer Role", customerRole),
                          buildRow("Reference ID", widget.transactionId),
                          buildRow(
                              "Date & Time", dateFormatter.format(createdAt)),

                          const SizedBox(height: 24.0),

                          // Make Payment Button (for seller only)
                          if (customerRole == 'Seller')
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showPaymentDialog = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2F4170),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Make Payment'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          // Payment Dialog
          if (showPaymentDialog)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Enter your payment details to proceed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showPaymentDialog = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment successful!'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4170),
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Pay Now'),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showPaymentDialog = false;
                          });
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build left-right aligned rows for details
  Widget buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
