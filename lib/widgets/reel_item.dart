import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:final_app2/widgets/comment.dart';
import 'package:final_app2/widgets/like_animation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/screens/profile_screen.dart';

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
  bool isFollowing = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    user = _auth.currentUser!.uid;
    _checkFollowingStatus();
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

  void _checkFollowingStatus() async {
    if (_auth.currentUser!.uid != widget.snapshot['uid']) {
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();
      List following = (userDoc.data() as dynamic)['following'];
      setState(() {
        isFollowing = following.contains(widget.snapshot['uid']);
      });
    }
  }

  void _followUser() async {
    String res = await Firebase_Firestore().follow(uid: widget.snapshot['uid']);
    if (res == 'success') {
      setState(() {
        isFollowing = !isFollowing;
      });
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

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_auth.currentUser!.uid == widget.snapshot['uid'])
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Reel'),
                onTap: () {
                  Navigator.pop(context);
                  _editReel();
                },
              ),
            if (_auth.currentUser!.uid == widget.snapshot['uid'])
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Reel', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteReel();
                },
              ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
          ],
        );
      },
    );
  }

  void _editReel() async {
    final TextEditingController captionController = TextEditingController();
    captionController.text = widget.snapshot['caption'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Reel'),
            content: TextField(
              controller: captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String res = await Firebase_Firestore().updateReel(
                    reelId: widget.snapshot['reelId'],
                    caption: captionController.text,
                  );
                  if (res == 'success') {
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteReel() async {
    Firebase_Firestore().deleteReel(reelId: widget.snapshot['reelId']);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reel deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeleted) {
      return SizedBox.shrink();
    }

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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(
                                    uid: widget.snapshot['uid'],
                                  ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.snapshot['profileImage'],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfileScreen(
                                    uid: widget.snapshot['uid'],
                                  ),
                            ),
                          );
                        },
                        child: Text(
                          widget.snapshot['username'],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_auth.currentUser!.uid != widget.snapshot['uid'])
                        TextButton(
                          onPressed: _followUser,
                          child: Text(
                            isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(
                              color: isFollowing ? Colors.grey : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
          ),

          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.white),
              onPressed: _showMoreOptions,
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
