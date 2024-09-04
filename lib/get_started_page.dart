// get_started_page.dart
import 'package:flutter/material.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue, // text color
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('Get Started'),
        ),
      ),
    );
  }
}
