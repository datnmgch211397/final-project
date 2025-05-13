import 'dart:io';

import 'package:final_app2/data/firebase_service/firebase_auth.dart';
import 'package:final_app2/screens/otp_screen.dart';
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
  final password = TextEditingController();
  final passwordConfirm = TextEditingController();
  final username = TextEditingController();
  final bio = TextEditingController();

  File? _imageFile;
  bool obscurePassword = true;
  bool isLoading = false;

  void _showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _handleEmailSignUp() async {
    try {
      if (email.text.isEmpty ||
          password.text.isEmpty ||
          passwordConfirm.text.isEmpty ||
          username.text.isEmpty ||
          bio.text.isEmpty) {
        throw exceptions("Please fill in all fields");
      }

      if (password.text != passwordConfirm.text) {
        throw exceptions("Passwords do not match");
      }

      File profileImage = _imageFile ?? File('assets/images/person.jpg');

      setState(() => isLoading = true);
      await Authentication().signUp(
        email: email.text,
        password: password.text,
        passwordConfirm: passwordConfirm.text,
        username: username.text,
        bio: bio.text,
        profile: profileImage,
      );
      _showSnack("Signup successful!", color: Colors.green);
    } on exceptions catch (e) {
      dialogBuilder(context, e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleGoogleSignUp() async {
    setState(() => isLoading = true);
    try {
      await Authentication().loginWithGoogle();
      _showSnack("Google sign-in successful!", color: Colors.green);
    } catch (e) {
      _showSnack("Google sign-in failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handlePhoneSignup() {
    showDialog(
      context: context,
      builder: (context) {
        final phoneDialogController = TextEditingController();

        return AlertDialog(
          title: const Text("Phone Signup"),
          content: TextField(
            controller: phoneDialogController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: "Phone Number (e.g., 0397778888)",
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final phone = phoneDialogController.text.trim();
                if (phone.isEmpty || phone.length < 9) {
                  _showSnack("Please enter a valid phone number");
                  return;
                }

                final fullPhoneNumber = "+84${phone.replaceFirst('0', '')}";
                Navigator.pop(context);
                _sendOtp(fullPhoneNumber);
              },
              child: const Text("Send OTP"),
            ),
          ],
        );
      },
    );
  }

  void _sendOtp(String fullPhoneNumber) async {
    setState(() => isLoading = true);
    try {
      await Authentication().loginWithPhoneNumber(
        phoneNumber: fullPhoneNumber,
        onCodeSent: (verificationId) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        onError: (error) {
          _showSnack("Failed to send OTP: $error");
        },
      );
    } catch (e) {
      _showSnack("Phone signup failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscureText,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: toggleObscureText,
                )
              : null,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Center(
                  child: Image.asset(
                    'assets/images/logo.webp',
                    width: 180.w,
                    height: 120.h,
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: () async {
                    final pickedImage =
                        await ImagePickerr().uploadImage('gallery');
                    setState(() => _imageFile = pickedImage);
                  },
                  child: CircleAvatar(
                    radius: 36.r,
                    backgroundColor: Colors.grey,
                    child: CircleAvatar(
                      radius: 35.r,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : const AssetImage('assets/images/person.jpg')
                              as ImageProvider,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                buildTextField(
                    label: "Email", icon: Icons.email, controller: email),
                buildTextField(
                    label: "Username", icon: Icons.person, controller: username),
                buildTextField(
                    label: "Bio", icon: Icons.info, controller: bio),
                buildTextField(
                  label: "Password",
                  icon: Icons.lock,
                  controller: password,
                  isPassword: true,
                  obscureText: obscurePassword,
                  toggleObscureText: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                buildTextField(
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  controller: passwordConfirm,
                  isPassword: true,
                  obscureText: obscurePassword,
                  toggleObscureText: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleEmailSignUp,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign up"),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(
                      imagePath: 'assets/images/gmail.jpg',
                      onTap: isLoading ? null : _handleGoogleSignUp,
                    ),
                    SizedBox(width: 20.w),
                    _circleButton(
                      imagePath: 'assets/images/phone.png',
                      onTap: isLoading ? null : _handlePhoneSignup,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: widget.show,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required String imagePath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 25.r,
        backgroundColor: Colors.grey.shade200,
        child: Image.asset(imagePath, width: 30.w, height: 30.h),
      ),
    );
  }
}
