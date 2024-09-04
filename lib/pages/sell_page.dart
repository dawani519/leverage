import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  _SellPageState createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  String? _category;
  String? _listingType = 'Single Item';
  String? _condition = 'New';
  bool _offerShipping = false;
  bool _offerLeverageFee = false;
  File? _image;

  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sell",
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Category'),
            DropdownButton<String>(
              value: _category,
              isExpanded: true,
              hint: const Text('Select Category'),
              items: <String>['Electronics', 'Fashion', 'Home', 'Sports']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _category = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('What are you selling?'),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Item Name',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Price (in Naira)'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter Price',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Location'),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter Location',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Condition'),
            DropdownButton<String>(
              value: _condition,
              isExpanded: true,
              items: <String>[
                'New',
                'Used',
                'Used Fairly',
                'Used Like New',
                'Used Poorly'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _condition = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('List as'),
            DropdownButton<String>(
              value: _listingType,
              isExpanded: true,
              items: <String>['Single Item', 'Stock'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _listingType = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text('Description'),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter Description',
              ),
            ),
            const SizedBox(height: 16.0),
            const Text('Product Image'),
            _image == null
                ? TextButton(
              onPressed: _pickImage,
              child: const Text('Upload Image'),
            )
                : Image.file(_image!),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Offer Shipping'),
                Switch(
                  value: _offerShipping,
                  onChanged: (value) {
                    setState(() {
                      _offerShipping = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Offer Leverage Fee'),
                Switch(
                  value: _offerLeverageFee,
                  onChanged: (value) {
                    setState(() {
                      _offerLeverageFee = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle submit action
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
