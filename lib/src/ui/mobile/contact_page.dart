import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/contact.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Database database;
  StreamSubscription dataStreamSubscription;
  TextEditingController _textEditingController;

  List<Contact> contactList = [];

  @override
  void dispose() {
    // TODO: implement dispose
    dataStreamSubscription?.cancel();
    _textEditingController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController();
    database = FirebaseInstance.instance.database;
    dataStreamSubscription =  database.ref("contact").onValue.listen((e) {
      DataSnapshot datasnapshot = e.snapshot;
      if (contactList.isNotEmpty) contactList.clear();
      datasnapshot.forEach((e) {
        e.forEach((k){
          // print("${k.key} : ${k.val()}");
          contactList.add(Contact(content: k.val(), datetime: k.key));
        });
      });
      setState(() {
        contactList = contactList.reversed.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("문의하기"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24, top: 8),
        child: Column(
          children: [
            Expanded(
                child: contactList.length > 0
                    ? ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("익명"),
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(contactList[index].content),
                                          Text("작성시간: ${contactList[index].datetime}")
                                        ],
                                      ),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("확인")),
                                      ],
                                    );
                                  });
                            },
                            leading: CircleAvatar(
                              child: Text("익"),
                            ),
                            title: Text(contactList[index].datetime),
                            subtitle: Text(
                              contactList[index].content,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text("${timeago.format(DateTime.parse(contactList[index].datetime),
                            locale: "ko")}"),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 8,
                          );
                        },
                        itemCount: contactList.length)
                    : Center(
                        child: CircularProgressIndicator(),
                      )),
            SizedBox(
              height: 32,
            ),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async{
                      if (_textEditingController.text.length > 0) {
                        String dt = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                        ThenableReference childRef = database.ref("contact").push();
                        await childRef.set({dt : _textEditingController.text});
                        _textEditingController.clear();

                        ///
                      } else {
                        Fluttertoast.showToast(msg: "내용을 입력해주세요", webPosition: "center");
                      }
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
