
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folder = 'post_image';

  // static Future<String?> getImageUrl(File? _file) async {
  //   if(_file == null) return null;
  //   String imgName = "image_" + DateTime.now().toString();
  //   Reference fireBaseStorageRef = _storage.child(folder).child(imgName);
  //   await fireBaseStorageRef.putFile(_file).then((link) async {
  //     if (link.metadata != null) {
  //       String? url = await link.ref.getDownloadURL();
  //       return url;
  //     }
  //   });
  //   return null;
  // }
  static Future<String?> getImageUrl(File? _image) async {
    if(_image == null) return null;
    String imgName = "image_" + DateTime.now().toString();
    Reference firebaseStorageRef = _storage.child(folder).child(imgName);
    UploadTask uploadTask = firebaseStorageRef.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String? imgUrl = await taskSnapshot.ref.getDownloadURL();
    return imgUrl;
  }

  static Future<void> deleteImage(String? imageFileUrl) async {
    if(imageFileUrl == null) return;
    Reference photoRef = FirebaseStorage.instance.refFromURL(imageFileUrl);
    await photoRef.delete().then((value) {
      if (kDebugMode) {
        print('DDDDDDDDDDDDDDDDDDDDDDDD');
      }
    });
  }

  static Future<void> deletingFile(String folder) async {
    await _storage.child(folder).listAll().then((value) {
      for (var element in value.items) {
        element.delete();
      }
    }).catchError((e) {
      if (kDebugMode) {
        print(e);
      }
    });
  }
}