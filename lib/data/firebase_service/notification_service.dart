import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createLikeNotification({
    required String postId,
    required String postType, 
    required String postOwnerId,
    required String postOwnerName,
  }) async {
    if (_auth.currentUser == null) return;
    if (_auth.currentUser!.uid == postOwnerId) return;

    await _firestore.collection('notifications').add({
      'userId': postOwnerId,
      'type': 'like',
      'postId': postId,
      'postType': postType,
      'actorId': _auth.currentUser!.uid,
      'actorName': postOwnerName,
      'message': 'liked your ${postType == 'posts' ? 'post' : 'reel'}',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createCommentNotification({
    required String postId,
    required String postType,
    required String postOwnerId,
    required String postOwnerName,
    required String comment,
  }) async {
    if (_auth.currentUser == null) return;
    if (_auth.currentUser!.uid == postOwnerId) return;

    await _firestore.collection('notifications').add({
      'userId': postOwnerId,
      'type': 'comment',
      'postId': postId,
      'postType': postType,
      'actorId': _auth.currentUser!.uid,
      'actorName': postOwnerName,
      'message': 'commented: $comment',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createFollowNotification({
    required String followedUserId,
    required String followerId,
    required String followerName,
  }) async {
    if (_auth.currentUser == null) return;
    if (followerId == followedUserId) return;

    await _firestore.collection('notifications').add({
      'userId': followedUserId,
      'type': 'follow',
      'actorId': followerId,
      'actorName': followerName,
      'message': 'started following you',
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getUserNotifications() {
    if (_auth.currentUser == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markAllNotificationsAsRead() async {
    if (_auth.currentUser == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: _auth.currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
