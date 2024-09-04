import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Chat'),
        titleTextStyle: const TextStyle(color: Colors.blue),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('No new chats'),
      ),
    );
  }
}
