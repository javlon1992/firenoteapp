import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firenoteapp/pages/detail_page.dart';
import 'package:firenoteapp/pages/home_page.dart';
import 'package:firenoteapp/pages/sign_in.dart';
import 'package:firenoteapp/pages/sign_up.dart';
import 'package:firenoteapp/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  /// #FireBase uchun
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// #Hive uchun
  await Hive.initFlutter();
  await Hive.openBox(HiveDB.dbName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _startPage(),
      routes: {
        SignInPage.id: (context) => SignInPage(),
        SignUpPage.id: (context) => SignUpPage(),
        HomePage.id: (context) => HomePage(),
        DetailPage.id: (context) => DetailPage(),
      },
    );
  }

  Widget _startPage(){
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator.adaptive());
        }else if(snapshot.hasError){
          return const Center(child: Text("Something went wrong!"));
        }else if(snapshot.hasData){
          return const HomePage();
        }else{
          return const SignInPage();
        }
        });

  }
}
