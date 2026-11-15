import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:leverage/pages/more/transactions/transaction_details.dart';

class TransactPage extends StatelessWidget {
  const TransactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      body: const TransactForm(),
    );
  }
}

class TransactForm extends StatefulWidget {
  const TransactForm({super.key});

  @override
  _TransactFormState createState() => _TransactFormState();
}

class _TransactFormState extends State<TransactForm>
    with AutomaticKeepAliveClientMixin<TransactForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form fields
  String? _transactionType;
  String? _selectedRole;
  String? _selectedCategory;
  String? _itemName;
  double? _itemPrice;
  int _itemQuantity = 1;
  String _description = '';
  int _remainingCharacters = 300;
  String? _selectedShippingFeePayer;
  String? _selectedDisputeResolutionMethod;
  String? _inspectionPeriod;
  String? _attachedFilePath;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_formatPrice);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _formatPrice() {
    String currentText = _priceController.text.replaceAll(',', ''); // Remove commas
    if (currentText.isEmpty) return;

    // Parse the string to a double (after removing commas)
    double price = double.tryParse(currentText) ?? 0.0; // Default to 0.0 if parsing fails
    _itemPrice = price; // Store the price as a double

    // Format the price for display (with commas)
    final formattedPrice = NumberFormat('#,##0').format(price);

    // Update the controller with the formatted price
    _priceController.value = TextEditingValue(
      text: formattedPrice,
      selection: TextSelection.collapsed(offset: formattedPrice.length),
    );
  }



  Widget customInputField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
    TextEditingController? controller,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: isMultiline ? 120 : 50,
      decoration: BoxDecoration(
        color: const Color(0xFFCFEBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: isMultiline ? 3 : 1,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a $label';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _attachedFilePath = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File attached: ${result.files.single.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
          key: _formKey,
          child: ListView(
            children: [
            dropdownField(
            label: 'Transaction Type',
            value: _transactionType,
            items: const ['One-Time Transaction', 'Milestone Transaction'],
            onChanged: (value) => setState(() => _transactionType = value),
          ),
          const SizedBox(height: 16.0),

          Row(
            children: [
              Expanded(
                child: dropdownField(
                  label: 'Role',
                  value: _selectedRole,
                  items: const ['Buyer', 'Seller'],
                  onChanged: (value) => setState(() => _selectedRole = value),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: dropdownField(
                  label: 'Item Category',
                  value: _selectedCategory,
                  items: const [
                    'Electronics',
                    'Clothing',
                    'Furniture',
                    'Books',
                    'Other'
                  ],
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          customInputField(
            label: _selectedRole == 'Buyer' ? 'Seller Email' : 'Buyer Email',
            onChanged: (value) {},
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 16.0),
          customInputField(
            label: _selectedRole == 'Buyer' ? 'Seller Name' : 'Buyer Name',
            onChanged: (value) {},
            controller: _nameController,
          ),
          const SizedBox(height: 16.0),
          customInputField(
            label: 'Phone Number',
            onChanged: (value) {},
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(height: 16.0),

          customInputField(
            label: 'Item Name',
            onChanged: (value) => _itemName = value,
          ),
              const SizedBox(height: 16.0),
              customInputField(
                label: 'Item Price',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _itemPrice = double.tryParse(value.replaceAll(',', ''));
                  } else {
                    _itemPrice = null; // If empty, set to null
                  }
                },
                keyboardType: TextInputType.number,
                controller: _priceController,
              ),
              const SizedBox(height: 16.0),
          customInputField(
            label: 'Item Quantity',
            onChanged: (value) {
              setState(() => _itemQuantity = int.parse(value));
            },
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFCFEBFF),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLength: 300,
              onChanged: (value) {
                setState(() {
                  _description = value;
                  _remainingCharacters = 300 - value.length;
                });
              },
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Agreement/Description',
                border: InputBorder.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text('$_remainingCharacters/300',
                style: const TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 16.0),

          InkWell(
            onTap: _pickFile,
            child: Text(
              _attachedFilePath == null
                  ? 'Attach agreement document here'
                  : 'File attached: ${_attachedFilePath!.split('/').last}',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          customInputField(
            label: 'Inspection Period (days)',
            onChanged: (value) => _inspectionPeriod = value,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16.0),
          dropdownField(
            label: 'Shipping Fee Paid By',
            value: _selectedShippingFeePayer,
            items: const ['Me', 'Customer'],
            onChanged: (value) => setState(() => _selectedShippingFeePayer = value),
          ),
          const SizedBox(height: 16.0),

          dropdownField(
            label: 'Dispute Resolution Method',
            value: _selectedDisputeResolutionMethod,
            items: const ['Leverage', 'Arbitration'],
            onChanged: (value) =>
                setState(() => _selectedDisputeResolutionMethod = value),
          ),
          const SizedBox(height: 16.0),

          ElevatedButton(
          style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 40),
            backgroundColor: const Color(0xFF2F4170),
          ),
            onPressed: () async {
            if (_formKey.currentState!.validate()) {
              User? currentUser = _auth.currentUser;
              if (currentUser != null) {
                String? sellerId = _selectedRole == 'Seller' ? currentUser.uid : null;
                String? buyerId = _selectedRole == 'Buyer' ? currentUser.uid : null;

                String status = _selectedRole == 'Buyer' ? 'Awaiting Payment' : 'Make Payment';

                DocumentReference transactionRef = await _firestore.collection('transactions').add({
                  'transactionType': _transactionType,
                  'role': _selectedRole,
                  'itemCategory': _selectedCategory,
                  'itemName': _itemName,
                  'itemPrice': _itemPrice,
                  'itemQuantity': _itemQuantity,
                  'description': _description,
                  'inspectionPeriod': int.tryParse(_inspectionPeriod ?? '') ?? 0,
                  'shippingFeePayer': _selectedShippingFeePayer,
                  'disputeResolutionMethod': _selectedDisputeResolutionMethod,
                  'sellerId': sellerId,
                  'buyerId': buyerId,
                  'email': _emailController.text,
                  'name': _nameController.text,
                  'phone': _phoneController.text,
                  'attachedFilePath': _attachedFilePath,
                  'status': status,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                String transactionId = transactionRef.id;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction Created Successfully')),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionDetailsPage(transactionId: transactionId),
                  ),
                );
              }
            }
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
            ],
          ),
      ),
    );
  }

  Widget dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFCFEBFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
