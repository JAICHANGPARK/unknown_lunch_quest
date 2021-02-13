import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/remote/ip_ping.dart';
import 'package:flutter_lunch_quest/src/utils/cut_corners_border.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController pwdTextEditController = TextEditingController();
  int tryCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인" ,style: TextStyle(
          fontFamily: "NanumBarunpenR",
        ),),
        centerTitle: true,
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event){
          // print(event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(
                "assets/img/pixeltrue-plan-1.png",
                width: MediaQuery.of(context).size.width / 1.5,
              ),
              SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    onFieldSubmitted: (s)async{
                      if (formKey.currentState.validate()) {
                        if (s.length > 0) {
                          var bytes = utf8.encode(s); // data being hashed
                          var digest = sha1.convert(bytes);
                          // print("Digest as bytes: ${digest.bytes}");
                          // print("Digest as hex string: $digest");
                          DocumentSnapshot result =
                              await FirebaseInstance.instance.fireStore.collection('login').doc('admin').get();
                          // print(result.data());
                          // print(result.data()["info"]["pwd"]);
                          if (digest.toString() == result.data()["info"]["pwd"]) {
                          String ip = await   getIP();
                            await FirebaseInstance.instance.fireStore.collection('login').doc('admin').collection('log').add(
                                {"datetime": DateTime.now(), "ip":ip});
                            Fluttertoast.showToast(msg: "로그인성공", webPosition: "center");
                            Navigator.of(context).pushReplacementNamed("/admin/home");
                          } else {
                            tryCount++;
                            pwdTextEditController.clear();
                            Fluttertoast.showToast(msg: "로그인실패", webPosition: "center");
                            if(tryCount > 4){
                              showDialog(context: context, builder: (context) => AlertDialog(
                                content: Text("비밀번호가 기억이 나지 않으신가요?\n비밀번호를 찾고싶다면\n박제창(jaichang@angel-robotics.com)에게 문의하세요"),
                              ));
                              tryCount = 0;
                            }

                          }
                          formKey.currentState.save();
                        }
                      }
                    },
                    controller: pwdTextEditController,
                    decoration: InputDecoration(
                      border: CutCornersBorder(),
                      labelText: '비밀번호',
                      labelStyle: TextStyle(),
                    ),
                    obscureText: true,
                    minLines: 1,
                    maxLines: 1,
                  ),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: Text('취소'),
                    onPressed: () {
                      pwdTextEditController.clear();
                    },
                  ),
                  RaisedButton(
                    child: Text('로그인' ,style: TextStyle(
                      fontFamily: "NanumBarunpenR",
                    ),),
                    elevation: 8.0,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState.validate()) {
                        if (pwdTextEditController.text.length > 0) {
                          var bytes = utf8.encode(pwdTextEditController.text); // data being hashed
                          var digest = sha1.convert(bytes);
                          // print("Digest as bytes: ${digest.bytes}");
                          // print("Digest as hex string: $digest");
                          DocumentSnapshot result =
                              await FirebaseInstance.instance.fireStore.collection('login').doc('admin').get();
                          // print(result.data());
                          // print(result.data()["info"]["pwd"]);
                          if (digest.toString() == result.data()["info"]["pwd"]) {
                            String ip = await   getIP();
                            await FirebaseInstance.instance.fireStore.collection('login').doc('admin').collection('log').add(
                                {"datetime": DateTime.now(), "ip":ip});
                            Fluttertoast.showToast(msg: "로그인성공", webPosition: "center");
                            Navigator.of(context).pushReplacementNamed("/admin/home");

                          } else {
                            tryCount++;
                            pwdTextEditController.clear();
                            if(tryCount > 4){
                              showDialog(context: context, builder: (context) => AlertDialog(
                                content: Text("비밀번호가 기억이 나지 않으신가요?\n비밀번호를 찾고싶다면\n박제창(jaichang@angel-robotics.com)에게 문의하세요"),
                              ));
                              tryCount = 0;
                            }
                            Fluttertoast.showToast(msg: "로그인실패", webPosition: "center");
                          }
                          formKey.currentState.save();
                        }
                      }
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


}
