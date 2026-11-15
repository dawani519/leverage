import 'package:leverage/pages/chat/models/chat_user.dart';

enum MessageType { text, image }

class Message {
  final String messageID;
  final ChatUser author;  // Who sent the message
  final String text;      // Message content (for text messages)
  final String? imageUrl; // URL of the image (for image messages)
  final MessageType messageType; // Either text or image
  final int createdAt;    // Timestamp in milliseconds
  final Message? repliedTo; // Optional reference to another message (replies)

  Message({
    required this.messageID,
    required this.author,
    required this.text,
    this.imageUrl,
    required this.messageType,
    required this.createdAt,
    this.repliedTo,
  });

  // Create a message from a Firestore document
  factory Message.fromMap(Map<String, dynamic> data, ChatUser author, String messageID) {
    return Message(
      messageID: messageID,
      author: author, // Use the provided author
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'], // This can be null for text messages
      messageType: data['messageType'] == 'image' ? MessageType.image : MessageType.text,
      createdAt: data['createdAt'] ?? DateTime.now().millisecondsSinceEpoch,
      repliedTo: data['repliedTo'] != null
          ? Message.fromMap(data['repliedTo'], author, data['repliedTo']['messageID'])
          : null,
    );
  }

  // Convert message instance to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'messageID': messageID,
      'text': text,
      'imageUrl': imageUrl,
      'messageType': messageType == MessageType.image ? 'image' : 'text',
      'createdAt': createdAt,
      'repliedTo': repliedTo?.toMap(),
      'authorID': author.userID, // Store author ID as a field
      'first_name': author.firstName, // Store author's first name
      'surname': author.surname, // Store author's surname
      'userRole': author.userRole, // Store author's role
    };
  }

  // Add the copyWith method
  Message copyWith({
    String? messageID,
    String? text,
    ChatUser? author,
    String? imageUrl,
    MessageType? messageType,
    int? createdAt,
    Message? repliedTo,
  }) {
    return Message(
      messageID: messageID ?? this.messageID,
      text: text ?? this.text,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      messageType: messageType ?? this.messageType,
      createdAt: createdAt ?? this.createdAt,
      repliedTo: repliedTo ?? this.repliedTo,
    );
  }
}