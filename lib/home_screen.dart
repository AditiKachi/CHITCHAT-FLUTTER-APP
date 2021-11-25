import 'dart:ffi';
import 'dart:math';
import 'package:chitchat/chat_screen.dart';
import 'package:chitchat/functions.dart';
import 'package:chitchat/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController SearchController = TextEditingController();
  Icon actionIcon = Icon(Icons.search);
  Widget appBarTitle = new Text("AppBar Title");
  bool isLoading = false;
  QuerySnapshot? snapshot;

  Map<String, dynamic> UserMap = SearchData.UserMap;

  //Map<String, dynamic> UserMap = SearchData.UserMap;
  String? chatroomid = SearchData.roomid;

  final TextEditingController _search = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
    SearchData();
  }

  void setStatus(String status) async {
    await _firestore.collection('Users').doc(auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // online
      setStatus("Offline");
    } else {
      // offline
      setStatus("Online");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xff8c49f2),
            centerTitle: false,
            title: Text("CHITCHAT"),
            actions: <Widget>[
              IconButton(
                  icon: actionIcon,
                  onPressed: () {
                    showSearch(context: context, delegate: SearchData());
                  }),
              IconButton(
                  onPressed: () {
                    setState(() {
                      LogOutFunc(context);
                      Navigator.pop(context);
                      setStatus("Offline");
                    });
                  },
                  icon: Icon(Icons.logout))
            ]),
        body: StreamBuilder(
            stream: _firestore
                .collection("Users")
                .where('name', isNotEqualTo: auth.currentUser!.displayName)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator(
                  color: Color(0xff8c49f2),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot user = snapshot.data!.docs[index];
                      return ListTile(
                        leading: const Icon(Icons.account_box),
                        trailing: const Icon(Icons.chat),
                        title: Text(
                          user['name'],
                          style: TextStyle(fontSize: 19),
                        ),
                        subtitle:
                            Text(user['email'], style: TextStyle(fontSize: 14)),
                        onTap: () => {
                          chatroomid = SearchData.ChatId(
                              auth.currentUser!.displayName.toString(),
                              user['name'].toString()),
                          print(chatroomid),
                          setState(() {
                            UserMap = user.data() as Map<String, dynamic>;
                          }),
                          print(UserMap),
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                      chatRoomId: chatroomid!,
                                      UserMap: UserMap))),
                        },
                      );
                    });
              }
            }));
  }
}
