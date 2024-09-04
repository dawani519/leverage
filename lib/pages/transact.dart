import 'package:flutter/material.dart';

class TransactPage extends StatelessWidget {
  const TransactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transact Page'),
      ),
      body: const TransactForm(),
    );
  }
}

class TransactForm extends StatefulWidget {
  const TransactForm({super.key});

  @override
  _TransactFormState createState() => _TransactFormState();
}

class _TransactFormState extends State<TransactForm> {
  final _formKey = GlobalKey<FormState>(); // Global key to identify the form

  String? _selectedRole;
  String? _selectedCurrency;
  String? _selectedCategory;
  String? _selectedShippingMethod;
  String? _selectedShippingFeePayer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey, // Assign the key to the form
        child: ListView(
          children: [
            const Text(
              'Transaction Title',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Transaction Title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a transaction title'; // Validation logic
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'buyer',
                        child: Text('Buyer'),
                      ),
                      DropdownMenuItem(
                        value: 'seller',
                        child: Text('Seller'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a role';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'usd',
                        child: Text('USD'),
                      ),
                      DropdownMenuItem(
                        value: 'ngn',
                        child: Text('Naira'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a currency';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Transaction Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item Price',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Item Category',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'electronics',
                  child: Text('Electronics'),
                ),
                DropdownMenuItem(
                  value: 'clothing',
                  child: Text('Clothing'),
                ),
                DropdownMenuItem(
                  value: 'furniture',
                  child: Text('Furniture'),
                ),
                DropdownMenuItem(
                  value: 'books',
                  child: Text('Books'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an item category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Item Description',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an item description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Shipping',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DropdownButtonFormField<String>(
              value: _selectedShippingMethod,
              decoration: const InputDecoration(
                labelText: 'Shipping Method',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'standard',
                  child: Text('Standard Shipping'),
                ),
                DropdownMenuItem(
                  value: 'waybill',
                  child: Text('Waybill'),
                ),
                DropdownMenuItem(
                  value: 'dispatch',
                  child: Text('Dispatch Rider'),
                ),
                DropdownMenuItem(
                  value: 'cargo',
                  child: Text('Cargo Shipping'),
                ),
                DropdownMenuItem(
                  value: 'no_shipping',
                  child: Text('No Shipping'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedShippingMethod = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a shipping method';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            if (_selectedShippingMethod == 'waybill' ||
                _selectedShippingMethod == 'dispatch') ...[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Driver/Dispatch Rider Name',
                ),
                validator: (value) {
                  if (_selectedShippingMethod == 'waybill' ||
                      _selectedShippingMethod == 'dispatch') {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the driver/dispatch rider name';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Driver/Dispatch Rider Phone Number',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (_selectedShippingMethod == 'waybill' ||
                      _selectedShippingMethod == 'dispatch') {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the driver/dispatch rider phone number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
            ],
            DropdownButtonFormField<String>(
              value: _selectedShippingFeePayer,
              decoration: const InputDecoration(
                labelText: 'Shipping Fee Paid By',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'buyer',
                  child: Text('Buyer'),
                ),
                DropdownMenuItem(
                  value: 'seller',
                  child: Text('Seller'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedShippingFeePayer = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select who pays the shipping fee';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Process the transaction
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
