import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int userCount = 0;
  int postCount = 0;
  int reelCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final usersSnap = await _firestore.collection('users').get();
      userCount = usersSnap.docs.length;

      final postsSnap = await _firestore.collection('posts').get();
      postCount = postsSnap.docs.length;

      final reelsSnap = await _firestore.collection('reels').get();
      reelCount = reelsSnap.docs.length;
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildStatisticsSection(),
                      SizedBox(height: 20.h),
                      _buildRecentActivitySection(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Users',
                count: userCount,
                icon: Icons.person,
                color: Colors.blue,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatCard(
                title: 'Posts',
                count: postCount,
                icon: Icons.image,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildStatCard(
                title: 'Reels',
                count: reelCount,
                icon: Icons.video_library,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                Icon(icon, color: color, size: 24.sp),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        StreamBuilder<QuerySnapshot>(
          stream:
              _firestore
                  .collection('posts')
                  .orderBy('time', descending: true)
                  .limit(5)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No recent activities'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.docs[index];
                final data = post.data() as Map<String, dynamic>;
                final DateTime time = (data['time'] as Timestamp).toDate();

                return Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(data['profileImage']),
                    ),
                    title: Text(data['username']),
                    subtitle: Text('Posted a new photo'),
                    trailing: Text(
                      '${time.day}/${time.month}/${time.year}',
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
