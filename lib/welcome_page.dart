import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA), // Background color
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100), // Moves the image upwards
            // Logo/Image
            SizedBox(
              width: 250, // Adjust the width of the image
              height: 200, // Adjust the height of the image
              child: Image.asset(
                'assets/images/IMG-20241031-WA0006.jpg',
                fit: BoxFit.contain, // Ensures the image is not distorted
              ),
            ),
            const SizedBox(height: 30), // Pushes content below the image downward
            const Text(
              'Buy with escrow, Sell escrow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F4170),
              ),
            ),
            const SizedBox(height: 100),


            // Login Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2F4170), // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF2F7FA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10), // Space between Login and "Or"

            // "Or" Text
            const Text(
              'Or',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F4170),
              ),
            ),

            const SizedBox(height: 10), // Space between "Or" and Register

            // Register Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  'Create account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4170),
                  ),
                ),
              ),
            ),

            const Spacer(), // Adds extra space at the bottom
          ],
        ),
      ),
    );
  }
}
