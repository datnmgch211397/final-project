import 'package:date_format/date_format.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:final_app2/widgets/comment.dart';
import 'package:final_app2/widgets/like_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> snapshot;
  const PostWidget(this.snapshot, {super.key});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLikeAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!.uid;
  }

  void _onLikeTap() {
    setState(() {
      isLikeAnimating = true;
    });
    Firebase_Firestore().like(
      like: widget.snapshot['like'],
      type: 'posts',
      uid: user,
      postId: widget.snapshot['postId'],
    );
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          isLikeAnimating = false;
        });
      }
    });
  }

  void _onCommentTap() {
    showBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            maxChildSize: 0.5,
            initialChildSize: 0.5,
            minChildSize: 0.2,
            builder: (context, scrollController) {
              return Comment('posts', widget.snapshot['postId']);
            },
          ),
        );
      },
    );
  }

  void _onShareTap() {
    // TODO: Implement share functionality
    print('Share tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        height: 35.h,
                        width: 35.w,
                        child: CachedImage(widget.snapshot['profileImage']),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      widget.snapshot['username'] ?? '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 45.w),
                  child: Text(
                    widget.snapshot['caption'] ?? '',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),

          // Image
          GestureDetector(
            onDoubleTap: _onLikeTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 300.h,
                  width: double.infinity,
                  child: CachedImage(widget.snapshot['postImage']),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimation: isLikeAnimating,
                    duration: Duration(milliseconds: 400),
                    isLike: true,
                    onEnd: () {
                      if (mounted) {
                        setState(() {
                          isLikeAnimating = false;
                        });
                      }
                    },
                    child: Icon(
                      Icons.favorite,
                      size: 100.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.only(left:8.w, right: 8.w, top: 6.h, ),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimation: isLikeAnimating,
                  duration: Duration(milliseconds: 400),
                  isLike: true,
                  onEnd: () {
                    if (mounted) {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    }
                  },
                  child: IconButton(
                    onPressed: _onLikeTap,
                    icon: Icon(
                      widget.snapshot['like'].contains(user)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          widget.snapshot['like'].contains(user)
                              ? Colors.red
                              : Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                IconButton(
                  onPressed: _onCommentTap,
                  icon: Icon(Icons.comment_outlined),
                ),
                SizedBox(width: 10.w),
                IconButton(onPressed: _onShareTap, icon: Icon(Icons.send)),
                Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.bookmark_border)),
              ],
            ),
          ),

          // Likes count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '${widget.snapshot['like'].length} likes',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),

          // Caption
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.snapshot['username'] ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      widget.snapshot['location'] ?? '',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
               
              ],
            ),
          ),
        ],
      ),
    );
  }
}
