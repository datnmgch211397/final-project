import 'package:date_format/date_format.dart';
import 'package:final_app2/util/image_cached.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostWidget extends StatefulWidget {
  const PostWidget(this.snapshot, {super.key});
  final snapshot;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 375.w,
          height: 54.h,
          color: Colors.white,
          child: Center(
            child: ListTile(
              leading: ClipOval(
                child: SizedBox(
                  width: 35.w,
                  height: 35.h,
                  child: CachedImage(widget.snapshot['profileImage']),
                ),
              ),
              title: Text(
                widget.snapshot['username'],
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                widget.snapshot['location'],
                style: TextStyle(fontSize: 11.sp),
              ),
              trailing: const Icon(Icons.more_horiz),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: 375.w,
          height: 375.h,
          child: CachedImage(widget.snapshot['postImage']),
        ),
        Container(
          width: 375.w,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 14.h),
              Row(
                children: [
                  SizedBox(width: 14.w),
                  Icon(Icons.favorite_outline, size: 25.w),
                  SizedBox(width: 17.w),
                  Image.asset('assets/images/comment.webp', height: 30.h),
                  SizedBox(width: 17.w),
                  Image.asset('assets/images/send2.png', height: 28.h),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: Image.asset('assets/images/save.png', height: 28.h),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 19.w, top: 13.5.h, bottom: 5.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.snapshot['like'].length.toString(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  children: [
                    Text(
                      widget.snapshot['username'] + '',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.snapshot['caption'],
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w, top: 20.h, bottom: 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatDate(widget.snapshot['time'].toDate(), [yyyy, '-', mm, '-', dd]),
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
