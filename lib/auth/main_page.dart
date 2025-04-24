import 'package:final_app2/auth/auth_screen.dart';
import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/screens/admin/admin_screen.dart';
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
            // Check user role and redirect accordingly
            return FutureBuilder<bool>(
              future: Firebase_Firestore().isCurrentUserAdmin(),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If the user is admin, redirect to admin screen
                if (adminSnapshot.data == true) {
                  return const AdminScreen();
                }

                // Otherwise, redirect to the regular app
                return const NavigationsScreen();
              },
            );
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
