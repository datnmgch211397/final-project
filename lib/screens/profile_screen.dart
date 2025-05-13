import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/firebase_service/storage.dart';
import 'package:final_app2/data/model/user_model.dart';
import 'package:final_app2/screens/post_screen.dart';
import 'package:final_app2/screens/reels_screen.dart';
import 'package:final_app2/screens/chat_screen.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:final_app2/widgets/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import '../data/firebase_service/chat_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.uid});
  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isCurrentUser = false;
  int postNumber = 0;
  List following = [];
  bool isFollowing = false;
  bool _isLoading = false;
  Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    getdata();
    if (_auth.currentUser!.uid == widget.uid) {
      setState(() {
        isCurrentUser = true;
      });
    } else {
      setState(() {
        isCurrentUser = false;
      });
    }
  }

  @override
  void dispose() {
    _videoControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  getdata() async {
    DocumentSnapshot snap =
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
    List follow = (snap.data() as dynamic)['following'];
    if (follow.contains(widget.uid)) {
      setState(() {
        isFollowing = true;
      });
    } else {
      setState(() {
        isFollowing = false;
      });
    }
  }

  void followUser() async {
    String res = await Firebase_Firestore().follow(uid: widget.uid);
    if (res == 'success') {
      setState(() {
        isFollowing = !isFollowing;
      });
    }
  }

  void _editProfile() async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController bioController = TextEditingController();
    File? selectedImage;
    String? imageUrl;

    // Get current user data
    UserModel currentUser = await Firebase_Firestore().getUser(
      uidd: widget.uid,
    );
    usernameController.text = currentUser.username;
    bioController.text = currentUser.bio;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text('Edit Profile'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setDialogState(() {
                                selectedImage = File(image.path);
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                selectedImage != null
                                    ? FileImage(selectedImage!)
                                    : NetworkImage(currentUser.profile)
                                        as ImageProvider,
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: bioController,
                          decoration: const InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (usernameController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Username cannot be empty')),
                          );
                          return;
                        }

                        if (usernameController.text.length < 3) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Username must be at least 3 characters',
                              ),
                            ),
                          );
                          return;
                        }

                        try {
                          setDialogState(() {
                            _isLoading = true;
                          });

                          if (selectedImage != null) {
                            imageUrl = await StorageMethod()
                                .uploadImageToStorage(
                                  'Profile',
                                  selectedImage!,
                                );
                          }

                          String res = await Firebase_Firestore()
                              .updateUserProfile(
                                uid: widget.uid,
                                username: usernameController.text,
                                bio: bioController.text,
                                profileImage: imageUrl,
                              );

                          setDialogState(() {
                            _isLoading = false;
                          });

                          if (res == 'success') {
                            Navigator.pop(context);
                            setState(() {}); // Refresh the profile screen
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating profile: $res'),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            _isLoading = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating profile: $e'),
                            ),
                          );
                        }
                      },
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<Widget> _buildReelThumbnail(String videoUrl, String reelId) async {
    if (!_videoControllers.containsKey(reelId)) {
      final controller = VideoPlayerController.network(videoUrl);
      await controller.initialize();
      _videoControllers[reelId] = controller;
    }

    return AspectRatio(
      aspectRatio: 1,
      child: VideoPlayer(_videoControllers[reelId]!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: Firebase_Firestore().getUser(uidd: widget.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("Error"));
                    } else {
                      return Top(snapshot.data!);
                    }
                  },
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    // Posts Tab
                    StreamBuilder(
                      stream:
                          _firebaseFirestore
                              .collection('posts')
                              .where('uid', isEqualTo: widget.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Error"));
                        }
                        postNumber = snapshot.data!.docs.length;
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No posts yet"));
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                              ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var snap = snapshot.data!.docs[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => PostScreen(snap.data()),
                                  ),
                                );
                              },
                              child: CachedImage(snap['postImage']),
                            );
                          },
                        );
                      },
                    ),
                    // Reels Tab
                    StreamBuilder(
                      stream:
                          _firebaseFirestore
                              .collection('reels')
                              .where('uid', isEqualTo: widget.uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(child: Text("Error"));
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No reels yet"));
                        }
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 1,
                                crossAxisSpacing: 1,
                              ),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var snap = snapshot.data!.docs[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ReelsScreen(
                                          initialIndex: index,
                                          initialReels: snapshot.data!.docs,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                color: Colors.black,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    FutureBuilder(
                                      future: _buildReelThumbnail(
                                        snap['video'],
                                        snap['reelId'],
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                          );
                                        }
                                        return snapshot.data!;
                                      },
                                    ),
                                    const Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget Top(UserModel user) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.h),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 10.h),
                child: ClipOval(
                  child: SizedBox(
                    width: 80.w,
                    height: 80.h,
                    child: CachedImage(user.profile),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(width: 35.w),
                      Text(
                        postNumber.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 52.w),
                      Text(
                        user.followers.length.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 52.w),
                      Text(
                        user.following.length.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 30.w),
                      Text(
                        'Posts',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 25.w),
                      Text(
                        'Followers',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                      SizedBox(width: 18.w),
                      Text(
                        'Following',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          if (!isFollowing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: GestureDetector(
                onTap: () {
                  if (isCurrentUser) {
                    _editProfile();
                  } else {
                    followUser();
                  }
                },
                child: Container(
                  height: 30.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.white : Colors.blue,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(
                      color: isCurrentUser ? Colors.grey.shade400 : Colors.blue,
                    ),
                  ),
                  child:
                      isCurrentUser
                          ? Text(
                            'Edit Profile',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14.sp),
                          )
                          : Text(
                            'Follow',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ),
          if (isFollowing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        followUser();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'Unfollow',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      height: 30.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () => _openChatWithUser(user),
                        child: Text(
                          'Message',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 5.h),
          SizedBox(
            width: double.infinity,
            height: 30.h,
            child: const TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [Icon(Icons.grid_on), Icon(Icons.video_collection)],
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  void _openChatWithUser(UserModel user) async {
    final ChatController chatController = ChatController();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final chatId =
          await chatController.getChatRoom(widget.uid) ??
          await chatController.createChatRoom(widget.uid);

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatScreen(chatId: chatId, receiverId: widget.uid),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }
}
