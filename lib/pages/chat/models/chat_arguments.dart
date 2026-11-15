// leverage/pages/chat/models/chat_arguments.dart
import 'package:leverage/pages/chat/models/chat_user.dart';

class ChatArguments {
  final String chatID;
  final ChatUser currentUser;
  final String productName;

  ChatArguments({
    required this.chatID,
    required this.currentUser,
    required this.productName,
  });
}
