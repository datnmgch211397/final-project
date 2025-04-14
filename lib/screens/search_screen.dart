import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/firebase_service/chat_service.dart';
import 'chat_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
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
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                List<UserTile> userWidgets = [];
                for (var user in users) {
                  final userData = user.data() as Map<String, dynamic>;
                  if (userData['uid'] != loggedInUser!.uid) {
                    final userWidget = UserTile(
                      userId: userData['uid'],
                      name: userData['username'],
                      email: userData['email'],
                      profile: userData['profile'],
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

  const UserTile({required this.userId, required this.name, required this.email, required this.profile});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = ChatController();
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage(profile)),
      title: Text(name),
      subtitle: Text(email),
      onTap: () async {
        final chatId = await chatController.getChatRoom(userId) ?? await chatController.createChatRoom(userId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId, receiverId: userId)),
        );
      },
    );
  }
}
