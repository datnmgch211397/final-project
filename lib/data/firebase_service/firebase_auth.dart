import 'dart:io';

import 'package:final_app2/data/firebase_service/firestore.dart';
import 'package:final_app2/data/firebase_service/storage.dart';
import 'package:final_app2/util/exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> loginWithGoogle() async {
    try {
      await GoogleSignIn().signOut();
      final googleUser = await GoogleSignIn().signIn();
      final googleAuth = await googleUser?.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      final userCredential = await _auth.signInWithCredential(cred);
      try {
        await Firebase_Firestore().getUser(uidd: userCredential.user!.uid);
      } catch (e) {
        await Firebase_Firestore().createUser(
          email: userCredential.user!.email!,
          username: userCredential.user!.displayName!,
          bio: '',
          profile:
              userCredential.user!.photoURL! ??
              'https://firebasestorage.googleapis.com/v0/b/final-app-6c3b5.firebasestorage.app/o/person.jpg?alt=media&token=1a434bc6-07fb-4af6-babd-cb1c4c5fa40e',
        phoneNumber: '',
        
        );
      }
      return userCredential;
    } catch (e) {
      throw exceptions(e.toString());
    }
  }

Future<UserCredential> verifySMSCode(
    {required String verificationId, required String smsCode}) async {
  try {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    final userCredential = await _auth.signInWithCredential(credential);

    try {
      await Firebase_Firestore().getUser(uidd: userCredential.user!.uid);
    } catch (e) {
      await Firebase_Firestore().createUser(
        email: '',
        username: 'New User',
        bio: '',
        profile:
            'https://firebasestorage.googleapis.com/v0/b/final-app-6c3b5.firebasestorage.app/o/person.jpg?alt=media&token=1a434bc6-07fb-4af6-babd-cb1c4c5fa40e',
        phoneNumber: userCredential.user?.phoneNumber ?? '',
      );
    }

    return userCredential;
  } catch (e) {
    throw exceptions(e.toString());
  }
}

Future<void> loginWithPhoneNumber({
  required String phoneNumber,
  required Function(String verificationId) onCodeSent,
  required Function(String error) onError,
}) async {
  try {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Phone verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
      },
    );
  } catch (e) {
    onError(e.toString());
  }
}

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
            phoneNumber: '',
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
