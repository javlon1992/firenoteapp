
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firenoteapp/pages/sign_in.dart';
import 'package:firenoteapp/services/auth_service.dart';
import 'package:firenoteapp/services/hive_service.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  static String id = "sign_up_page";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoad = false;
  var emailController = TextEditingController();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var passwordController = TextEditingController();

  void _doSingUp(BuildContext context){
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      AuthService.showSnackBar(context, "Check all information");
      return;
    }else {
      AuthService.signUpUser(context,"$firstName $lastName",email, password).then((firebaseUser) => _getFirebaseUser(context,firebaseUser));
    }
  }

  void _getFirebaseUser(BuildContext context,User? firebaseUser,) async {
    if(firebaseUser != null){
       isLoad = true;
       await HiveDB.saveUserId(firebaseUser.uid);
       setState(() {isLoad = false;});
       Navigator.popAndPushNamed(context,SignInPage.id);
    }else{
      AuthService.showSnackBar(context, "Check all information");
    }
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
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

              // #firstname
              TextField(
                textInputAction: TextInputAction.next,
                controller: firstNameController,
                decoration: InputDecoration(hintText: "Firstname"),
              ),
              SizedBox(height: 10,),

              // #lastname
              TextField(
                textInputAction: TextInputAction.next,
                controller: lastNameController,
                decoration: InputDecoration(hintText: "Lastname"),
              ),
              SizedBox(height: 10,),

              // #email
              TextField(
                textInputAction: TextInputAction.next,
                controller: emailController,
                decoration: InputDecoration(hintText: "Email"),
              ),
              SizedBox(height: 10,),

              // #password
              TextField(
                controller: passwordController,
                decoration: InputDecoration(hintText: "Password"),
              ),
              SizedBox(height: 10,),

              // #sign_up
              MaterialButton(
                onPressed: () {
                   _doSingUp(context);
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                //focusNode: FocusNode(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                ),
                height: 50,
                minWidth: MediaQuery.of(context).size.width - 50,
                color: Colors.blueAccent,
                child: Text("Sign Up"),
                textColor: Colors.white,
              ),
              SizedBox(height: 20,),

              // #don't_have_account
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, SignInPage.id);
                    },
                    child: Text("Sign In", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
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
