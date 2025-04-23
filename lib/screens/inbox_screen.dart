import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/firebase_service/chat_service.dart';
import 'chat_screen.dart';
import 'search_chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatController _chatController = ChatController();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatController.getChats(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchChatScreen(),
                        ),
                      );
                    },
                    child: Text('Find People to Chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final chatId = snapshot.data!.docs[index].id;
              final users = chatData['users'] as List<dynamic>;

              // Find the other user's ID
              final otherUserId = users.firstWhere(
                (userId) => userId != _currentUserId,
                orElse: () => _currentUserId,
              );

              if (otherUserId == _currentUserId) {
                return SizedBox.shrink(); // Skip self-chats
              }

              return FutureBuilder<DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      title: Container(
                        width: 100,
                        height: 14,
                        color: Colors.grey.shade300,
                      ),
                      subtitle: Container(
                        width: 150,
                        height: 10,
                        color: Colors.grey.shade200,
                      ),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return SizedBox.shrink(); // Skip if user data doesn't exist
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final timestamp = chatData['timestamp'] as Timestamp?;
                  final lastMessage =
                      chatData['lastMessage'] as String? ?? 'Start chatting';

                  final formattedTime =
                      timestamp != null
                          ? '${timestamp.toDate().hour}:${timestamp.toDate().minute.toString().padLeft(2, '0')}'
                          : '';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['profile']),
                    ),
                    title: Text(
                      userData['username'] ?? 'Unknown User',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing:
                        timestamp != null
                            ? Text(
                              formattedTime,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            )
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                chatId: chatId,
                                receiverId: otherUserId,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchChatScreen()),
          );
        },
        child: Icon(Icons.chat),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
