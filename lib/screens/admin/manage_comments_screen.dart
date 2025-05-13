import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

class ManageCommentsScreen extends StatefulWidget {
  const ManageCommentsScreen({super.key});

  @override
  State<ManageCommentsScreen> createState() => _ManageCommentsScreenState();
}

class _ManageCommentsScreenState extends State<ManageCommentsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, VideoPlayerController> _videoControllers = {};

  String _filterOption = 'All Comments';
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All Comments',
    'Post Comments',
    'Reel Comments',
  ];

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Comments'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterOption = value;
              });
            },
            itemBuilder: (context) {
              return _filterOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      Icon(
                        option == _filterOption
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _buildCommentsList(),
    );
  }

  Widget _buildCommentsList() {
    return _buildCommentsFromSubcollections();
  }

  Widget _buildCommentsFromSubcollections() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getCommentsFromSubcollections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No comments found'));
        }

        final comments = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(8.w),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final commentData = comments[index];
            return _buildSubcollectionCommentCard(
              commentData['commentId'],
              commentData['parentId'],
              commentData['parentType'],
              commentData,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getCommentsFromSubcollections() async {
    List<Map<String, dynamic>> allComments = [];

    final postsSnapshot = await _firestore.collection('posts').get();

    final reelsSnapshot = await _firestore.collection('reels').get();

    if (_filterOption == 'All Comments' || _filterOption == 'Post Comments') {
      for (var postDoc in postsSnapshot.docs) {
        final commentsSnapshot =
            await postDoc.reference.collection('comments').get();
        for (var commentDoc in commentsSnapshot.docs) {
          final data = commentDoc.data();
          allComments.add({
            ...data,
            'commentId': commentDoc.id,
            'parentId': postDoc.id,
            'parentType': 'posts',
          });
        }
      }
    }

    if (_filterOption == 'All Comments' || _filterOption == 'Reel Comments') {
      for (var reelDoc in reelsSnapshot.docs) {
        final commentsSnapshot =
            await reelDoc.reference.collection('comments').get();
        for (var commentDoc in commentsSnapshot.docs) {
          final data = commentDoc.data();
          allComments.add({
            ...data,
            'commentId': commentDoc.id,
            'parentId': reelDoc.id,
            'parentType': 'reels',
          });
        }
      }
    }

    allComments.sort((a, b) {
      final aTime = a['time'] as Timestamp?;
      final bTime = b['time'] as Timestamp?;
      if (aTime == null || bTime == null) return 0;
      return bTime.compareTo(aTime);
    });

    return allComments;
  }

  Widget _buildSubcollectionCommentCard(
    String commentId,
    String parentId,
    String parentType,
    Map<String, dynamic> commentData,
  ) {
    final String userId = commentData['uid'] ?? '';
    final String text = commentData['comment'] ?? '';
    final Timestamp? timestamp = commentData['time'] as Timestamp?;
    final DateTime commentTime = timestamp?.toDate() ?? DateTime.now();
    final String formattedDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(commentTime);
    final String username = commentData['username'] ?? 'Unknown User';
    final String profileImage = commentData['profileImage'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (profileImage.isNotEmpty)
                      CircleAvatar(
                        radius: 16.r,
                        backgroundImage: NetworkImage(profileImage),
                        onBackgroundImageError: (e, s) =>
                            const Icon(Icons.person),
                      ),
                    SizedBox(width: 8.w),
                    Text(
                      username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: parentType == 'posts'
                            ? Colors.blue.shade100
                            : Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        parentType == 'posts' ? 'Post' : 'Reel',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: parentType == 'posts'
                              ? Colors.blue.shade800
                              : Colors.purple.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              formattedDate,
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
            ),
            SizedBox(height: 8.h),
            Text(text),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.visibility, size: 16),
                  label: Text(
                    'View ${parentType == 'posts' ? 'Post' : 'Reel'}',
                  ),
                  onPressed: () => _viewContentDetails(parentId, parentType),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          _showDeleteSubcollectionCommentConfirmation(
                        commentId,
                        parentId,
                        parentType,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      iconSize: 20.w,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteSubcollectionCommentConfirmation(
    String commentId,
    String parentId,
    String parentType,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteSubcollectionComment(
                  commentId,
                  parentId,
                  parentType,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSubcollectionComment(
    String commentId,
    String parentId,
    String parentType,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore
          .collection(parentType)
          .doc(parentId)
          .collection('comments')
          .doc(commentId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting comment: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Widget> _buildReelThumbnail(String videoUrl, String reelId) async {
    try {
      if (!_videoControllers.containsKey(reelId)) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
        );
        await controller.initialize();
        _videoControllers[reelId] = controller;
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: VideoPlayer(_videoControllers[reelId]!),
        ),
      );
    } catch (e) {
      // Return a placeholder on error
      return Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.video_library, color: Colors.white, size: 40),
        ),
      );
    }
  }

  Future<void> _viewContentDetails(String contentId, String contentType) async {
    try {
      final contentDoc =
          await _firestore.collection(contentType).doc(contentId).get();

      if (!contentDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Content not found')));
        }
        return;
      }

      if (!mounted) return;

      final contentData = contentDoc.data() as Map<String, dynamic>;
      final String title =
          contentType == 'posts' ? 'Post Details' : 'Reel Details';
      final bool isPost = contentType == 'posts';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(
                        contentData['profileImage'] ?? '',
                      ),
                      onBackgroundImageError: (_, __) =>
                          const Icon(Icons.person),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      contentData['username'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Media
                if (isPost && contentData['postImage'] != null)
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        contentData['postImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),

                // Reel video thumbnail using VideoPlayerController
                if (!isPost && contentData['video'] != null)
                  Container(
                    height: 250,
                    width: double.infinity,
                    child: FutureBuilder<Widget>(
                      future: _buildReelThumbnail(
                        contentData['video'],
                        contentId,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        }

                        return Stack(
                          children: [
                            snapshot.data!,
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                                size: 50,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                const Text(
                  'Caption:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isPost
                      ? (contentData['description'] ?? 'No caption')
                      : (contentData['caption'] ?? 'No caption'),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${(contentData['like'] as List?)?.length ?? 0} likes',
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear video controller for this reel when closing
                if (!isPost && _videoControllers.containsKey(contentId)) {
                  _videoControllers[contentId]!.pause();
                }
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
