import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_app2/data/firebase_service/notification_service.dart';

class Comment extends StatefulWidget {
  Comment(this.type, this.uid, {super.key});
  String type;
  String uid;

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final comment = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(25.r),
        topRight: Radius.circular(25.r),
      ),
      child: Container(
        color: Colors.white,
        height: 300.h,
        child: Stack(
          children: [
            Positioned(
              top: 8.h,
              left: 140.w,
              child: Container(width: 100.w, height: 3.h, color: Colors.black),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(widget.type)
                  .doc(widget.uid)
                  .collection('comments')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return commentItem(
                        snapshot.data!.docs[index].data(),
                        snapshot.data!.docs[index].id,
                      );
                    },
                    itemCount:
                        snapshot.data == null ? 0 : snapshot.data!.docs.length,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 60.h,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 45.h,
                      width: 260.w,
                      child: TextField(
                        controller: comment,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(fontSize: 12.sp),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (comment.text.isNotEmpty) {
                          // Lấy thông tin bài viết/reel
                          final postDoc = await _firestore
                              .collection(widget.type)
                              .doc(widget.uid)
                              .get();

                          if (postDoc.exists) {
                            final postData =
                                postDoc.data() as Map<String, dynamic>;

                            // Tạo thông báo khi comment
                            NotificationService().createCommentNotification(
                              postId: widget.uid,
                              postType: widget.type,
                              postOwnerId: postData['uid'],
                              postOwnerName: postData['username'],
                              comment: comment.text,
                            );
                          }

                          await Firebase_Firestore().createComment(
                            comment: comment.text,
                            type: widget.type,
                            uidd: widget.uid,
                          );
                        }
                        setState(() {
                          comment.clear();
                        });
                      },
                      child: Icon(Icons.send, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentItem(final snapshot, String commentId) {
    final DateTime commentTime = (snapshot['time'] as Timestamp).toDate();
    final String formattedTime = formatDate(commentTime, [
      HH,
      ':',
      nn,
      ' ',
      am,
      ' ',
      dd,
      '/',
      mm,
      '/',
      yyyy,
    ]);

    return GestureDetector(
      onLongPress: () {
        if (_auth.currentUser?.uid == snapshot['uid']) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Comment'),
              content: const Text(
                'Are you sure you want to delete this comment?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Firebase_Firestore().deleteComment(
                      type: widget.type,
                      postId: widget.uid,
                      commentId: commentId,
                    );
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: ListTile(
        leading: ClipOval(
          child: SizedBox(
            width: 35.w,
            height: 35.h,
            child: CachedImage(snapshot['profileImage']),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              snapshot['username'],
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8.h),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Text(
          snapshot['comment'],
          style: TextStyle(fontSize: 13.sp, color: Colors.black),
        ),
      ),
    );
  }
}
