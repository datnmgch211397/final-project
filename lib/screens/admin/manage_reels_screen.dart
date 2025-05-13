import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';

class ManageReelsScreen extends StatefulWidget {
  const ManageReelsScreen({Key? key}) : super(key: key);

  @override
  State<ManageReelsScreen> createState() => _ManageReelsScreenState();
}

class _ManageReelsScreenState extends State<ManageReelsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Firebase_Firestore _firebaseFirestore = Firebase_Firestore();
  final Map<String, VideoPlayerController> _videoControllers = {};
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Widget> _buildReelThumbnail(String videoUrl, String reelId) async {
    if (!_videoControllers.containsKey(reelId)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      _videoControllers[reelId] = controller;
    }
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: VideoPlayer(_videoControllers[reelId]!),
    );
  }

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
                hintText: 'Search reels by username or caption...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('reels')
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
                  return const Center(child: Text('No reels found.'));
                }

                var reels = snapshot.data!.docs;
                if (_searchQuery.isNotEmpty) {
                  reels = reels.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final username = data['username'].toString().toLowerCase();
                    final caption = data['caption'].toString().toLowerCase();
                    return username.contains(_searchQuery) ||
                        caption.contains(_searchQuery);
                  }).toList();
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 9 / 16,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                  ),
                  itemCount: reels.length,
                  itemBuilder: (context, index) {
                    final doc = reels[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final reelId = doc.id;
                    final videoUrl = data['video'] ?? '';
                    final username = data['username'] ?? 'No Username';
                    final caption = data['caption'] ?? '';
                    final likes = (data['like'] as List?)?.length ?? 0;

                    return GestureDetector(
                      onTap: () => _showReelDetails(data, reelId),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: FutureBuilder<Widget>(
                                future: _buildReelThumbnail(videoUrl, reelId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                        size: 30.sp,
                                      ),
                                    );
                                  }
                                  return snapshot.data!;
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.r),
                                  bottomRight: Radius.circular(10.r),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    caption,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(Icons.favorite,
                                          color: Colors.red, size: 12.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '$likes',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red, size: 20.sp),
                              onPressed: () => _deleteReel(reelId),
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

  void _showReelDetails(Map<String, dynamic> data, String reelId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reel Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(data['profileImage']),
                ),
                title: Text(data['username'] ?? 'Unknown'),
                subtitle:
                    Text('Likes: ${(data['like'] as List?)?.length ?? 0}'),
              ),
              SizedBox(height: 10.h),
              const Text('Caption:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(data['caption'] ?? 'No caption'),
              SizedBox(height: 10.h),
              const Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                data['time'] != null
                    ? (data['time'] as Timestamp).toDate().toString()
                    : 'Unknown',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReel(reelId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReel(String reelId) async {
    try {
      setState(() => _isLoading = true);

      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this reel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Clean up controller if exists
      await _videoControllers[reelId]?.dispose();
      _videoControllers.remove(reelId);

      final result = await _firebaseFirestore.deleteReel(reelId: reelId);

      final snackBar = SnackBar(
        content: Text(
          result == 'success'
              ? 'Reel deleted successfully.'
              : 'Failed to delete reel: $result',
        ),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
