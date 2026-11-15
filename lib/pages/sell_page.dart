import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leverage/pages/homepage.dart'; // Import your homepage file here

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
  List<File> _images = [];
  final _picker = ImagePicker();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 10 images allowed')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitProduct() async {
    if (_images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum of 3 images required')),
      );
      return;
    }

    // Get the current user's UID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to sell a product')),
      );
      return;
    }
    String sellerId = user.uid;

    // Upload images to Firebase Storage
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('products/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    // Store product details in Firestore
    await FirebaseFirestore.instance.collection('products').add({
      'category': _category,
      'itemName': _itemNameController.text,
      'price': int.parse(_priceController.text),
      'location': _locationController.text,
      'condition': _condition,
      'listingType': _listingType,
      'description': _descriptionController.text,
      'offerShipping': _offerShipping,
      'offerLeverageFee': _offerLeverageFee,
      'imageUrls': imageUrls,
      'timestamp': FieldValue.serverTimestamp(),
      'sellerId': sellerId,  // Add the sellerId here
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product listed successfully')),
    );

    // Navigate back to the homepage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()), // Replace with your Homepage class
          (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text('Sell',
        style: TextStyle(
          color: Color(0xFFF2F7FA)
        ),),
        backgroundColor: Color(0xFF2F4170),
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
              controller: _itemNameController,
              decoration: const InputDecoration(hintText: 'Item Name'),
            ),
            const SizedBox(height: 16.0),
            const Text('Price (in Naira)'),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Enter Price'),
            ),
            const SizedBox(height: 16.0),
            const Text('Location'),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(hintText: 'Enter Location'),
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
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Enter Description'),
            ),
            const SizedBox(height: 16.0),
            const Text('Product Images'),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length + 1,
                itemBuilder: (context, index) {
                  if (index == _images.length) {
                    return GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add),
                      ),
                    );
                  } else {
                    return Stack(
                      children: [
                        Image.file(
                          _images[index],
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                            child: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
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
              onPressed: _submitProduct,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
