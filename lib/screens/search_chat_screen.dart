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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      appBar: AppBar(title: const Text('Search Users')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by username or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: handleSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                if (searchQuery.isEmpty) {
                  return const Center(
                      child: Text('No users found'));
                }
                final filteredUsers = snapshot.data!.docs.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final username =
                      userData['username'].toString().toLowerCase();
                  final email = userData['email'].toString().toLowerCase();
                  return username.contains(searchQuery.toLowerCase()) ||
                      email.contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final userData = user.data() as Map<String, dynamic>;

                    return UserTile(
                      userId: user.id,
                      name: userData['username'],
                      email: userData['email'],
                      profile: userData['profile'],
                    );
                  },
                );
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
        final chatId = await chatController.getChatRoom(userId) ??
            await chatController.createChatRoom(userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatId: chatId, receiverId: userId),
          ),
        );
      },
    );
  }
}
