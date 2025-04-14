import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;

  const ChatTile({
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return lastMessage != ""
        ? ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(receiverData['imageUrl']),
      ),
      title: Text(receiverData['name']),
      subtitle: Text(lastMessage, maxLines: 2),
      trailing: Text(
        '${timestamp.hour}:${timestamp.minute}',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: chatId,
              receiverId: receiverData['uid'],
            ),
          ),
        );
      },
    )
        : Container();
  }
}

