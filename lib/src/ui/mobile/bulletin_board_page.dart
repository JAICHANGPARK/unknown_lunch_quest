import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/bulletin.dart';
import 'package:flutter_lunch_quest/src/model/contact.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'bulletin_detail_page.dart';

class BulletinBoardPage extends StatefulWidget {
  @override
  _BulletinBoardPageState createState() => _BulletinBoardPageState();
}

class _BulletinBoardPageState extends State<BulletinBoardPage> {
  StreamSubscription _streamSubscription;
  Database database;
  List<Bulletin> items = [];
  PanelController _pc = PanelController();
  TextEditingController _titleTextEditingController = TextEditingController();
  TextEditingController _contentTextEditingController = TextEditingController();

  List<Map<String, Map<String, String>>> comments = [];

  @override
  void dispose() {
    // TODO: implement dispose
    if(_streamSubscription != null){
      _streamSubscription?.cancel();
    }

    _titleTextEditingController?.dispose();
    _contentTextEditingController?.dispose();
    _pc.close();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    database = FirebaseInstance.instance.database;
    _streamSubscription = database.ref("bulletin").limitToLast(20).onValue.listen((e) {
      DataSnapshot datasnapshot = e.snapshot;
      if (items.isNotEmpty) items.clear();
      datasnapshot.forEach((value) {
        // print(">>> e.key: ${value.key}");

        String k = value.key;
        String title = "";
        String content = "";
        String dt = "";
        int childCount = 0;

        value.forEach((k) {
          // print(">>> ${k.key} : ${k.val()}");
          if (k.key == "title") {
            title = k.val();
          }
          if (k.key == "content") {
            content = k.val();
          }
          if (k.key == "datetime") {
            dt = k.val();
          }
          if (k.key == "comments") {
            // print(k.numChildren());
            childCount = k.numChildren();
          }

          // items.add(Bulletin(content: k.val(), datetime: k.key));
        });
        // print("e.child(e.key).child(comments).key: ${value.child(value.key).child("comments").key}");
        // print(">>>e.child(e.key).child(comments).numChildren() : ${value.child(value.key).numChildren()}");
        // childCount = value.child(value.key).child("comments").numChildren();
        items.add(Bulletin(title: title, mainKey: k, content: content, datetime: dt, commentCount: childCount));
      });
      setState(() {
        items = items.reversed.toList();
      });
    });
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("게시판"),
      ),
      body: SlidingUpPanel(
        borderRadius: radius,
        controller: _pc,
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height / 1.6,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8,8,8,36),
          child: Column(
            children: [
              // ElevatedButton(
              //   onPressed: () {
              //     database
              //         .ref("bulletin")
              //         .child(items[1].mainKey.toString())
              //         .child("comments")
              //         .push()
              //         .set({"datetime": "test", "content": "asdasd"});
              //   },
              //   child: Text("댓글 생성"),
              // ),
              Expanded(
                  child: items.length > 0
                      ? ListView.separated(
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                _streamSubscription.pause();
                                await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => BulletinDetailPage(items[index], database)));
                                _streamSubscription.resume();
                              },
                              leading: CircleAvatar(
                                child: Text("익명"),
                              ),
                              trailing: Text("${timeago.format(DateTime.parse(items[index].datetime),
                                  locale: "ko")}", style: TextStyle(fontSize: 12),),
                              title: Text("${items[index].title} [${items[index].commentCount}]"),
                              subtitle: Text(
                                "${items[index].content}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 8,
                            );
                          },
                          itemCount: items.length)
                      : Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
        panel: Column(
          children: [
            SizedBox(
              height: 24,
            ),
            Container(
              height: 6,
              width: 36,
              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "제목",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextField(
                    controller: _titleTextEditingController,
                    maxLines: 1,
                    maxLength: 50,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        color: Colors.black,
                      )),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    "내용",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(
                    child: TextField(
                      maxLength: 150,
                      controller: _contentTextEditingController,
                      onChanged: (v) {
                        setState(() {});
                      },
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          // width: 0.0 produces a thin "hairline" border
                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black
                          )
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 40),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  ButtonBar(
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            if (_titleTextEditingController.text.length > 0 &&
                                _contentTextEditingController.text.length > 0) {
                              String dt = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                              ThenableReference childRef = database.ref("bulletin").push();
                              await childRef.set({
                                "title": _titleTextEditingController.text,
                                "content": _contentTextEditingController.text,
                                "datetime": dt
                              });
                            } else {
                              Fluttertoast.showToast(msg: "제목과 내용을 모두 입력해주세요", webPosition: "center");
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "등록",
                              style: TextStyle(fontSize: 18),
                            ),
                          ))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: "작성하기",
        onPressed: () async {
          _pc.open();
          // String dt = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
          // ThenableReference childRef = database.ref("bulletin").push();
          // await childRef.set({"title": "커피하실분2", "content": "testing", "datetime": dt});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
