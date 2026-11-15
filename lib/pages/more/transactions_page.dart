import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leverage/pages/more/transactions/transaction_details.dart';
import 'package:async/async.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(color: Color(0xFFF2F7FA)),
        ),
        backgroundColor: const Color(0xFF2F4170),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase(); // Update search query
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by item name or amount...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Transactions List
          Expanded(
            child: TransactionsList(searchQuery: searchQuery),
          ),
        ],
      ),
    );
  }
}

class TransactionsList extends StatelessWidget {
  final String searchQuery;

  const TransactionsList({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Please log in to view transactions.'));
    }

    // Fetch transactions from Firestore for the current user as buyer or seller
    final Stream<QuerySnapshot> buyerTransactionsStream = FirebaseFirestore.instance
        .collection('transactions')
        .where('buyerId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    final Stream<QuerySnapshot> sellerTransactionsStream = FirebaseFirestore.instance
        .collection('transactions')
        .where('sellerId', isEqualTo: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    // Combine both streams
    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([buyerTransactionsStream, sellerTransactionsStream]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No transactions found.'));
        }

        final List<QuerySnapshot> allTransactions = snapshot.data!;
        final List<DocumentSnapshot> transactions = [
          ...allTransactions[0].docs, // Buyer transactions
          ...allTransactions[1].docs, // Seller transactions
        ];

        // Apply search filter
        final filteredTransactions = transactions.where((transaction) {
          final data = transaction.data() as Map<String, dynamic>;
          final String itemName = data['itemName']?.toString().toLowerCase() ?? '';
          final num? itemPrice = data['itemPrice']; // Retrieve numeric itemPrice
          final String itemPriceStr = itemPrice?.toString() ?? '';

          return itemName.contains(searchQuery) || itemPriceStr.contains(searchQuery);
        }).toList();

        if (filteredTransactions.isEmpty) {
          return const Center(child: Text('No transactions match your search.'));
        }

        return ListView.builder(
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            final transaction = filteredTransactions[index].data() as Map<String, dynamic>;
            final String status = transaction['status'] ?? 'pending'; // Get the transaction status
            final String title = transaction['itemName'] ?? 'No Title';
            final num? itemPrice = transaction['itemPrice']; // Numeric itemPrice from Firestore

            // Navigate to transaction details page when tapped
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TransactionDetailsPage(transactionId: filteredTransactions[index].id),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4.0,
                child: ListTile(
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$status'),
                  trailing: Text(
                    'NGN ${itemPrice?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2F4170),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
