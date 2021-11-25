import 'package:chitchat/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<User?> CreateAccountFun(
    String name, String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print("Account Created Successfull");

      user.updateProfile(displayName: name);
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).set({
        'name': name,
        'email': email,
        'Status': 'Offline',
        'uid': _auth.currentUser!.uid
      });
      return user;
    } else {
      print("account creation failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> LoginFunc(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print("Login Successfull");
      return user;
    } else {
      print("login failed");
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> LogOutFunc(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    ToastMessage("Logged Out Successfully");
    await _auth.signOut().then(
          (value) => Navigator.push(
              context, MaterialPageRoute(builder: (_) => LoginPage())),
        );
  } catch (e) {
    print("error");
    return null;
  }
}

void ToastMessage(String message) => Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 16.0);
