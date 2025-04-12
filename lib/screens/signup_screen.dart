import 'dart:io';

import 'package:final_app2/data/firebase_service/firebase_auth.dart';
import 'package:final_app2/util/dialog.dart';
import 'package:final_app2/util/exception.dart';
import 'package:final_app2/util/imagepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen(this.show, {super.key});
  final VoidCallback show;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final email = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final password = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  final bio = TextEditingController();
  FocusNode bioFocus = FocusNode();
  final username = TextEditingController();
  FocusNode usernameFocus = FocusNode();
  final passwordConfirm = TextEditingController();
  FocusNode passwordConfirmFocus = FocusNode();
  File? _imageFile;
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 96.w, height: 40.h),
            Center(
              child: Image.asset(
                'assets/images/logo.webp',
                width: 200.w,
                height: 150.h,
              ),
            ),
            SizedBox(height: 40.h),
            Center(
              child: InkWell(
                onTap: () async {
                  File _imageFilee = await ImagePickerr().uploadImage(
                    'gallery',
                  );
                  setState(() {
                    _imageFile = _imageFilee;
                  });
                },
                child:
                    _imageFile == null
                        ? CircleAvatar(
                          radius: 36.r,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 34.r,
                            backgroundColor: Colors.grey.shade100,
                            backgroundImage: const AssetImage(
                              'assets/images/person.jpg',
                            ),
                          ),
                        )
                        : CircleAvatar(
                          radius: 36.r,
                          backgroundColor: Colors.grey,
                          child: CircleAvatar(
                            radius: 34.r,

                            backgroundImage:
                                Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ).image,
                            backgroundColor: Colors.grey.shade100,
                          ),
                        ),
              ),
            ),
            SizedBox(height: 30.h),
            textField(email, Icons.email, 'Email', emailFocus),
            SizedBox(height: 15.h),
            textField(username, Icons.person, 'Username', usernameFocus),
            SizedBox(height: 10.h),
            textField(bio, Icons.abc, 'bio', bioFocus),
            SizedBox(height: 10.h),
            textField(
              password,
              Icons.lock,
              'Password',
              passwordFocus,
              isPassword: true,
              obscureText: obscurePassword,
              toggleObscureText:
                  () => setState(() {
                    obscurePassword = !obscurePassword;
                  }),
            ),
            SizedBox(height: 10.h),
            textField(
              passwordConfirm,
              Icons.lock,
              'Confirm Password',
              passwordConfirmFocus,
              isPassword: true,
              obscureText: obscurePassword,
              toggleObscureText:
                  () => setState(() {
                    obscurePassword = !obscurePassword;
                  }),
            ),
            SizedBox(height: 20.h),
            signup(),
            SizedBox(height: 10.h),
            haveAccount(),
          ],
        ),
      ),
    );
  }

  Widget haveAccount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: widget.show,
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget signup() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: InkWell(
        onTap: () async {
          try {
            if (email.text.isEmpty ||
                password.text.isEmpty ||
                username.text.isEmpty ||
                bio.text.isEmpty) {
              throw exceptions('Please fill all fields');
            }

            if (password.text != passwordConfirm.text) {
              throw exceptions('Passwords do not match');
            }

            // Use default profile image if no image is selected
            File profileImage = _imageFile ?? File('assets/images/person.jpg');

            await Authentication().signUp(
              email: email.text,
              password: password.text,
              passwordConfirm: passwordConfirm.text,
              username: username.text,
              bio: bio.text,
              profile: profileImage,
            );
          } on exceptions catch (e) {
            dialogBuilder(context, e.message);
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'Sign up',
            style: TextStyle(
              fontSize: 23.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget forgot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget textField(
  TextEditingController controller,
  IconData icon,
  String type,
  FocusNode focusNode, {
  bool isPassword = false,
  bool obscureText = false,
  VoidCallback? toggleObscureText,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),

      child: TextField(
        style: TextStyle(fontSize: 18.sp, color: Colors.black),
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword ? obscureText : false,
        decoration: InputDecoration(
          hintText: type,
          prefixIcon: Icon(
            icon,
            color: focusNode.hasFocus ? Colors.black : Colors.grey,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: toggleObscureText,
                  )
                  : null,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 15.w,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
            borderSide: const BorderSide(color: Colors.grey, width: 2.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.r),
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    ),
  );
}
