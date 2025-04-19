import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:final_app2/widgets/comment.dart';
import 'package:final_app2/widgets/like_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ReelItem extends StatefulWidget {
  final Map<String, dynamic> snapshot;
  const ReelItem(this.snapshot, {super.key});

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late VideoPlayerController _controller;
  bool isPlaying = true;
  bool isAnimating = false;
  bool isLikeAnimating = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    user = _auth.currentUser!.uid;
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.snapshot['video']),
        )
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller.setLooping(true);
            _controller.setVolume(1.0);
            _controller.play();
          }
        });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        _controller.play();
      } else {
        _controller.pause();
      }
    });
  }

  void _onLikeTap() {
    setState(() {
      isLikeAnimating = true;
    });
    Firebase_Firestore().like(
      like: widget.snapshot['like'],
      type: 'reels',
      uid: user,
      postId: widget.snapshot['reelId'],
    );
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          isLikeAnimating = false;
        });
      }
    });
  }

  void _onDoubleTap() {
    Firebase_Firestore().like(
      like: widget.snapshot['like'],
      type: 'reels',
      uid: user,
      postId: widget.snapshot['reelId'],
    );
    setState(() {
      isAnimating = true;
    });
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          isAnimating = false;
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
              return Comment('reels', widget.snapshot['reelId']);
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
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_controller.value.isInitialized)
            GestureDetector(
              onDoubleTap: _onDoubleTap,
              onTap: _togglePlay,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          if (!isPlaying)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 35.r,
                  ),
                ),
              ),
            ),

          // Like animation
          Center(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 200),
              opacity: isAnimating ? 1 : 0,
              child: LikeAnimation(
                isAnimation: isAnimating,
                duration: Duration(milliseconds: 400),
                isLike: true,
                onEnd: () {
                  if (mounted) {
                    setState(() {
                      isAnimating = false;
                    });
                  }
                },
                child: Icon(Icons.favorite, size: 100.w, color: Colors.white),
              ),
            ),
          ),

          // Overlay controls
          Positioned(
            right: 15.w,
            bottom: 150.h,
            child: Column(
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
                              : Colors.white,
                      size: 28.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  widget.snapshot['like'].length.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
                SizedBox(height: 15.h),
                _buildActionButton(Icons.comment, 0, onTap: _onCommentTap),
                SizedBox(height: 15.h),
                _buildActionButton(Icons.send, 0, onTap: _onShareTap),
              ],
            ),
          ),

          // User info and caption
          Positioned(
            left: 15.w,
            right: 15.w,
            bottom: 30.h,
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
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Follow', style: TextStyle(fontSize: 13.sp)),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  widget.snapshot['caption'] ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    int count, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28.w),
          SizedBox(height: 3.h),
          Text(
            count.toString(),
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
