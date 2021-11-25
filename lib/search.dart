import 'dart:async';
import 'package:chitchat/chat_screen.dart';
import 'package:chitchat/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchData extends SearchDelegate {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore Firestore = FirebaseFirestore.instance;

  HomeScreen newstate = const HomeScreen();

  static Map<String, dynamic> UserMap = <String, dynamic>{};

  static String? roomid;

  // SearchData({required this.UserMap});

  CollectionReference reference =
      FirebaseFirestore.instance.collection('Users');

  String? bothUsers;

  static String ChatId(String? user1, String user2) {
    if (user1.hashCode <= user2.hashCode) {
      return "$user1-$user2";
    } else {
      return "$user2-$user1";
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context));
  }

  @override
  Widget buildResults(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return StreamBuilder<QuerySnapshot>(
          stream: Firestore.collection('Users').snapshots().asBroadcastStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            void OnSearchFunc() async {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .where('email', isEqualTo: query.toString().toLowerCase())
                  .where('email', isNotEqualTo: auth.currentUser!.email)
                  .get()
                  .then((value) {
                setState(() {
                  UserMap = value.docs[0].data();
                });
              });
              print(UserMap);
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.data!.docs
                  .where((element) => element['email']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .isEmpty) {
                return const Center(
                  child: Text(
                    "Opps ! No result found !",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Times new roman",
                        color: Colors.black),
                  ),
                );
              } else {
                try {
                  OnSearchFunc.call();
                } catch (e) {
                  print(e);
                }
                return ListView(children: [
                  ...snapshot.data!.docs
                      .where((element) => element['email']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .where((element) =>
                          element['email'] != auth.currentUser!.email)
                      .map((e) {
                    return ListTile(
                      onTap: () {
                        setState(() {
                          OnSearchFunc();
                        });
                        roomid = ChatId(
                            (auth.currentUser!.displayName).toString(),
                            UserMap['name'].toString());
                        List<String> bothUsers = <String>[
                          auth.currentUser!.displayName.toString(),
                          UserMap['name'].toString(),
                        ];

                        print(roomid);
                        print(bothUsers);
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (_) => ChatScreen(
                                chatRoomId: roomid!, UserMap: UserMap)));
                      },
                      leading: Icon(Icons.account_box),
                      trailing: IconButton(
                          onPressed: () {
                            final String roomid = ChatId(
                                (auth.currentUser!.displayName).toString(),
                                UserMap['name'].toString());
                            print(roomid);
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                        chatRoomId: roomid,
                                        UserMap: UserMap['name'])));
                          },
                          icon: Icon(Icons.chat)),
                      title: Text(e['email'], style: TextStyle(fontSize: 19)),
                      subtitle: Text(e['name'], style: TextStyle(fontSize: 14)),
                    );
                  })
                ]);
              }
            }
          });
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.collection('Users')
            .where('name', isNotEqualTo: auth.currentUser!.displayName)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return Text('Loading...');

          final results = snapshot.data!.docs
              .where((a) => a['email'].contains(query))
              .where((element) => element['email'] != query)
              .toList();

          final String roomid = ChatId(
              (auth.currentUser!.displayName).toString(),
              UserMap['name'].toString());

          return ListView(
            children: snapshot.data!.docs.map((e) {
              return ListTile(
                onTap: () => [
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (_) => ChatScreen(
                          chatRoomId: roomid, UserMap: UserMap['name'])))
                ],
                leading: Icon(Icons.account_box),
                trailing: Icon(Icons.chat),
                title: Text(e['email'], style: TextStyle(fontSize: 19)),
                subtitle: Text(e['name'], style: TextStyle(fontSize: 14)),
              );
            }).toList(),
          );
        });
  }
}
