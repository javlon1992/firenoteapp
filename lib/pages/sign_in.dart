
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firenoteapp/pages/home_page.dart';
import 'package:firenoteapp/pages/sign_up.dart';
import 'package:firenoteapp/services/auth_service.dart';
import 'package:firenoteapp/services/hive_service.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  static String id = "sign_in_page";
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isLoad = false;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

 void _doLogIn(BuildContext context) async{
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if(email.isEmpty || password.isEmpty){
      AuthService.showSnackBar(context,"Check email and password");
      return;
    }else {
      AuthService.signInUser(context, email, password).then((firebaseUser) => _getFirebaseUser(context, firebaseUser));
    }
  }

  void _getFirebaseUser(BuildContext context,User? firebaseUser) async{
   if(firebaseUser != null){
     isLoad = true;
     await HiveDB.saveUserId(firebaseUser.uid);
     setState(() {isLoad = false;});
     Navigator.pushReplacementNamed(context, HomePage.id);
   }else{
     AuthService.showSnackBar(context,"No such account");
   }
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoad ? const Center(child: CircularProgressIndicator.adaptive())
      : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// #email
              TextField(
                textInputAction: TextInputAction.next,
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              SizedBox(height: 10,),

              /// #password
              TextField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
              ),
              SizedBox(height: 10,),

              /// #sign_in
              MaterialButton(
                onPressed: () {
                  _doLogIn(context);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                height: 50,
                minWidth: MediaQuery.of(context).size.width - 50,
                color: Colors.blueAccent,
                child: Text("Sign In"),
                textColor: Colors.white,
              ),
              SizedBox(height: 20,),

              // #don't_have_account
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, SignUpPage.id);
                    },
                    child: Text("Sign Up", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}