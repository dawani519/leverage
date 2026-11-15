import 'package:flutter/material.dart';
import 'package:leverage/pages/chat/models/message.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;
  final VoidCallback onAvatarTap; // Callback for avatar tap

  const MessageItem({
    Key? key,
    required this.message,
    required this.isOwnMessage,
    required this.onAvatarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isOwnMessage) // Show avatar only for opposite user
          GestureDetector(
            onTap: onAvatarTap,
            child: const CircleAvatar(
              child: Icon(Icons.person), // Use a placeholder avatar icon
            ),
          ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: isOwnMessage ? Colors.blue[100] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message.text),
        ),
      ],
    );
  }
}
