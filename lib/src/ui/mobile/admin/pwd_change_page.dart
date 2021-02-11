import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PwdChangePage extends StatefulWidget {
  @override
  _PwdChangePageState createState() => _PwdChangePageState();
}

class _PwdChangePageState extends State<PwdChangePage> {
  TextEditingController pwdTextEditingController = TextEditingController();
  TextEditingController pwdChangeTextEditingController = TextEditingController();
  TextEditingController pwdChangeTextEditingController2 = TextEditingController();
  bool isCorrect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "비밀번호 변경",
          style: TextStyle(
            fontFamily: "NanumBarunpenR",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "기존 비밀번호",
              style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                controller: pwdTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            ButtonBar(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      if (pwdTextEditingController.text.length > 0) {
                        var bytes = utf8.encode(pwdTextEditingController.text); // data being hashed
                        var digest = sha1.convert(bytes);
                        // print("Digest as bytes: ${digest.bytes}");
                        // print("Digest as hex string: $digest");
                        DocumentSnapshot result =
                            await FirebaseInstance.instance.fireStore.collection('login').doc('admin').get();
                        // print(result.data());
                        // print(result.data()["info"]["pwd"]);
                        if (digest.toString() == result.data()["info"]["pwd"]) {
                          setState(() {
                            isCorrect = true;
                          });
                          Fluttertoast.showToast(msg: "확인성공", webPosition: "center");
                        } else {
                          pwdTextEditingController.clear();
                          Fluttertoast.showToast(msg: "확인실패", webPosition: "center");
                        }
                      } else {
                        Fluttertoast.showToast(msg: "공백일수 없습니다.", webPosition: "center");
                      }
                    },
                    child: Text("확인하기")),
              ],
            ),
            isCorrect
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "비밀번호 변경",
                        style: TextStyle(
                          fontFamily: "NanumBarunpenR",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextField(
                          controller: pwdChangeTextEditingController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                      Text(
                        "비밀번호 변경(다시확인)",
                        style: TextStyle(
                          fontFamily: "NanumBarunpenR",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextField(
                          controller: pwdChangeTextEditingController2,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      ),
                      ButtonBar(
                        children: [
                          ElevatedButton(
                              onPressed: () async {
                                if (pwdChangeTextEditingController2.text.length > 0 && pwdChangeTextEditingController.text.length > 0) {
                                  
                                  if(pwdChangeTextEditingController2.text  == pwdChangeTextEditingController.text){
                                    var bytes = utf8.encode(pwdChangeTextEditingController.text); // data being hashed
                                    var digest = sha1.convert(bytes);
                                    // print("Digest as bytes: ${digest.bytes}");
                                    // print("Digest as hex string: $digest");
                                    DocumentSnapshot result =
                                    await FirebaseInstance.instance.fireStore.collection('login').doc('admin').update(
                                      data: {
                                        "info":{"pwd":digest.toString(), "pwdRad": pwdChangeTextEditingController.text,
                                        "update":DateTime.now()}
                                      }
                                    );
                                    Fluttertoast.showToast(msg: "비밀번호 변경완료", webPosition: "center");
                                    Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false);
                                  }

                                  // print(result.data());
                                  // print(result.data()["info"]["pwd"]);
                                  
                                } else {
                                  Fluttertoast.showToast(msg: "공백일수 없습니다.", webPosition: "center");
                                }
                              },
                              child: Text("변경하기")),
                        ],
                      ),
                    ],
                  )
                : Container(),


          ],
        ),
      ),
    );
  }
}
