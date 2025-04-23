import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/firebase_service/chat_service.dart';
import 'chat_screen.dart';

class SearchChatScreen extends StatefulWidget {
  const SearchChatScreen({super.key});

  @override
  State<SearchChatScreen> createState() => _SearchChatScreenState();
}

class _SearchChatScreenState extends State<SearchChatScreen> {
  final FirebaseAuth authController = FirebaseAuth.instance;
  final ChatController chatController = ChatController();

  User? loggedInUser;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = authController.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  void handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Search Users')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatController.searchUsers(searchQuery),
              builder: (context, snapshot) {
                if (searchQuery.isEmpty) {
                  return const Center(
                    child: Text(
                      'No user available',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                List<UserTile> userWidgets = [];

                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  final userId = userData['uid'] ?? '';
                  final username = userData['username'] ?? 'Unknown';
                  final email = userData['email'] ?? 'No email';
                  final profile = userData['profile'] ?? '';

                  if (userId != loggedInUser!.uid ) {
                    final userWidget = UserTile(
                      userId: userId,
                      name: username,
                      email: email,
                      profile: profile,
                    );
                    userWidgets.add(userWidget);
                  }
                }
                return ListView(children: userWidgets);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String profile;

  const UserTile({
    required this.userId,
    required this.name,
    required this.email,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = ChatController();
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(profile)),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        final chatId =
            await chatController.getChatRoom(userId) ??
            await chatController.createChatRoom(userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatScreen(chatId: chatId, receiverId: userId),
          ),
        );
      },
    );
  }
}
