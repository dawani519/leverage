import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:firebase_auth/firebase_auth.dart'; // For auth entication
import 'package:leverage/pages/listings/listings_page.dart'; // Assuming you have a listings page
import 'package:leverage/login_page.dart'; // Assuming you have a login page

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _fullName = '';
  String _location = '';
  String _phoneNumber = '';
  String _email = '';
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Check if the user is authenticated
  Future<void> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // If not authenticated, redirect to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // If authenticated, fetch user details
      await _fetchUserDetails();
      await _fetchUserReviews();
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        setState(() {
          _fullName = '${userDoc['first_name']} ${userDoc['middle_name'] ?? ''} ${userDoc['surname']}'.trim();
          // Safely handle missing fields by providing default values
          _location = userDoc.data()?.containsKey('location') == true ? userDoc['location'] : 'Unknown';
          _phoneNumber = userDoc.data()?.containsKey('phone_number') == true ? userDoc['phone_number'] : 'Unknown';
          _email = userDoc.data()?.containsKey('email') == true ? userDoc['email'] : 'Unknown';
        });
      } else {
        setState(() {
          _errorMessage = 'User not found.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching user details: $error';
      });
    }
    _checkLoadingStatus();
  }

  Future<void> _fetchUserReviews() async {
    try {
      var reviewsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('user_reviews')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _reviews = reviewsSnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching reviews: $error';
      });
    }
    _checkLoadingStatus();
  }

  void _checkLoadingStatus() {
    if (_fullName.isNotEmpty && _reviews.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFFF2F7FA),
          ),
        ),
        backgroundColor: Color(0xFF2F4170),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fullName,
              style: const TextStyle(
                color: Color(0xFF2F4170),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Location: $_location',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Phone: $_phoneNumber',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Email: $_email',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16.0),

            // Button to view user's listings
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListingsPage(userId: widget.userId),
                  ),
                );
              },
              child: Text(
                'View Listings',
                style: TextStyle(color: Color(0xFFF2F7FA)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2F4170),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                textStyle: const TextStyle(fontSize: 16.0),
              ),
            ),
            const SizedBox(height: 24.0),

            // Reviews section
            const Text(
              'Reviews',
              style: TextStyle(
                color: Color(0xFF2F4170),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            _reviews.isEmpty
                ? const Text('No reviews available for this user.')
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                final DateTime reviewDate = (review['date'] as Timestamp).toDate();
                final formattedDate = DateFormat.yMMMd().format(reviewDate);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      'Rating: ${review['rating']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2F4170)),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Review: ${review['reviewText']}'),
                        const SizedBox(height: 4.0),
                        Text('Date: $formattedDate'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
