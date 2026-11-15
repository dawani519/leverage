import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you have this package added to your pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart';

class BrokerPage extends StatefulWidget {
  const BrokerPage({super.key});

  @override
  State<BrokerPage> createState() => _BrokerPageState();
}

class _BrokerPageState extends State<BrokerPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? currentUser;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser; // Get the current user
    fetchTransactions(); // Fetch transactions from Firestore
  }

  Future<void> fetchTransactions() async {
    // Fetch transactions related to the current broker user
    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .where('brokerID', isEqualTo: currentUser!.uid) // Assuming brokerId is stored as user ID
        .get();

    setState(() {
      transactions = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  void verifyProfile() {
    // Logic for verification, this could redirect to a verification page
    Navigator.pushNamed(context, '/verification'); // Change this to your actual verification route
  }

  void acceptTransaction(String transactionId) {
    // Logic to accept the transaction
    Navigator.pushNamed(context, '/transactionDetails', arguments: transactionId); // Change this to your actual transaction details route
  }

  void rejectTransaction(String transactionId) {
    // Logic to reject the transaction (could be an update to Firestore or just remove it from the list)
    _firestore.collection('transactions').doc(transactionId).update({'status': 'rejected'}).then((_) {
      fetchTransactions(); // Refresh transaction list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broker Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verify Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('Verify'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Ongoing Transactions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Transaction ID: ${transaction['transactionId']}'),
                      subtitle: Text('Amount: ${transaction['amount']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            color: Colors.green,
                            onPressed: () => acceptTransaction(transaction['transactionId']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () => rejectTransaction(transaction['transactionId']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
