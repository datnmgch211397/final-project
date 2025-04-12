import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethod {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String name, File file) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not logged in');
      }

      Reference ref = _storage.ref().child(name).child(_auth.currentUser!.uid);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
