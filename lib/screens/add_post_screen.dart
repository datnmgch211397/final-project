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
