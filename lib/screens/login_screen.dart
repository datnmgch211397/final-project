import 'package:final_app2/data/firebase_service/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.show, {super.key});
  final VoidCallback show;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  FocusNode emailFocus = FocusNode();
  final password = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(width: 96.w, height: 100.h),
            Center(
              child: Image.asset(
                'assets/images/logo.webp',
                width: 200.w,
                height: 200.h,
              ),
            ),
            SizedBox(height: 120.h),
            textField(email, Icons.email, 'Email', emailFocus),
            SizedBox(height: 15.h),
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
            forgot(),
            SizedBox(height: 10.h),
            login(),
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
            'Don\'t have an account?',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          InkWell(
            onTap: widget.show,
            child: Text(
              'Sign up',
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

  Widget login() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: InkWell(
        onTap: () async {
          await Authentication().Login(
            email: email.text,
            password: password.text,
          );
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
            'Login',
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
