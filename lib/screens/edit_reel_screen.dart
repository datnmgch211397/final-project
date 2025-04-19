import 'dart:io';

import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/firebase_service/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class EditReelScreen extends StatefulWidget {
  EditReelScreen(this.videlFile, {super.key});
  File videlFile;

  @override
  State<EditReelScreen> createState() => _EditReelScreenState();
}

class _EditReelScreenState extends State<EditReelScreen> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.file(widget.videlFile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('New Reel', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.black))
                : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    children: [
                      SizedBox(height: 30.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Container(
                          width: 270.w,
                          height: 420.h,
                          child:
                              controller.value.isInitialized
                                  ? AspectRatio(
                                    aspectRatio: controller.value.aspectRatio,
                                    child: VideoPlayer(controller),
                                  )
                                  : CircularProgressIndicator(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        height: 60.w,
                        width: 280.w,
                        child: TextField(
                          controller: caption,
                          maxLength: 15,
                          decoration: InputDecoration(
                            hintText: 'Add a caption...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 45.h,
                            width: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              'Safe draft',
                              style: TextStyle(color: Colors.black,
                              fontSize: 16.sp,),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              String reelsUrl = await StorageMethod()
                                  .uploadImageToStorage(
                                    'Reels',
                                    widget.videlFile,
                                  );
                              await Firebase_Firestore().createReels(
                                video: reelsUrl,
                                caption: caption.text,
                              );
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 45.h,
                              width: 150.w,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Text(
                                'Share',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
