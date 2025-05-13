import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/screens/admin/admin_routes.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _userCount = 0;
  int _postCount = 0;
  int _reelCount = 0;
  int _commentCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userSnapshot = await _firestore.collection('users').count().get();
      _userCount = userSnapshot.count ?? 0;

      final postSnapshot = await _firestore.collection('posts').count().get();
      _postCount = postSnapshot.count ?? 0;

      final reelSnapshot = await _firestore.collection('reels').count().get();
      _reelCount = reelSnapshot.count ?? 0;

      int totalComments = 0;

      final postsSnapshot = await _firestore.collection('posts').get();
      for (var doc in postsSnapshot.docs) {
        final commentsCount = await _firestore
            .collection('posts')
            .doc(doc.id)
            .collection('comments')
            .count()
            .get();
        totalComments += commentsCount.count ?? 0;
      }

      final reelsSnapshot = await _firestore.collection('reels').get();
      for (var doc in reelsSnapshot.docs) {
        final commentsCount = await _firestore
            .collection('reels')
            .doc(doc.id)
            .collection('comments')
            .count()
            .get();
        totalComments += commentsCount.count ?? 0;
      }

      _commentCount = totalComments;
    } catch (e) {
      debugPrint('Error fetching statistics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login_screen');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Statistics',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildStatisticsGrid(),
                  SizedBox(height: 32.h),
                  Text(
                    'Management',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _buildManagementMenu(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Users', _userCount, Icons.people),
        _buildStatCard('Posts', _postCount, Icons.image),
        _buildStatCard('Reels', _reelCount, Icons.video_file),
        _buildStatCard('Comments', _commentCount, Icons.comment),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.w, color: Theme.of(context).primaryColor),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementMenu() {
    return Column(
      children: [
        _buildManagementItem(
          title: 'Manage Users',
          icon: Icons.people,
          onTap: () {
            AdminRoutes.goToManageUsers(context);
          },
        ),
        _buildManagementItem(
          title: 'Manage Posts',
          icon: Icons.image,
          onTap: () {
            AdminRoutes.goToManagePosts(context);
          },
        ),
        _buildManagementItem(
          title: 'Manage Reels',
          icon: Icons.video_file,
          onTap: () {
            AdminRoutes.goToManageReels(context);
          },
        ),
        _buildManagementItem(
          title: 'Manage Comments',
          icon: Icons.comment,
          onTap: () {
            AdminRoutes.goToManageComments(context);
          },
        ),
      ],
    );
  }

  Widget _buildManagementItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
