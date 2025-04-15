import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/model/user_model.dart';
import 'package:final_app2/screens/post_screen.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:final_app2/widgets/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: Firebase_Firestore().getUser(),
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
              StreamBuilder(
                stream:
                    _firebaseFirestore
                        .collection('posts')
                        .where('uid', isEqualTo: _auth.currentUser!.uid)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text("Error")),
                    );
                  }

                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      var snap = snapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PostScreen(snap.data()),
                            ),
                          );
                        },
                        child: CachedImage(snap['postImage']),
                      );
                    }, childCount: snapshot.data!.docs.length),
                  );
                },
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
                        '10',
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5.r),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Text(
                'Edit Profile',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp),
              ),
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
              tabs: [
                Icon(Icons.grid_on),
                Icon(Icons.video_collection),
                Icon(Icons.person),
              ],
            ),
          ),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }
}
