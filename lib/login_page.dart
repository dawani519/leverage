import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for email and password fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Login function
  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // If login is successful, navigate to home screen (or wherever you want)
        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.of(context).pushReplacementNamed("/home");
      } on FirebaseAuthException catch (e) {
        // Handle login error
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          default:
            errorMessage = 'Login failed. Please try again.';
        }
        Fluttertoast.showToast(msg: errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar
      backgroundColor: const Color(0xFFF2F7FA), // Set background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Login Text
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: Color(0xFF2F4170),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Space between Login and input fields

                // Email Input Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFEBFF),
                    borderRadius: BorderRadius.circular(30), // Curved edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(15.0), // Padding around the icon
                        child: Icon(Icons.person, color: Color(0xFF2F4170)), // Person icon
                      ),
                      Container(
                        color: const Color(0xFF2F4170), // Color of the line
                        height: 30, // Thickness of the line
                        width: 2, // Space between icon and line
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(vertical: 15), // Padding inside the TextFormField
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]").hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Space between Email and Password

                // Password Input Field
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCFEBFF),
                    borderRadius: BorderRadius.circular(30), // Curved edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(15.0), // Padding around the icon
                        child: Icon(Icons.lock, color: Color(0xFF2F4170)), // Lock icon
                      ),
                      Container(
                        color: const Color(0xFF2F4170), // Color of the line
                        height:30, // Thickness of the line
                        width: 2, // Space between icon and line
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.symmetric(vertical: 15), // Padding inside the TextFormField
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password should be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32), // Space between Password and Login Button

                // Login Button
                Container(
                  width: 100, // Make button full width
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F4170), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Curved edges
                      ),
                    ),
                    onPressed: loginUser,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFFF2F7FA), // Text color
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Space below the Login Button

                // Register Navigation Text
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register'); // Navigate to registration page
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
