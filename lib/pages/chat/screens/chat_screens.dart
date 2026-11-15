import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leverage/pages/chat/models/chat_user.dart';
import 'package:leverage/pages/chat/models/message.dart';
import 'package:leverage/pages/chat/services/chat_service.dart';
import 'package:leverage/pages/chat/widgets/chat_input.dart';
import 'package:leverage/pages/chat/widgets/message_item.dart';
import 'package:leverage/pages/chat/userProfile.dart';

class ChatScreen extends StatefulWidget {
  final String chatID;
  final ChatUser currentUser;
  final String? productName;

  const ChatScreen({
    Key? key,
    required this.chatID,
    required this.currentUser,
    this.productName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatService _chatService;
  late final Stream<List<Message>> _messageStream;

  String? _productName;
  String _oppositeUserId = '';
  String _oppositeUserName = '';

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    _messageStream = _chatService.getMessages(widget.chatID);
    _productName = widget.productName ?? 'Chat';
    _loadOppositeUserDetails();
  }

  // Load opposite user details
  Future<void> _loadOppositeUserDetails() async {
    try {
      final chatDoc = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatID)
          .get();

      if (chatDoc.exists) {
        final participantIDs = chatDoc['participants'] ?? [];
        _oppositeUserId = participantIDs.firstWhere(
              (id) => id != widget.currentUser.userID,
          orElse: () => '',
        );

        if (_oppositeUserId.isNotEmpty) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(_oppositeUserId)
              .get();
          setState(() {
            _oppositeUserName = '${userDoc['first_name']} ${userDoc['surname']}';
          });
        }
      }
    } catch (error) {
      print('Error loading opposite user details: $error');
    }
  }

  // Method to send a message
  Future<void> _sendMessage(String messageText) async {
    try {
      final newMessage = Message(
        messageID: '',
        author: widget.currentUser,
        text: messageText,
        messageType: MessageType.text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      final docRef = await _chatService.sendMessage(widget.chatID, newMessage);
      await _chatService.updateMessageID(widget.chatID, docRef.id, newMessage.copyWith(messageID: docRef.id));
      await FirebaseFirestore.instance.collection('chats').doc(widget.chatID).update({
        'lastMessage': messageText,
        'lastUpdated': Timestamp.now(),
      });
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  // Select and upload an image
  Future<void> _handleAttachmentPressed() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final File imageFile = File(image.path);
      final imageUrl = await _chatService.uploadImage(widget.chatID, imageFile);

      await _sendImageMessage(imageUrl);
    } catch (error) {
      print('Error handling attachment: $error');
    }
  }

  // Send image message after upload
  Future<void> _sendImageMessage(String imageUrl) async {
    final imageMessage = Message(
      messageID: '',
      author: widget.currentUser,
      text: '',
      messageType: MessageType.image,
      imageUrl: imageUrl,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final docRef = await _chatService.sendMessage(widget.chatID, imageMessage);
    await _chatService.updateMessageID(widget.chatID, docRef.id, imageMessage.copyWith(messageID: docRef.id));

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatID).update({
      'lastMessage': '[Image]',
      'lastUpdated': Timestamp.now(),
    });
  }

  // Navigate to the user profile
  void _navigateToUserProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfilePage(userId: _oppositeUserId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: Text(_productName ?? 'Chat'),
        backgroundColor: const Color(0xFF2F4170),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageItem(
                      message: message,
                      isOwnMessage: message.author.userID == widget.currentUser.userID,
                      onAvatarTap: () => _navigateToUserProfile(context),
                    );
                  },
                );
              },
            ),
          ),
          ChatInput(
            onSendPressed: _sendMessage, // Directly linked to the attachment handler
            onImageSelected: (String imagePath) {},
          ),
        ],
      ),
    );
  }
}
