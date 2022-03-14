import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDB {
  static const String dbName = "firenoteapp";
  static var box = Hive.box(dbName);

  static Future<void> saveUserId(String userId) async{
    await box.put(userId, userId);
  }

  static String loadUserId(String userId) {
    var user = box.get(userId);
    return user;
  }

  static Future<void> removeUserId(String userId) async {
    await box.delete(userId);
  }
}
