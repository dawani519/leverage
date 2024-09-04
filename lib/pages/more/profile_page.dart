import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.blue),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'User Name',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.check_circle,
                  color: Colors.blue[700],
                  size: 24,
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
                  _buildDetailRow('First Name', 'John'),
                  const Divider(),
                  _buildDetailRow('Last Name', 'Doe'),
                  const Divider(),
                  _buildDetailRow('Phone Number', '+234 800 000 0000'),
                  const Divider(),
                  _buildDetailRow('Email', 'john.doe@example.com'),
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
