import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text('Notifications',
        style: TextStyle(
          color: Color(0xFFF2F7FA)
        ),),
        backgroundColor: const Color(0xFF2F4170),
      ),
      body: const Center(
        child: Text('No new notifications'),
      ),
    );
  }
}
