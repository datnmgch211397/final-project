import 'package:final_app2/auth/auth_screen.dart';
import 'package:final_app2/screens/home.dart';
import 'package:final_app2/widgets/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const NavigationsScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
