import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leverage/pages/chat/screens/chat_screens.dart';
import 'package:leverage/pages/chat/models/chat_user.dart';
import 'package:leverage/pages/chat/models/chat_arguments.dart';
import 'package:leverage/pages/transact.dart';
import 'package:leverage/pages/chat/userProfile.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productName;
  final List<String> productImages;
  final num price;
  final String location;
  final String condition;
  final String listingType;
  final String description;
  final bool offerShipping;
  final bool offerLeverageFee;
  final String sellerId;

  const ProductDetailsPage({
    Key? key,
    required this.productName,
    required this.productImages,
    required this.price,
    required this.location,
    required this.condition,
    required this.listingType,
    required this.description,
    required this.offerShipping,
    required this.offerLeverageFee,
    required this.sellerId,
  }) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<Map<String, dynamic>> reviews = [];
  final TextEditingController _messageController = TextEditingController();

  String _sellerFullName = '';
  String _buyerFullName = '';
  String? _buyerId;

  String _sellerFirstName = '';
  String _sellerSurname = '';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _buyerId = FirebaseAuth.instance.currentUser?.uid;

    if (_buyerId != null) {
      _getSellerDetails();
      _getBuyerFullName();
    } else {
      setState(() {
        _errorMessage = 'User not authenticated. Please log in.';
        _isLoading = false;
      });
    }
  }

  Future<void> _getSellerDetails() async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.sellerId).get();
      if (userDoc.exists) {
        setState(() {
          _sellerFirstName = userDoc['first_name'] ?? '';
          _sellerSurname = userDoc['surname'] ?? '';
          _sellerFullName = '$_sellerFirstName $_sellerSurname';
        });
      } else {
        setState(() {
          _errorMessage = 'Seller not found for ID: ${widget.sellerId}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching seller details: $error';
      });
    }
    _checkLoadingStatus();
  }

  Future<void> _getBuyerFullName() async {
    if (_buyerId != null) {
      try {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(_buyerId).get();
        if (userDoc.exists) {
          setState(() {
            _buyerFullName = '${userDoc['first_name']} ${userDoc['middle_name'] ?? ''} ${userDoc['surname']}'.trim();
          });
        } else {
          setState(() {
            _errorMessage = 'Buyer not found';
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'Error fetching buyer details: $error';
        });
      }
    }
    _checkLoadingStatus();
  }

  void _checkLoadingStatus() {
    if (_buyerFullName.isNotEmpty && _sellerFullName.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
      print('Buyer: $_buyerFullName');
      print('Seller: $_sellerFullName');
    }
  }

  Future<String> _getOrCreateChatID(String buyerId, String sellerId, String buyerName, String sellerName, String productName) async {
    try {
      var chatQuery = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: buyerId)
          .get();

      // Check if a chat between these participants already exists
      if (chatQuery.docs.isNotEmpty) {
        for (var doc in chatQuery.docs) {
          if (doc['participants'].contains(sellerId)) {
            // Return existing chat ID
            return doc.id;
          }
        }
      }

      // No existing chat found, create a new one with productName
      DocumentReference newChat = await FirebaseFirestore.instance.collection('chats').add({
        'participants': [buyerId, sellerId],
        'participantNames': [buyerName, sellerName],
        'productName': productName, // Add product name to new chat document
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Log to confirm document creation
      print("Created new chat with ID: ${newChat.id} and productName: $productName");

      return newChat.id;
    } catch (error) {
      print('Error creating or retrieving chat ID: $error');
      rethrow; // Rethrow the error after logging
    }
  }

  Future<void> _sendMessage(BuildContext context, ChatArguments chatArgs) async {
    if (_messageController.text.isNotEmpty && _buyerFullName.isNotEmpty && _sellerFullName.isNotEmpty && _buyerId != null) {
      try {
        String chatID = await _getOrCreateChatID(
            _buyerId!,
            widget.sellerId,
            _buyerFullName,
            _sellerFullName,
            chatArgs.productName // Use productName from chatArgs
        );

        // Create message within the chat document
        var messageRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(chatID)
            .collection('messages')
            .doc();

        await messageRef.set({
          'authorName': _buyerFullName,
          'text': _messageController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'messageID': messageRef.id,
          'messageType': 'text',
          'imageUrl': null,
        });

        // Update the chat document with the last message and last updated timestamp
        await FirebaseFirestore.instance.collection('chats').doc(chatID).update({
          'lastMessage': _messageController.text, // Update with the last message text
          'lastUpdated': FieldValue.serverTimestamp(), // Set last updated timestamp
        });

        // Clear message input after sending
        _messageController.clear();

        // Log navigation action
        print("Navigating to ChatScreen with chatID: $chatID and productName: ${chatArgs.productName}");

        // Navigate to ChatScreen and pass ChatArguments
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatID: chatID,
              currentUser: chatArgs.currentUser,
              productName: chatArgs.productName, // Use productName from chatArgs
            ),
          ),
        );
      } catch (error) {
        print('Error sending message: $error');
      }
    } else {
      print('Message input is empty or names are not loaded');
    }
  }
  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: widget.sellerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
        child: Column(
          children: [
            // Product images slider
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: widget.productImages.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(imageUrl: image),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),

            // Product details section
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                borderRadius: BorderRadius.circular(12)
              ),
              width: 350,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.productName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Price: ₦${widget.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on, // Location icon
                          color: Colors.black, // Match color to the text
                          size: 18, // Adjust size as needed
                        ),
                        const SizedBox(width: 4), // Space between icon and text
                        Text(
                          '${widget.location}',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    // Seller name (Moved up)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _navigateToUserProfile(context),  // Add onTap to trigger navigation
                          child: const CircleAvatar(
                            child: Icon(Icons.person), // Placeholder avatar icon
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_sellerFullName',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),


                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey, // Background color
                        borderRadius: BorderRadius.circular(12), // Rounded corners with 12 radius
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12), // Optional padding inside container
                      child: TextField(
                        controller: _messageController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Removes all border lines
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'Write message here...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          contentPadding: EdgeInsets.all(10), // Adjust padding inside the text field
                        ),
                      ),
                    ),

                    const SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.centerRight, // Aligns the button to the left
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4170), // Set the background color to 0xFF2F4170
                        ),
                        onPressed: () {
                          // Create ChatUser instance
                          ChatUser currentUser = ChatUser(
                            userID: _buyerId!,
                            firstName: _buyerFullName.split(' ').first,
                            surname: _buyerFullName.split(' ').last,
                            userRole: 'buyer',
                          );

                          // Create ChatArguments instance
                          ChatArguments chatArgs = ChatArguments(
                            chatID: '', // Initialize this as needed
                            currentUser: currentUser,
                            productName: widget.productName, // Pass productName from widget
                          );

                          // Call _sendMessage with context and chatArgs
                          _sendMessage(context, chatArgs);
                        },
                        child: const Text(
                          'Send',
                          style: TextStyle(
                            color: Color(0xFFF2F7FA), // Text color
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the left if desired
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.underline, // Adds an underline
                          ),
                        ),
                        const SizedBox(width:14),
                        Text(
                          '${widget.description}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8.0),
                    // The rest of the product details (same as before)
                    Text(
                      'Condition: ${widget.condition}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Listing Type: ${widget.listingType}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.offerShipping ? 'Shipping Available' : 'No Shipping',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.offerLeverageFee ? 'Leverage Fee Supported' : 'Leverage Fee Not Supported',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16.0),

                    Align(
                      alignment: Alignment.centerRight, // Aligns the button to the right
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F4170), // Set the background color to 0xFF2F4170
                        ),
                        onPressed: () {
                          // Navigate to the TransactPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TransactPage()),
                          );
                        },
                        child: const Text(
                          'Transact',
                          style: TextStyle(
                            color: Color(0xFFF2F7FA), // Text color
                          ),
                        ),
                      ),
                    )


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
