import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Registration function
  Future<void> _register() async {
    final String firstName = _firstNameController.text;
    final String middleName = _middleNameController.text;
    final String surname = _surnameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user; // The user object might be null

      if (user != null) {
        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification email sent to ${user.email}')),
          );
        }

        // Save user data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'first_name': firstName,
          'middle_name': middleName,
          'surname': surname,
          'email': email,
          'uid': user.uid, // User ID from Firebase Authentication
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please verify your email.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. User object is null.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA), // Set background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start (left)
            children: [
              // Sign Up Text
              const SizedBox(height: 40), // Space at the top
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Color(0xFF2F4170),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between Sign Up and first name

              // First Name Container
              _buildInputField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
              ),

              // Middle Name Container
              _buildInputField(
                controller: _middleNameController,
                label: 'Middle Name',
                icon: Icons.person,
              ),

              // Surname Container
              _buildInputField(
                controller: _surnameController,
                label: 'Surname',
                icon: Icons.person,
              ),

              // Email Container
              _buildInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),

              // Password Container
              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock,
                obscureText: true,
              ),

              // Confirm Password Container
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 20), // Space before Register Button

              // Register Button
              Center( // Centering the button
                child: SizedBox(
                  width: 150, // Make button width smaller
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4170), // Set color same as login button
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        color: Color(0xFFF2F7FA), // Text color same as background
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Center(
      child: Container(
        height: 40,
        width: 300,
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        decoration: BoxDecoration(
          color: const Color(0xFFCFEBFF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row( // Using Row to place icon and demarcation container together
          children: [
            Icon(icon, size: 20, color: Color(0xFF2F4170),),
            const SizedBox(width: 8.0), // Space between icon and text field
            Container(
              height: 25, // Height of the demarcation container
              width: 2, // Width of the demarcation container
              color: Color(0xFF2F4170), // Color of the demarcation container (same as icon)
            ),
            const SizedBox(width: 10.0), // Space after demarcation container
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none, // No border
                ),
                obscureText: obscureText,
                keyboardType: keyboardType,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
