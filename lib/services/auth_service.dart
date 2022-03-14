import 'package:firebase_auth/firebase_auth.dart';
import 'package:firenoteapp/pages/sign_in.dart';
import 'package:firenoteapp/services/hive_service.dart';
import 'package:flutter/material.dart';

class AuthService{
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// #SignIn
  static Future<User?> signInUser(BuildContext context,String email,String password) async{
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password,);
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(context, "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        showSnackBar(context, "Wrong password provided for that user.");
      }
    }
    return null;
  }

  /// #SignUp
  static Future<User?> signUpUser(BuildContext context,String name,String email, String password) async{
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password,);
      await userCredential.user?.updateDisplayName(name);
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, "The account already exists for that email.");
      }
    }
    return null;
  }

  static User? getCurrentUser() {
    User? user = _auth.currentUser;
     return user;
  }

  /// #LogOut
  static void logOutUser(BuildContext context) async{
   await _auth.signOut();
   HiveDB.removeUserId(_auth.currentUser!.uid).then((value) => Navigator.pushReplacementNamed(context,SignInPage.id));
  }

  /// #Delete
  static Future<void> deleteUser(BuildContext context) async {
    try {
      await _auth.currentUser!.delete();
      HiveDB.removeUserId(_auth.currentUser!.uid).then((value) => Navigator.pushReplacementNamed(context, SignInPage.id));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showSnackBar(context, "The user must reauthenticate before this operation can be executed.");
      }
    }

  }

  /// #ShowSnackBar
  static void showSnackBar(BuildContext context,String text){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text),));
  }

}