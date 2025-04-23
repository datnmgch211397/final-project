import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CachedImage extends StatelessWidget {
  CachedImage(this.imageUrl, {super.key});
  String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageUrl!,
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          child: Padding(
            padding: EdgeInsets.all(130.h),
            child: CircularProgressIndicator(
              value: progress.progress,
              color: Colors.black,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) => Container(color: Colors.amber),
    );
  }
}
