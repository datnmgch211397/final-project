// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:photo_manager/photo_manager.dart';

// class AddPostScreen extends StatefulWidget {
//   const AddPostScreen({super.key});

//   @override
//   State<AddPostScreen> createState() => _AddPostScreenState();
// }

// class _AddPostScreenState extends State<AddPostScreen> {
//   final List<Widget> _mediaList = [];
//   final List<File> path = [];
//   File? _file;
//   int currentPage = 0;
//   int? lastPage;

//   @override
//   // _fetchNewMedia() async {
//   //   lastPage = currentPage;
//   //   final PermissionState ps = await PhotoManager.requestPermissionExtend();
//   //   if (ps.isAuth) {
//   //     List<AssetPathEntity> album = await PhotoManager.getAssetPathList(
//   //       onlyAll: true,
//   //     );
//   //     List<AssetEntity> media = await album[0].getAssetListPaged(
//   //       page: currentPage,
//   //       size: 60,
//   //     );

//   //     for (var asset in media) {
//   //       if (asset.type == AssetType.image) {
//   //         final file = await asset.file;
//   //         if (file != null) {
//   //           path.add(File(file.path));
//   //           _file = path[0];
//   //         }
//   //       }
//   //     }
//   //     List<Widget> temp = [];
//   //     for (var asset in media) {
//   //       temp.add(
//   //         FutureBuilder(
//   //           future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
//   //           builder: (context, snapshot) {
//   //             if (snapshot.connectionState == ConnectionState.done) {
//   //               return Container(
//   //                 child: Stack(
//   //                   children: [
//   //                     Positioned.fill(
//   //                       child: Image.memory(snapshot.data!, fit: BoxFit.cover),
//   //                     ),
//   //                   ],
//   //                 ),
//   //               );
//   //             }
//   //             return Container();
//   //           },
//   //         ),
//   //       );
//   //     }
//   //   }
//   // }

//   @override
//   // void initState() {
//   //   super.initState();
//   //   _fetchNewMedia();
//   // }

//   int indexx = 0;
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('New Post', style: TextStyle(color: Colors.black)),
//         centerTitle: false,
//         actions: [
//           Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10.w),
//               child: Text(
//                 'Next',
//                 style: TextStyle(fontSize: 15.sp, color: Colors.blue),
//               ),
//             ),
//           ),
//         ],
//         backgroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 375.h,
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 1,
//                   mainAxisSpacing: 1,
//                   crossAxisSpacing: 1,
//                 ),
//                 itemBuilder: (context, index) {
//                   return _mediaList[index];
//                 },
//               ),
//             ),
//             Container(
//               width: double.infinity,
//               height: 40.h,
//               color: Colors.white,
//               child: Row(
//                 children: [
//                   Text(
//                     'Recent',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             GridView.builder(
//               shrinkWrap: true,
//               itemCount: _mediaList.length,
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 1,
//                 mainAxisSpacing: 1,
//                 crossAxisSpacing: 1,
//               ),
//               itemBuilder: (context, index) {
//                 return GestureDetector(onTap: () {
//                   setState(() {
//                     indexx = index;
//                   });
//                 }, child: _mediaList[index]);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:final_app2/screens/add_post_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  File? _selectedImage; // Biến lưu ảnh được chọn
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Cập nhật ảnh được chọn
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>  AddPostTextScreen(_selectedImage!),
                    ),
                  );
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 15.sp, color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 40.h,
            color: Colors.white,
            child: Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick from Gallery'),
              ),
            ),
          ),
          // Hiển thị ảnh lớn ở trên cùng
          SizedBox(
            height: 375.h,
            child:
                _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Center(
                      child: Text(
                        'No image selected',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
          ),

   
        ],
      ),
    );
  }
}
