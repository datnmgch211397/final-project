import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _searchQuery = '';
  bool _isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
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

                // Filter users based on search query
                var filteredDocs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final username =
                            data['username'].toString().toLowerCase();
                        final email = data['email'].toString().toLowerCase();
                        return username.contains(_searchQuery) ||
                            email.contains(_searchQuery);
                      }).toList();
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final userId = doc.id;
                    final username = data['username'] ?? 'No Username';
                    final email = data['email'] ?? 'No Email';
                    final profileImage = data['profile'] ?? '';
                    final role = data['role'] ?? 'user';

                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profileImage),
                        ),
                        title: Text(username),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(email),
                            Text(
                              'Role: ${role.toUpperCase()}',
                              style: TextStyle(
                                color:
                                    role == 'admin'
                                        ? Colors.purple
                                        : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (value) async {
                            if (value == 'change_role') {
                              _changeUserRole(userId, role);
                            } else if (value == 'delete') {
                              _deleteUser(userId);
                            }
                          },
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'change_role',
                                  child: Row(
                                    children: [
                                      Icon(
                                        role == 'admin'
                                            ? Icons.person
                                            : Icons.admin_panel_settings,
                                        color:
                                            role == 'admin'
                                                ? Colors.grey
                                                : Colors.purple,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        role == 'admin'
                                            ? 'Make User'
                                            : 'Make Admin',
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8.w),
                                      const Text('Delete User'),
                                    ],
                                  ),
                                ),
                              ],
                        ),
                      ),
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

  Future<void> _changeUserRole(String userId, String currentRole) async {
    try {
      // Don't allow changing the current admin's role
      if (userId == _auth.currentUser!.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot change your own role')),
        );
        return;
      }

      final newRole = currentRole == 'admin' ? 'user' : 'admin';

      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User role updated to $newRole'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Don't allow deleting the current admin
      if (userId == _auth.currentUser!.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot delete your own account')),
        );
        return;
      }

      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Delete User'),
              content: const Text(
                'Are you sure you want to delete this user? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );

      if (shouldDelete != true) return;

      // Delete user's posts
      final postsQuery =
          await _firestore
              .collection('posts')
              .where('uid', isEqualTo: userId)
              .get();

      for (var doc in postsQuery.docs) {
        await _firestore.collection('posts').doc(doc.id).delete();
      }

      // Delete user's reels
      final reelsQuery =
          await _firestore
              .collection('reels')
              .where('uid', isEqualTo: userId)
              .get();

      for (var doc in reelsQuery.docs) {
        await _firestore.collection('reels').doc(doc.id).delete();
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User and all associated content deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
