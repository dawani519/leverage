import 'package:flutter/material.dart';
import 'package:leverage/pages/chat/models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user info
            Text(
              '${message.author.firstName} ${message.author.surname}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.blue[900] : Colors.black87,
              ),
            ),
            const SizedBox(height: 5),

            // Check if message has media (image or other file)
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Handle media preview or download
                },
                child: Image.network(
                  message.imageUrl!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.imageUrl == null || message.imageUrl!.isEmpty)
              Text(
                message.text,
                style: const TextStyle(color: Colors.black),
              ),

            const SizedBox(height: 5),
            Text(
              _formatTimestamp(message.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
