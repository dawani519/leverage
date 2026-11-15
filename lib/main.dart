import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leverage/pages/chat/screens/chat_screens.dart';
import 'firebase_options.dart';
import 'package:leverage/pages/homepage.dart';
import 'package:leverage/pages/notification.dart';
import 'package:leverage/pages/more.dart';
import 'package:leverage/pages/transact.dart';
import 'package:leverage/welcome_page.dart';
import 'package:leverage/register_page.dart';
import 'package:leverage/login_page.dart';
import 'package:leverage/become_broker_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leverage/pages/chat.dart';
import 'package:leverage/pages/chat/models/chat_arguments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leverage',
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(),
        '/home': (context) => const HomePage(),
        '/notification': (context) => const NotificationPage(),
        '/more': (context) => const MorePage(),
        '/transact': (context) => const TransactPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/chat': (context) => ChatPage(),
        '/become-broker': (context) => BecomeBrokerPage(),
        '/chatScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ChatArguments;
          return ChatScreen(
            chatID: args.chatID,
            currentUser: args.currentUser,
            productName: '',
          );
        },
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
          return const StartPage();
        } else {
          return const NavigationHandler();
        }
      },
    );
  }
}

class NavigationHandler extends StatefulWidget {
  const NavigationHandler({super.key});

  @override
  State<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends State<NavigationHandler> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const StartPage();
  }
}
