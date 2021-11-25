import 'dart:io';

import 'package:chitchat/home_screen.dart';
import 'package:chitchat/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> UserMap;
  String chatRoomId;

  ChatScreen({required this.chatRoomId, required this.UserMap});
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _messege = TextEditingController();

  File? imageFile;

  Future getImages() async {
    ImagePicker picker = ImagePicker();

    await picker.pickImage(source: ImageSource.gallery).then((XFile) {
      if (XFile != null) {
        imageFile = File(XFile.path);
        uploadImages();
      }
    });
  }

  Future uploadImages() async {
    String FileName = Uuid().v1();
    int status = 1;
    var ref = await FirebaseStorage.instance.ref().child("$FileName.jpg");

    await firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(FileName)
        .set({
      "sendby": auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp()
    });

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(FileName)
          .delete();

      status = 0;
    });
    if (status == 1) {
      String imageURL = await uploadTask.ref.getDownloadURL();
      await firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(FileName)
          .update({"message": imageURL});

      print(imageURL);
    }

    // String imageURL = await uploadTask.ref.getDownloadURL();
  }

  void MessageSend() async {
    if (_messege.text.isNotEmpty) {
      var LastMessage = DateTime.now();

      Map<String, dynamic> messages = {
        "sendby": auth.currentUser!.displayName,
        "message": _messege.text,
        "type": "text",
        "time": FieldValue.serverTimestamp()
      };
      await firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);

      _messege.clear();
    } else {
      print("Enter text to send");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff8c49f2),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()))),
        title: StreamBuilder<DocumentSnapshot>(
          stream: firestore.collection("Users").doc(UserMap['uid']).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Column(
                  children: [
                    Text(UserMap['name']),
                    Text(
                      snapshot.data!['status'],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          Container(
            height: size.height / 1.25,
            width: size.width,
            child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('chatroom')
                    .doc(chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic>? map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return Message(size, map, context);
                        });
                  } else {
                    return Container();
                  }
                }),
          ),
          Container(
            height: size.height / 10,
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    height: size.height / 13,
                    width: size.width / 1.2,
                    child: TextField(
                      controller: _messege,
                      decoration: InputDecoration(
                          suffix: IconButton(
                              onPressed: () => getImages(),
                              icon: Icon(Icons.image, color: Colors.black)),
                          hintText: "Enter Message to Send",
                          hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                              fontFamily: "Times new roman"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7),
                          )),
                    ),
                  ),
                  IconButton(
                      onPressed: () => MessageSend(),
                      icon: Icon(Icons.send_sharp))
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget Message(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment: map['sendby'] == auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: map['sendby'] == auth.currentUser!.displayName
                        ? Color(0xff8c49f2)
                        : Colors.purpleAccent[200]),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(map['message'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600))))
        : Container(
            height: size.height / 2.3,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment: map['sendby'] == auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FullImages(ImageURL: map['message']))),
                child: Container(
                  height: size.height / 2.3,
                  width: size.width / 2,
                  decoration: BoxDecoration(border: Border.all()),
                  alignment: map['message'] != "" ? null : Alignment.center,
                  child: map['message'] != ""
                      ? Image.network(
                          map['message'],
                          fit: BoxFit.cover,
                        )
                      : CircularProgressIndicator(),
                )));
  }
}

class FullImages extends StatelessWidget {
  final String ImageURL;
  const FullImages({Key? key, required this.ImageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(ImageURL),
      ),
    );
  }
}
