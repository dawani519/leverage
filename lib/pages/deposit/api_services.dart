import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class PaystackAPI {
  static const String publicKey = 'pk_test_ccbe891e0586cba36a5e8e776be78d4674224555';
  static const String secretKey = 'YOUR_PAYSTACK_SECRET_KEY';
  static const String baseUrl = 'https://api.paystack.co';

  /// Initialize a transaction
  static Future<Map<String, dynamic>> initializeTransaction({
    required String email,
    required int amount,
    required String reference,
  }) async {
    final url = Uri.parse('$baseUrl/transaction/initialize');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'email': email,
      'amount': amount,
      'reference': reference,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData; // Successful response
      } else {
        throw Exception('Failed to initialize transaction: ${responseData['message']}');
      }
    } catch (error) {
      throw Exception('Error initializing transaction: $error');
    }
  }

  /// Verify a transaction
  static Future<Map<String, dynamic>> verifyTransaction(String reference) async {
    final url = Uri.parse('$baseUrl/transaction/verify/$reference');
    final headers = {
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData; // Successful verification
      } else {
        throw Exception('Failed to verify transaction: ${responseData['message']}');
      }
    } catch (error) {
      throw Exception('Error verifying transaction: $error');
    }
  }

  /// Send the transaction details to your backend
  static Future<void> sendTransactionToBackend({
    required String reference,
    required String email,
    required int amount,
    required bool verified,
  }) async {
    final backendUrl = 'https://your-backend-api.com/record-transaction'; // Change this to your backend endpoint
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'reference': reference,
      'email': email,
      'amount': amount,
      'verified': verified,
    });

    try {
      final response = await http.post(Uri.parse(backendUrl), headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('Transaction recorded successfully: ${responseData['message']}');
      } else {
        throw Exception('Failed to record transaction: ${responseData['message']}');
      }
    } catch (error) {
      throw Exception('Error recording transaction: $error');
    }
  }

  /// Open the payment URL in a browser
  static Future<void> openPaymentUrl(BuildContext context, String url) async {
    // Use url_launcher package to open URLs.
    // Add this dependency in pubspec.yaml: url_launcher: ^6.1.5
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
