import 'dart:math';
import 'package:flutter/material.dart';
import 'package:leverage/pages/deposit/api_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DepositPage extends StatefulWidget {
  final String title;
  final String email; // Email passed from the homepage

  const DepositPage({
    super.key,
    required this.title,
    required this.email,
  });

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage> {
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false; // Track loading state
  String email = ''; // Initialize email with an empty string

  @override
  void initState() {
    super.initState();
    // If email is not passed, fetch the current user's email from Firebase
    if (widget.email.isEmpty) {
      getCurrentUserEmail();
    } else {
      email = widget.email;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // Fetch the current user's email from Firebase Authentication
  Future<void> getCurrentUserEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          email = user.email ?? ''; // Get email or set empty string
        });
      } else {
        // Handle case where user is not logged in
        showSnackbar('No user is logged in.');
      }
    } catch (e) {
      showSnackbar('Failed to fetch user email: $e');
    }
  }

  String generateRef() {
    // Generate a unique reference for the transaction
    final randomCode = Random().nextInt(1000000);
    return 'ref-${randomCode.toString().padLeft(6, '0')}';
  }

  Future<void> startPayment() async {
    if (isLoading) return; // Prevent multiple submissions
    setState(() {
      isLoading = true;
    });

    // Validate amount input
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      showSnackbar('Please enter a valid amount.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showSnackbar('Please enter a valid amount greater than 0.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final ref = generateRef();

    try {
      // Initialize payment via API
      final response = await PaystackAPI.initializeTransaction(
        email: email, // Use the email (either passed or fetched)
        amount: amount * 100, // Convert amount to kobo
        reference: ref,
      );

      if (response['status'] == true) {
        final paymentUrl = response['data']['authorization_url'];
        debugPrint('Redirecting to payment URL: $paymentUrl');

        // Redirect user to the payment page
        await PaystackAPI.openPaymentUrl(context, paymentUrl);

        // After user completes the payment, verify it
        await verifyPayment(ref);
      } else {
        debugPrint('Failed to initialize payment: ${response['message']}');
        showSnackbar('Error: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error during payment process: $e');
      showSnackbar('An error occurred while processing the payment.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> verifyPayment(String reference) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    try {
      // Verify the transaction status
      final response = await PaystackAPI.verifyTransaction(reference);

      if (response['status'] == true) {
        final amount = response['data']['amount'];

        // Send the verified transaction to the backend
        await PaystackAPI.sendTransactionToBackend(
          reference: reference,
          email: email,
          amount: amount,
          verified: true,
        );

        showSuccessDialog('Payment verified successfully and recorded!');
        amountController.clear(); // Clear the input on success
      } else {
        debugPrint('Payment verification failed: ${response['message']}');
        showSnackbar('Error: ${response['message']}');
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      showSnackbar('An error occurred during payment verification.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ensure email is available before rendering the text
                if (email.isNotEmpty)
                  Text(
                    'Depositing as: $email',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (₦)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: isLoading ? null : startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading ? Colors.grey : Colors.blue,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isLoading
                          ? 'Processing...'
                          : 'Pay ${amountController.text.isEmpty ? '' : '\u20A6${amountController.text}'} with Paystack',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
