import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/data/firebase_service/notification_service.dart';
import 'package:final_app2/screens/post_screen.dart';
import 'package:final_app2/screens/profile_screen.dart';
import 'package:final_app2/widgets/reel_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              _notificationService.markAllNotificationsAsRead();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getUserNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final timestamp = data['timestamp'] as Timestamp?;
              final timeAgo = timestamp != null
                  ? timeago.format(timestamp.toDate())
                  : 'Just now';

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  doc.reference.delete();
                },
                child: ListTile(
                  leading: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(data['actorId'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircleAvatar();
                      }
                      final userData =
                          snapshot.data?.data() as Map<String, dynamic>?;
                      final profileImage =
                          userData != null ? userData['profile'] : null;
                      return CircleAvatar(
                        backgroundImage: profileImage != null
                            ? NetworkImage(profileImage)
                            : null,
                        child: profileImage == null
                            ? const Icon(Icons.person)
                            : null,
                      );
                    },
                  ),
                  title: Text(
                    '${data['actorName']} ${data['message']}',
                    style: TextStyle(
                      fontWeight:
                          data['isRead'] ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(timeAgo),
                  onTap: () async {
                    // Mark notification as read
                    await _notificationService.markNotificationAsRead(doc.id);

                    // Navigate based on notification type
                    if (data['type'] == 'like' || data['type'] == 'comment') {
                      if (data['postType'] == 'posts') {
                        final postDoc = await FirebaseFirestore.instance
                            .collection('posts')
                            .doc(data['postId'])
                            .get();
                        if (postDoc.exists && postDoc.data() != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(postDoc.data()),
                            ),
                          );
                        }
                      } else if (data['postType'] == 'reels') {
                        final reelDoc = await FirebaseFirestore.instance
                            .collection('reels')
                            .doc(data['postId'])
                            .get();
                        if (reelDoc.exists && reelDoc.data() != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                body: SafeArea(
                                  child: ReelItem(reelDoc.data()!),
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    } else if (data['type'] == 'follow') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileScreen(uid: data['actorId']),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
