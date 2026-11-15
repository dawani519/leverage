import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leverage/pages/chat/screens/chat_screens.dart';
import 'package:leverage/pages/chat/models/chat_user.dart';

class ListingsPage extends StatefulWidget {
  final String userId; // Add userId as a parameter

  ListingsPage({required this.userId});

  get productName => null; // Required constructor to accept userId

  @override
  _ListingsPageState createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  String _buyerFullName = '';
  String? _buyerId;

  @override
  void initState() {
    super.initState();
    _buyerId = widget.userId; // Use the passed userId instead of fetching from FirebaseAuth

    if (_buyerId != null) {
      _getBuyerFullName();
    }
  }

  Future<void> _getBuyerFullName() async {
    if (_buyerId != null) {
      try {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(_buyerId).get();
        if (userDoc.exists) {
          setState(() {
            _buyerFullName = '${userDoc['first_name']} ${userDoc['middle_name'] ?? ''} ${userDoc['surname']}'.trim();
          });
        }
      } catch (error) {
        print('Error fetching buyer details: $error');
      }
    }
  }

  Future<String> _getSellerFullName(String sellerId) async {
    try {
      var sellerDoc = await FirebaseFirestore.instance.collection('users').doc(sellerId).get();
      if (sellerDoc.exists) {
        String firstName = sellerDoc['first_name'] ?? '';
        String middleName = sellerDoc['middle_name'] ?? '';
        String surname = sellerDoc['surname'] ?? '';
        return '$firstName $middleName $surname'.trim();
      }
    } catch (error) {
      print('Error fetching seller details: $error');
    }
    return 'Unknown Seller';
  }

  Future<String> _getOrCreateChatID(String buyerId, String sellerId, String buyerName, String sellerName) async {
    var chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: buyerId)
        .get();

    if (chatQuery.docs.isNotEmpty) {
      for (var doc in chatQuery.docs) {
        if (doc['participants'].contains(sellerId)) {
          return doc.id;
        }
      }
    }

    DocumentReference newChat = await FirebaseFirestore.instance.collection('chats').add({
      'participants': [buyerId, sellerId],
      'participantNames': [buyerName, sellerName],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }

  Future<void> _sendMessage(BuildContext context, String sellerId, String sellerName, String messageText) async {
    if (messageText.isNotEmpty && _buyerFullName.isNotEmpty && _buyerId != null) {
      String chatID = await _getOrCreateChatID(_buyerId!, sellerId, _buyerFullName, sellerName);

      try {
        var messageRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(chatID)
            .collection('messages')
            .doc();

        await messageRef.set({
          'authorName': _buyerFullName,
          'text': messageText,
          'createdAt': FieldValue.serverTimestamp(),
          'messageID': messageRef.id,
          'messageType': 'text',
          'imageUrl': null,
        });

        ChatUser currentUser = ChatUser(
          userID: _buyerId!,
          firstName: _buyerFullName.split(' ').first,
          surname: _buyerFullName.split(' ').last,
          userRole: 'buyer',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(chatID: chatID, currentUser: currentUser, productName: widget.productName,),
          ),
        );
      } catch (error) {
        print('Error sending message: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: Text('Listings',
        style: TextStyle(
          color: Color(0xFFF2F7FA)
        ),),
        backgroundColor: Color(0xFF2F4170),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: _buyerId)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No listings found.'));
          }

          var products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var itemName = product['itemName'] ?? 'Unnamed Product';
              var imageUrl = (product['imageUrls'] as List<dynamic>).isNotEmpty
                  ? product['imageUrls'][0]
                  : 'https://via.placeholder.com/150'; // Placeholder if no image is available
              var sellerId = product['sellerId'];

              return FutureBuilder<String>(
                future: _getSellerFullName(sellerId), // Fetch the seller's name using sellerId
                builder: (context, sellerSnapshot) {
                  if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var sellerName = sellerSnapshot.data ?? 'Unknown Seller';

                  return Card(
                    child: ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      title: Text(itemName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('Send message:'),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Type a message...',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send,
                                color: Color(0xFF2F4170),),
                                onPressed: () {
                                  _sendMessage(
                                    context,
                                    sellerId,
                                    sellerName,
                                    'Hi, I am interested in your product.',
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
