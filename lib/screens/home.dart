import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/screens/add_screen.dart';
import 'package:final_app2/screens/chat_screen.dart';
import 'package:final_app2/screens/inbox_screen.dart';
import 'package:final_app2/widgets/post_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,

        elevation: 0,
        title: SizedBox(
          width: 130.w,
          height: 50.h,
          child: Image.asset('assets/images/textlogo.png'),
        ),
        // leading: Image.asset('assets/images/camera.jpg'),
        leading: IconButton(
          icon: const Icon(Icons.camera_alt_outlined, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddScreen()),
            );
          },
        ),
        actions: [
          const Icon(
            Icons.favorite_border_outlined,
            color: Colors.black,
            size: 25,
          ),
          // Image.asset('assets/images/send2.png', width: 25.w, height: 25.h),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InboxScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(
                  '/login_screen',
                ); // Điều hướng về trang login
              }
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(246, 246, 246, 255),
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream:
                _firebaseFirestore
                    .collection('posts')
                    .orderBy('time', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return PostWidget(snapshot.data!.docs[index].data());
                  },
                  childCount:
                      snapshot.data == null ? 0 : snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
