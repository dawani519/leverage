import 'package:flutter/material.dart';
import 'package:leverage/homepage.dart';
import 'package:leverage/notification.dart';
import 'package:leverage/pages/more.dart';
import 'package:leverage/pages/transact.dart';
import 'package:leverage/get_started_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leverage/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leverage',
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/notification': (context) => const NotificationPage(),
        '/more': (context) => const MorePage(),
        '/transact': (context) => const TransactPage(),
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!) {
          return HomePage();
        } else {
          return GetStartedPage();
        }
      },
    );
  }
}
