import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../exceptions/upload_file_exception.dart';

class ImagesStorage {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> uploadImage(File file) async {
    String route = 'items_images';
    final fileName = (file.path.split('/').last);
    final destination = '$route/$fileName';
    try {
      await storage.ref(destination).putFile(file);

      final ref = storage.ref().child(destination);

      var completeUrl = await ref.getDownloadURL();

      return completeUrl;
    } on FirebaseException catch (e) {
      throw UploadFileException(message: e.message);
    }
  }
}
