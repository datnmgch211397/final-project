// import 'dart:io';

// import 'package:final_app2/screens/edit_reel_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AddReelsScreen extends StatefulWidget {
//   const AddReelsScreen({super.key});

//   @override
//   State<AddReelsScreen> createState() => _AddReelsScreenState();
// }

// class _AddReelsScreenState extends State<AddReelsScreen> {
//   final List<Widget> _mediaList = [];
//   final List<File> path = [];
//   File? _file;
//   int currentPage = 0;
//   int? lastPage;
//   @override
//   _fetchNewMedia() async {
//     lastPage = currentPage;
//     final PermissionState ps = await PhotoManager.requestPermissionExtend();
//     if (ps.isAuth) {
//       List<AssetPathEntity> album = await PhotoManager.getAssetPathList(
//         type: RequestType.video,
//       );
//       List<AssetEntity> media = await album[0].getAssetListPaged(
//         page: currentPage,
//         size: 60,
//       );

//       for (var asset in media) {
//         if (asset.type == AssetType.video) {
//           final file = await asset.file;
//           if (file != null) {
//             path.add(File(file.path));
//             _file = path[0];
//           }
//         }
//       }
//       List<Widget> temp = [];
//       for (var asset in media) {
//         temp.add(
//           FutureBuilder(
//             future: asset.thumbnailDataWithSize(ThumbnailSize(200, 200)),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done)
//                 return Container(
//                   child: Stack(
//                     children: [
//                       Positioned.fill(
//                         child: Image.memory(snapshot.data!, fit: BoxFit.cover),
//                       ),
//                       if (asset.type == AssetType.video)
//                         Align(
//                           alignment: Alignment.bottomRight,
//                           child: Container(
//                             alignment: Alignment.center,
//                             width: 35.w,
//                             height: 15.h,
//                             child: Row(
//                               children: [
//                                 Text(
//                                   asset.videoDuration.inMinutes.toString(),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                  Text(
//                                   ':',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                  Text(
//                                   asset.videoDuration.inSeconds.toString(),
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w400,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 );

//               return Container();
//             },
//           ),
//         );
//       }
//       setState(() {
//         _mediaList.addAll(temp);
//         currentPage++;
//       });
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _fetchNewMedia();
//   }

//   int indexx = 0;

//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: false,
//         title: const Text('New Reel', style: TextStyle(color: Colors.black)),
//         backgroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: GridView.builder(
//           shrinkWrap: true,
//           itemCount: _mediaList.length,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             mainAxisSpacing: 5.h,
//             crossAxisSpacing: 3.w,
//             mainAxisExtent: 250,
//           ),
//           itemBuilder: (context, index) {
//             return GestureDetector(onTap: () {
//               setState(() {
//                 indexx = index;
//                 _file = path[index];
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => EditReelScreen(_file!),
//                 ));
//               });
//             },child: _mediaList[index]);
//           },
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';

import 'package:final_app2/screens/edit_reel_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class AddReelsScreen extends StatefulWidget {
  const AddReelsScreen({super.key});

  @override
  State<AddReelsScreen> createState() => _AddReelsScreenState();
}

class _AddReelsScreenState extends State<AddReelsScreen> {
  File? _selectedVideo; // Biến lưu video được chọn
  final ImagePicker _picker = ImagePicker();
  VideoPlayerController? _videoController;

  Future<void> _pickVideo() async {
    final XFile? pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery, // Hoặc ImageSource.camera để quay video
    );
    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path); // Cập nhật video được chọn
        _videoController = VideoPlayerController.file(_selectedVideo!)
          ..initialize().then((_) {
            setState(() {}); // Cập nhật UI sau khi video được load
          });
      });

      // Chuyển sang trang EditReelScreen ngay sau khi chọn video
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditReelScreen(_selectedVideo!),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('New Reel', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
              child: Center(
                child: ElevatedButton(
                  onPressed: _pickVideo,
                  child: const Text('Pick Video from Gallery'),
                ),
              ),
            ),
            Expanded(
              child: _selectedVideo != null
                  ? _videoController != null && _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const Center(child: CircularProgressIndicator())
                  : const Center(
                      child: Text(
                        'No video selected',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _videoController != null && _videoController!.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              child: Icon(
                _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }
}