import 'package:chitchat/create_account.dart';
import 'package:chitchat/functions.dart';
import 'package:chitchat/home_screen.dart';
import 'package:chitchat/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: isLoading
            ? Center(
                child: Container(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: CircularProgressIndicator(),
                ),
              )
            : SingleChildScrollView(
                child: Column(children: <Widget>[
                SizedBox(height: size.height / 25),
                Container(
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.topLeft,
                    child: const Text("HEY WELCOME!",
                        style: TextStyle(
                            fontFamily: "Times new roman",
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Color(0xff8c49f2)))),
                const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("LET'S CHITCHAT !",
                        style: TextStyle(
                            fontFamily: "Times new roman",
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xff8c49f2)))),
                SizedBox(height: size.height / 10),
                Container(
                    alignment: Alignment.center,
                    width: size.width,
                    child:
                        Field(size, "Enter Email", Icons.email, _email, false)),
                Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      alignment: Alignment.center,
                      width: size.width,
                      child: Field(
                          size, "Enter Password", Icons.lock, _password, true),
                    )),
                SizedBox(
                  height: size.height / 10,
                ),
                CustomButton(size),
                SizedBox(
                  height: size.height / 10,
                ),
                GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const CreateAccount())),
                    child: const Text(
                      "Create Account Here",
                      style: TextStyle(
                          color: Color(0xff8c49f2),
                          fontSize: 13.0,
                          fontFamily: "Times new roman"),
                    ))
              ])));
  }

  Widget CustomButton(Size size) {
    return GestureDetector(
        onTap: () {
          if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
            setState(() {
              isLoading = true;
            });

            LoginFunc(_email.text, _password.text).then((user) {
              if (user != null) {
                print("Login Sucessfull");
                setState(() {
                  isLoading = false;
                });
                ToastMessage("Login successfull");
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              } else {
                print("Login Failed");
                setState(() {
                  isLoading = false;
                });
                ToastMessage("Field Should not be empty");
              }
            });
          } else {
            ToastMessage("Please fill correctly");
            print("Please fill form correctly");
          }
        },
        child: Container(
            height: size.height / 14,
            width: size.width / 1.3,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xff8c49f2)),
            child: const Text(
              "LOGIN",
              style: TextStyle(
                  fontFamily: "times new roman",
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            )));
  }

  Widget Field(Size size, String hint, IconData icon,
      TextEditingController cont, bool password) {
    return Container(
        alignment: Alignment.center,
        height: size.height / 15,
        width: size.width / 1.3,
        child: TextField(
          cursorColor: Color(0xff8c49f2),
          obscureText: password,
          controller: cont,
          decoration: InputDecoration(
              focusColor: Color(0xff8c49f2),
              prefixIcon: Icon(icon),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              )),
        ));
  }

  void ToastMessage(String message) => Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0);
}
