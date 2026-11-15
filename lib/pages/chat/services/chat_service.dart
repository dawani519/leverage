import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For image upload
import 'package:leverage/pages/chat/models/chat_user.dart';
import 'package:leverage/pages/chat/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Firebase storage for image upload

  // Fetch messages in a chat room
  Stream<List<Message>> getMessages(String chatID) {
    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data() as Map<String, dynamic>;

          // Extract the author field from the data
          final author = ChatUser(
            userID: data['authorID'],
            firstName: data['first_name'],
            surname: data['surname'],
            userRole: data['userRole'],
          );

          return Message.fromMap(data, author, doc.id);
        } catch (e) {
          print("Error parsing message: $e");
          return null; // Handle parsing error gracefully
        }
      }).whereType<Message>().toList(); // Filters out null messages
    });
  }

  // Send a message to the chat and return the doc reference
  Future<DocumentReference> sendMessage(String chatID, Message message) async {
    return await _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .add(message.toMap());
  }

  // Update the messageID field after the message is created in Firestore
  Future<void> updateMessageID(String chatID, String messageID, Message message) async {
    await _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .doc(messageID)
        .update({'messageID': messageID});
  }

  // Create a new chat document in Firestore
  Future<void> createChat(String chatID, List<ChatUser> participants) async {
    await _firestore.collection('chats').doc(chatID).set({
      'participants': participants.map((user) => user.toMap()).toList(),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Upload an image to Firebase Storage and return the image URL
  Future<String> uploadImage(String chatID, File imageFile) async {
    try {
      final storageRef = _storage
          .ref()
          .child('chats/$chatID/${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Return the download URL of the image
      return await snapshot.ref.getDownloadURL();
    } catch (error) {
      print('Error uploading image: $error');
      throw Exception('Image upload failed');
    }
  }

  // Send an image message with the image URL
  Future<void> sendImageMessage(String chatID, ChatUser author, String imageUrl) async {
    final message = Message(
      messageID: '',
      author: author,
      text: '', // No text since it's an image message
      imageUrl: imageUrl,
      messageType: MessageType.image,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final docRef = await sendMessage(chatID, message);
    await updateMessageID(chatID, docRef.id, message);
  }

  // Listen to typing state for a specific chat
  Stream<bool> getTypingState(String chatID, String userID) {
    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('typing')
        .doc(userID)
        .snapshots()
        .map((doc) => doc.exists && doc.data()?['isTyping'] == true);
  }

  // Update typing state
  Future<void> setTypingState(String chatID, String userID, bool isTyping) async {
    await _firestore
        .collection('chats')
        .doc(chatID)
        .collection('typing')
        .doc(userID)
        .set({'isTyping': isTyping});
  }
}
