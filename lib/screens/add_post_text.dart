import 'dart:io';

import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/firebase_service/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostTextScreen extends StatefulWidget {
  AddPostTextScreen(this._file, {super.key});
  File _file;

  @override
  State<AddPostTextScreen> createState() => _AddPostTextScreenState();
}

class _AddPostTextScreenState extends State<AddPostTextScreen> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('New Post', style: TextStyle(color: Colors.black)),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () async {
                  try {
                    setState(() {
                      isLoading = true;
                    });

                    // Check if user is logged in
                    if (FirebaseAuth.instance.currentUser == null) {
                      throw Exception('User not logged in');
                    }

                    // Upload image to storage
                    String post_url = await StorageMethod()
                        .uploadImageToStorage('post', widget._file);

                    // Create post in Firestore
                    await Firebase_Firestore().CreatePost(
                      postImage: post_url,
                      caption: caption.text,
                      location: location.text,
                    );

                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
                child: Text(
                  'Share',
                  style: TextStyle(color: Colors.blue, fontSize: 15.sp),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 65.w,
                              height: 65.h,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                image: DecorationImage(
                                  image: FileImage(widget._file),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            SizedBox(
                              width: 280.w,
                              height: 60.h,
                              child: TextField(
                                controller: caption,
                                decoration: const InputDecoration(
                                  hintText: 'Write a caption...',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: SizedBox(
                          width: 280.w,
                          height: 30.h,
                          child: TextField(
                            controller: location,
                            decoration: const InputDecoration(
                              hintText: 'Add location...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
