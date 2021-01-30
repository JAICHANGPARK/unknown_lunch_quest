import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/bulletin.dart';
import 'package:flutter_lunch_quest/src/model/contact.dart';
import 'dart:async';

import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:intl/intl.dart';

class BulletinDetailPage extends StatefulWidget {
  final Bulletin bulletin;
  final Database database;
  BulletinDetailPage(this.bulletin, this.database);

  @override
  _BulletinDetailPageState createState() => _BulletinDetailPageState();
}

class _BulletinDetailPageState extends State<BulletinDetailPage> {
  TextEditingController _textEditingController = TextEditingController();

  StreamSubscription _streamSubscription;

  List<Contact> items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamSubscription = widget.database.ref("bulletin").child(widget.bulletin.mainKey).child("comments").onValue.listen((e) {

      DataSnapshot datasnapshot = e.snapshot;
      if(items.isNotEmpty) items.clear();
      datasnapshot.forEach((value) {
        print(">>> value.key : ${value.key} , ${value.val()}");
        var data = value.val();
        print(data);
        items.add(Contact(datetime: data["datetime"], content: data["content"]));
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _textEditingController.dispose();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bulletin.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.bulletin.content),
                        Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(widget.bulletin.datetime),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              flex: 4,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "댓글: ${items.length}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _textEditingController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send_outlined),
                                onPressed: () async {
                                  print(widget.bulletin.mainKey);

                                  if(_textEditingController.text.length > 0){
                                    String dt = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
                                    await widget.database
                                        .ref("bulletin")
                                        .child(widget.bulletin.mainKey)
                                        .child("comments")
                                        .push()
                                        .set({"datetime": dt, "content": _textEditingController.text});
                                    _textEditingController.clear();
                                    setState(() {

                                    });
                                  }else{
                                    print("dfs");
                                  }

                                },
                              )),
                        )),
                    Expanded(
                        flex: 10,
                        child: items.length > 0 ? ListView.separated(
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text("익명"),
                                ),
                                title: Text(
                                  "익명의엔젤러",
                                  style: TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  items[index].content,
                                  style: TextStyle(fontSize: 16),
                                ),
                                trailing: Text(items[index].datetime),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                thickness: 1.5,
                              );
                            },
                            itemCount: items.length)
                      : Center(
                          child: Text("등록된 댓글이 없습니다."),
                        )
                      ,

                    ),
                  ],
                ),
              ),
              flex: 10,
            ),
          ],
        ),
      ),
    );
  }
}
