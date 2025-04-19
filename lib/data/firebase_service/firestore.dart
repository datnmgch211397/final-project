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

  Future<UserModel> getUser({String? uidd}) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      final user =
          await _firebaseFirestore
              .collection('users')
              .doc(uidd ?? _auth.currentUser!.uid)
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

  Future<bool> createPost({
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

  Future<bool> createReels({
    required String video,
    required String caption,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      var uid = Uuid().v4();
      DateTime data = DateTime.now();
      UserModel user = await getUser();

      await _firebaseFirestore.collection('reels').doc(uid).set({
        'video': video,
        'username': user.username,
        'profileImage': user.profile,
        'caption': caption,
        'uid': _auth.currentUser!.uid,
        'reelId': uid,
        'like': [],
        'time': data,
      });
      return true;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create reel: ${e.message}');
    } catch (e) {
      throw Exception('Error creating reel: $e');
    }
  }

  Future<bool> createComment({
    required String comment,
    required String type,
    required String uidd,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      var uid = Uuid().v4();
      UserModel user = await getUser();

      await _firebaseFirestore
          .collection(type)
          .doc(uidd)
          .collection('comments')
          .doc(uid)
          .set({
            'comment': comment,
            'username': user.username,
            'profileImage': user.profile,
            'commentUid': uid,
          });
      return true;
    } on FirebaseException catch (e) {
      throw Exception('Failed to create reel: ${e.message}');
    } catch (e) {
      throw Exception('Error creating reel: $e');
    }
  }

  Future<String> like({
    required List like,
    required String type,
    required String uid,
    required String postId,
  }) async {
    String res = 'error';
    try {
      if (like.contains(uid)) {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayRemove([uid]),
        });
      } else {
        _firebaseFirestore.collection(type).doc(postId).update({
          'like': FieldValue.arrayUnion([uid]),
        });
      }
      res = 'success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> follow({required String uid}) async {
    String res = 'error';
    DocumentSnapshot snap =
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .get();
    List follow = (snap.data() as dynamic)['following'];
    try {
      if (follow.contains(uid)) {
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
              'following': FieldValue.arrayRemove([uid]),
            });
        await _firebaseFirestore
            .collection('users')
            .doc(uid)
            .update({
              'followers': FieldValue.arrayRemove([_auth.currentUser!.uid]),
            });
      } else {
        await _firebaseFirestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
              'following': FieldValue.arrayUnion([uid]),
            });
        await _firebaseFirestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayUnion([_auth.currentUser!.uid]),
        });
      }
      res = 'success';
    } on Exception catch (e) {
      res = e.toString();
    }
    return res;
  }
}
