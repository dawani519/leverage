import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:leverage/pages/chat/models/chat_user.dart';
import 'package:leverage/pages/chat/models/chat_arguments.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user == null) {
      return Scaffold(
        body: const Center(
          child: Text('Please log in to view your chats.'),
        ),
      );
    }

    final userId = user.uid;

    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(color: Color(0xFFF2F7FA)),
        ),
        backgroundColor: Color(0xFF2F4170),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading chats.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No chats available. Start a new transaction to create chats!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          var chatDocuments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocuments.length,
            itemBuilder: (context, index) {
              var chatData = chatDocuments[index];
              var participants = chatData['participants'] as List<dynamic>;

              // Retrieve lastMessage, lastUpdated, and productName fields
              var chatDataMap = chatData.data() as Map<String, dynamic>?; // Nullable check
              var lastMessage = chatDataMap?['lastMessage'] ?? 'No messages yet';
              var lastUpdated = chatDataMap?['lastUpdated'] != null
                  ? (chatDataMap!['lastUpdated'] as Timestamp).toDate()
                  : DateTime.now();
              var productName = chatDataMap?['productName'] ?? 'Chat';

              return FutureBuilder<String>(
                future: getOtherParticipantName(participants, userId),
                builder: (context, nameSnapshot) {
                  if (!nameSnapshot.hasData) {
                    return const ListTile(
                      leading: Icon(Icons.chat),
                      title: Text('Loading...'),
                      subtitle: Text('Fetching participant information...'),
                    );
                  }

                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(nameSnapshot.data ?? 'Unknown'),
                    subtitle: Text(lastMessage),
                    trailing: Text(
                      formatDate(lastUpdated),
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      // Create an instance of ChatUser for the current user
                      ChatUser currentUser = ChatUser.fromMap({
                        'first_name': user.displayName?.split(' ').first ?? '',
                        'surname': (user.displayName != null &&
                            user.displayName!.split(' ').length > 1)
                            ? user.displayName!.split(' ').last
                            : '', // Logic to get user's surname
                        'userRole': 'buyer', // or whichever role is appropriate
                      }, userId);

                      // Navigate to ChatScreen with required arguments, including productName
                      Navigator.pushNamed(
                        context,
                        '/chatScreen',
                        arguments: ChatArguments(
                          chatID: chatData.id,
                          currentUser: currentUser,
                          productName: productName, // Pass productName here
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to find the other participant's name in the chat
  Future<String> getOtherParticipantName(List<dynamic> participants, String currentUserId) async {
    String otherParticipantId = participants.firstWhere(
          (participant) => participant != currentUserId,
      orElse: () => 'Unknown',
    );

    if (otherParticipantId == 'Unknown') {
      return 'Unknown';
    }

    // Retrieve other participant's full name from Firestore
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(otherParticipantId).get();
    if (userDoc.exists) {
      var userData = userDoc.data() as Map<String, dynamic>;
      String firstName = userData['first_name'] ?? 'Unknown';
      String middleName = userData['middle_name'] ?? ''; // optional field
      String surname = userData['surname'] ?? 'Unknown';
      return '$firstName $middleName $surname'.trim();
    } else {
      return 'Unknown';
    }
  }

  // Helper function to format date
  String formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
