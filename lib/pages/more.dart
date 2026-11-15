import 'package:flutter/material.dart';
import 'package:leverage/pages/more/profile_page.dart';
import 'package:leverage/pages/more/support_page.dart';
import 'package:leverage/pages/more/faq_page.dart';
import 'package:leverage/pages/more/settings_page.dart';
import 'package:leverage/pages/more/about_us_page.dart';
import 'package:leverage/pages/more/privacy_policy_page.dart';
import 'package:leverage/pages/more/terms_of_service_page.dart';
import 'package:leverage/pages/more/transactions_page.dart';
import 'package:leverage/login_page.dart'; // Assuming the login page is here

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FA),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF2F4170)),
            title: const Text(
              'Profile',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.wallet_rounded, color: Color(0xFF2F4170)),
            title: const Text(
              'Transactions',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TransactionsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF2F4170)),
            title: const Text(
              'Settings',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF2F4170)),
            title: const Text(
              'FAQ',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support, color: Color(0xFF2F4170)),
            title: const Text(
              'Support',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Color(0xFF2F4170)),
            title: const Text(
              'About Us',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF2F4170)),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner, color: Color(0xFF2F4170)),
            title: const Text(
              'Terms of Service',
              style: TextStyle(color: Color(0xFF2F4170)),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to the login page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false, // Clear the navigation stack
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
