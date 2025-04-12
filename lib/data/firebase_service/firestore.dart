import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_app2/data/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class Firebase_Firestore {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<bool> createUser({
    required String email,
    required String username,
    required String bio,
    required String profile,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      await _firebaseFirestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set({
            'email': email,
            'username': username,
            'bio': bio,
            'profile': profile,
            'followers': [],
            'following': [],
          });
      return true;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create user: ${e.message}');
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<UserModel> getUser() async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      final user =
          await _firebaseFirestore
              .collection('users')
              .doc(_auth.currentUser!.uid)
              .get();

      if (!user.exists || user.data() == null) {
        throw Exception('User data not found');
      }

      final snapUser = user.data()!;

      // Check if all required fields exist
      if (snapUser['email'] == null ||
          snapUser['username'] == null ||
          snapUser['bio'] == null ||
          snapUser['profile'] == null ||
          snapUser['followers'] == null ||
          snapUser['following'] == null) {
        throw Exception('Missing required user data fields');
      }

      return UserModel(
        snapUser['email'],
        snapUser['username'],
        snapUser['bio'],
        snapUser['profile'],
        snapUser['followers'],
        snapUser['following'],
      );
    } on FirebaseException catch (e) {
      throw Exception('Firebase error: ${e.message}');
    } catch (e) {
      throw Exception('Error getting user data: $e');
    }
  }

  Future<bool> CreatePost({
    required String postImage,
    required String caption,
    required String location,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      var uid = Uuid().v4();
      DateTime data = DateTime.now();
      UserModel user = await getUser();

      await _firebaseFirestore.collection('posts').doc(uid).set({
        'postImage': postImage,
        'username': user.username,
        'profileImage': user.profile,
        'caption': caption,
        'location': location,
        'uid': _auth.currentUser!.uid,
        'postId': uid,
        'like': [],
        'time': data,
      });
      return true;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create post: ${e.message}');
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }
}
