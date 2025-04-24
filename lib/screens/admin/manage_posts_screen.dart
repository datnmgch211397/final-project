import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManagePostsScreen extends StatefulWidget {
  const ManagePostsScreen({Key? key}) : super(key: key);

  @override
  State<ManagePostsScreen> createState() => _ManagePostsScreenState();
}

class _ManagePostsScreenState extends State<ManagePostsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';

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
                hintText: 'Search posts by username or caption...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('posts')
                      .orderBy('time', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts found'));
                }

                // Filter posts based on search query
                var filteredDocs = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  filteredDocs =
                      filteredDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final username =
                            data['username'].toString().toLowerCase();
                        final caption =
                            data['caption'].toString().toLowerCase();
                        return username.contains(_searchQuery) ||
                            caption.contains(_searchQuery);
                      }).toList();
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final postId = doc.id;
                    final username = data['username'] ?? 'No Username';
                    final postImage = data['postImage'] ?? '';
                    final caption = data['caption'] ?? 'No Caption';
                    final location = data['location'] ?? '';
                    final likes = (data['like'] as List?)?.length ?? 0;
                    final DateTime time = (data['time'] as Timestamp).toDate();

                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                data['profileImage'],
                              ),
                            ),
                            title: Text(username),
                            subtitle: Text(
                              '${time.day}/${time.month}/${time.year}',
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePost(postId),
                            ),
                          ),
                          SizedBox(
                            height: 200.h,
                            width: double.infinity,
                            child: CachedImage(postImage),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.red),
                                    SizedBox(width: 4.w),
                                    Text('$likes likes'),
                                    Spacer(),
                                    if (location.isNotEmpty) ...[
                                      Icon(Icons.location_on, size: 16.sp),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: TextStyle(fontSize: 12.sp),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  caption,
                                  style: TextStyle(fontSize: 14.sp),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Future<void> _deletePost(String postId) async {
    try {
      // Show confirmation dialog
      final shouldDelete = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Delete Post'),
              content: const Text(
                'Are you sure you want to delete this post? This action cannot be undone.',
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

      // Delete post
      await _firestore.collection('posts').doc(postId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
