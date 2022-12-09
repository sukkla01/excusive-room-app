import 'dart:convert';

import 'package:flutter/material.dart';
import '../api_provider.dart';
import '../config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int color_sub = config.color_sub;
  int color_active = config.color_active;

  //login
  TextEditingController ctrlLoginUsername = TextEditingController();
  TextEditingController ctrlLoginPassword = TextEditingController();
  bool isUsername = true;
  bool isLoginStatus = false;

  String msgAlert = '';
  String msgAlertUsername = '';

  ApiProvider apiProvider = ApiProvider();
  final _formKey = GlobalKey<FormState>();

  Future login() async {
    String loginUsername = ctrlLoginUsername.text;
    String loginPassword = ctrlLoginPassword.text;
    Map data = {'username': loginUsername, 'password': loginPassword};
    if (loginUsername == '' || loginPassword == '') {
      setState(() {
        isLoginStatus = true;
        msgAlert = 'username หรือ password ต้องไม่ว่าง';
      });

      // Toast.show(
      //   "username หรือ password ต้องไม่ว่าง",
      //   context,
      //   duration: 2,
      //   gravity: Toast.BOTTOM,
      //   backgroundColor: Colors.red,
      // );
    } else {
      print('ff');

      try {
        var res = await apiProvider.login(loginUsername, loginPassword);
        print(res.statusCode);
        if (res.statusCode == 200) {
          var jsonDecode = json.decode(res.body);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', jsonDecode['token']);
          // Map<String, dynamic> decodedToken =
          //     JwtDecoder.decode(jsonDecode['token']);
          // if (decodedToken['plat'] == 'N') {
          print('ddd');
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/main', (Route<dynamic> route) => false);
          // } else {
          //   setState(() {
          //     isLoginStatus = true;
          //     msgAlert = 'ชื่อผู้ใช้ถูกปิด';
          //   });
          // }
        } else if (res.statusCode == 401) {
          setState(() {
            isLoginStatus = true;
            msgAlert = 'ชื่อผู้ใช้งานหรือรหัสผ่านผิด';
          });
        }
      } catch (err) {
        print(err);
      }
    }

    print(data);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double viewInset = MediaQuery.of(context)
        .viewInsets
        .bottom; // we are using this to determine Keyboard is opened or not
    double defaultLoginSize = size.height - (size.height * 0.2);
    double defaultRegisterSize = size.height - (size.height * 0.1);

    return Scaffold(
        backgroundColor: Color(color_sub),
        body: Stack(
          children: [
            Positioned(
                top: 180,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white),
                )),
            // Positioned(
            //     top: 195,
            //     right: -80,
            //     child: Container(
            //       width: 110,
            //       height: 110,
            //       decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(50),
            //           color: Color(color_active)),
            //     )),
            Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(color_active)),
                )),
            Positioned(
                bottom: 100,
                left: 300,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Color(color_active)),
                )),
            Center(
              child: Container(
                height: 400,
                width: 500,
                // color: Colors.amberAccent,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withOpacity(0.85),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Container(
                          width: size.width,
                          // height: defaultLoginSize,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'จองห้องพิเศษ',
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                msgAlert,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 17),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFFE7B8B3).withAlpha(50),
                                ),
                                child: TextField(
                                  controller: ctrlLoginUsername,
                                  cursorColor: Color(0xFFE90000),
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                      icon: Icon(
                                        Icons.account_circle_outlined,
                                        color: Color(0xFFE90000),
                                      ),
                                      hintText: 'Username',
                                      hintStyle: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black.withOpacity(0.3)),
                                      border: InputBorder.none),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0xFFE7B8B3).withAlpha(50),
                                ),
                                child: TextField(
                                  controller: ctrlLoginPassword,
                                  cursorColor: Color(0xFFE90000),
                                  style: TextStyle(color: Colors.black),
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  decoration: InputDecoration(
                                      icon: Icon(
                                        Icons.lock,
                                        color: Color(0xFFE90000),
                                      ),
                                      hintText: 'password',
                                      hintStyle: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black.withOpacity(0.3)),
                                      border: InputBorder.none),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(30),
                                child: GestureDetector(
                                  onTap: () {
                                    login();
                                  },
                                  child: Container(
                                    width: size.width * 0.8,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Color(0xFFE90000)),
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'เข้าสู่ระบบ',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
