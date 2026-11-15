// leverage/pages/chat/models/chat_user.dart

class ChatUser {
  final String userID;
  final String firstName;
  final String surname;
  final String userRole;

  ChatUser({
    required this.userID,
    required this.firstName,
    required this.surname,
    required this.userRole,
  });

  factory ChatUser.fromMap(Map<String, dynamic> data, String userID) {
    return ChatUser(
      userID: userID,
      firstName: data['first_name'] ?? '',
      surname: data['surname'] ?? '',
      userRole: data['userRole'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'surname': surname,
      'userRole': userRole,
    };
  }
}
