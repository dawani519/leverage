import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? ''; // Get the UID of the current user

    return Scaffold(
      backgroundColor: Color(0xFFF2F7FA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Color(0xFFF2F7FA)),
        ),
        backgroundColor: Color(0XFF2F4170),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          // Get user data
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String fullName = '${userData['first_name']} ${userData['middle_name']} ${userData['surname']}';
          final String mobileNumber = userData['number'] ?? 'N/A';
          final String email = userData['email'] ?? 'N/A';
          final String dateOfBirth = userData['date_of_birth'] ?? 'N/A'; // Make sure to add this in your Firestore
          final String address = userData['address'] ?? 'N/A'; // Make sure to add this in your Firestore

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(userData['profile_picture'] ?? 'https://via.placeholder.com/150'), // URL to profile picture
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Verified User',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'PERSONAL DETAILS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Full Name', fullName),
                      const Divider(),
                      _buildDetailRow('Mobile Number', mobileNumber),
                      const Divider(),
                      _buildDetailRow('Date of Birth', dateOfBirth),
                      const Divider(),
                      _buildDetailRow('Email', email),
                      const Divider(),
                      _buildDetailRow('Address', address),
                      const Divider(),
                      _buildDetailRow(
                        'Change Password',
                        '',
                        isLink: true,
                        onTap: () {
                          // Add your change password logic here
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Add your logout logic here
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false, VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isLink)
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
      ],
    );
  }
}
