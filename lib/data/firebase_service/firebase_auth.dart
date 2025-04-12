import 'dart:io';

import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/firebase_service/storage.dart';
import 'package:final_app2/util/exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> Login({required String email, required String password}) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } else {
        throw exceptions('Please fill all fields');
      }
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String passwordConfirm,
    required String username,
    required String bio,
    required File profile,
  }) async {
    try {
      if (email.isNotEmpty &&
          password.isNotEmpty &&
          username.isNotEmpty &&
          bio.isNotEmpty) {
        if (password == passwordConfirm) {
          // Create user account
          await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

          String profileUrl = '';

          // Upload profile image if it exists and is readable
          if (await profile.exists()) {
            profileUrl = await StorageMethod().uploadImageToStorage(
              'Profile',
              profile,
            );
          } else {
            // Use default profile image URL if file doesn't exist
            profileUrl =
                'https://firebasestorage.googleapis.com/v0/b/final-app-6c3b5.firebasestorage.app/o/person.jpg?alt=media&token=1a434bc6-07fb-4af6-babd-cb1c4c5fa40e';
          }

          // Create user document in Firestore
          await Firebase_Firestore().createUser(
            email: email,
            username: username,
            bio: bio,
            profile: profileUrl,
          );
        } else {
          throw exceptions('Passwords do not match');
        }
      } else {
        throw exceptions('Please fill all fields');
      }
    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    } catch (e) {
      throw exceptions(e.toString());
    }
  }
}
