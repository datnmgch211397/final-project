import 'package:final_app2/data/firebase_service/firebase_auth.dart';
import 'package:final_app2/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen(this.show, {super.key});
  final VoidCallback show;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscurePassword = true;
  bool showPhoneInput = false;
  bool isLoading = false;

  void _showSnack(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  void _handleEmailLogin() async {
    try {
      setState(() => isLoading = true);
      await Authentication().Login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      _showSnack('Login successful', color: Colors.green);
    } catch (e) {
      _showSnack('Login failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handleGoogleLogin() async {
    try {
      setState(() => isLoading = true);
      await Authentication().loginWithGoogle();
      _showSnack('Google login successful', color: Colors.green);
    } catch (e) {
      _showSnack('Google login failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _handlePhoneLogin() {
    showDialog(
      context: context,
      builder: (context) {
        final phoneDialogController = TextEditingController();

        return AlertDialog(
          title: const Text("Phone Login"),
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
              onPressed: () {
                Navigator.pop(context);
              },
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
                _sendOtpWithPhone(fullPhoneNumber);
              },
              child: const Text("Send OTP"),
            ),
          ],
        );
      },
    );
  }

  void _sendOtpWithPhone(String fullPhoneNumber) async {
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
      _showSnack("Phone login failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
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
                SizedBox(height: 50.h),
                Center(
                  child: Image.asset(
                    'assets/images/logo.webp',
                    width: 150.w,
                    height: 150.h,
                  ),
                ),
                SizedBox(height: 30.h),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 45.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleEmailLogin,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login with Email"),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(
                      imagePath: 'assets/images/gmail.jpg',
                      onTap: isLoading ? null : _handleGoogleLogin,
                    ),
                    SizedBox(width: 20.w),
                    _circleButton(
                      imagePath: 'assets/images/phone.png',
                      onTap: isLoading ? null : _handlePhoneLogin,
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: widget.show,
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleButton({required String imagePath, VoidCallback? onTap}) {
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
