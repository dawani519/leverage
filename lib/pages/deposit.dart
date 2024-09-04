import 'package:flutter/material.dart';
import 'package:leverage/pages/deposit_page/ade_flutterwave.dart';

class AdeFlutterExample extends StatefulWidget {
  const AdeFlutterExample({Key? key}) : super(key: key);

  @override
  State<AdeFlutterExample> createState() => _AdeFlutterExampleState();
}

class _AdeFlutterExampleState extends State<AdeFlutterExample> {
  final TextEditingController _amountController = TextEditingController();
  double _fee = 0.0;
  double _finalAmount = 0.0;

  void _calculateFee() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount < 50000) {
      _fee = amount * 0.03;
    } else if (amount <= 150000) {
      _fee = amount * 0.02;
    } else {
      _fee = amount * 0.015;
    }

    if (_fee < 500) {
      _fee = 500;
    }

    _finalAmount = amount - _fee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          child: Column(
            children: [
              const Text(
                'Deposit Amount',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                onChanged: (value) {
                  setState(() {
                    _calculateFee();
                  });
                },
              ),
              const SizedBox(height: 10),
              Text('Fee: ₦${_fee.toStringAsFixed(2)}'),
              Text('Final Deposit: ₦${_finalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter an amount'),
                      ),
                    );
                    return;
                  }

                  var data = {
                    'amount': _finalAmount.toString(),
                    'payment_options': 'card, banktransfer, ussd',
                    'title': 'Deposit',
                    'currency': "NGN",
                    'tx_ref': "AdeFlutterwave-${DateTime.now().millisecondsSinceEpoch}",
                    'public_key': "FLWPUBK_TEST-45105e89172ec1d36b54f92a232c4472-X",
                    'sk_key': 'FLWSECK_TEST-4213da5c992e3a7a215030af56e93330-X',
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdeFlutterWavePay(data),
                    ),
                  ).then((response) {
                    // Handle the payment response
                  });
                },
                child: const Text('Deposit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
