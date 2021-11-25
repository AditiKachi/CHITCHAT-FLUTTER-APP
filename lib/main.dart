// ignore: unused_import
import 'package:chitchat/home_screen.dart';
import 'package:chitchat/login_page.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color mainColor = Color(0xff8c49f2);
    return MaterialApp(
      theme: ThemeData(primaryColor: mainColor),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
