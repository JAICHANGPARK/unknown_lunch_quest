import 'dart:async';

import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/record.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/ui/wide_screen/export/web_record_print_page.dart';

class WideHomePage extends StatefulWidget {
  @override
  _WideHomePageState createState() => _WideHomePageState();
}

class _WideHomePageState extends State<WideHomePage> {
  Firestore firestore = FirebaseInstance.instance.store;

  List<Record> records = [];
  StreamSubscription streamSubscription;

  Future streamLunchList() {
    CollectionReference ref = firestore.collection('lunch');

    streamSubscription = ref.onSnapshot.listen((querySnapshot) {
      // print("record Clear");
      // if (records.isNotEmpty) records.clear();
      querySnapshot.docChanges().forEach((change) {
        List<String> userList = List<String>.from(change.doc.data()['users']);
        if (['added'].contains(change.type)) {
          // print("added");
          records.add(Record(
              date: change.doc.id,
              users: userList.map((e) => e.split(",").first).toList(),
              total: userList.length,
              used: userList.length,
              leftTicket: change.doc.data()['ticket_left'],
              isClosed: change.doc.data()['isClosed']));
        } else if (['modified'].contains(change.type)) {
          // print("modified");
          // print(change.doc.id);

          int idx = records.indexWhere((element) => element.date == change.doc.id);
          // print(idx);
          if (idx != -1) {
            records.removeAt(idx);
            records.insert(
                idx,
                Record(
                    date: change.doc.id,
                    users: userList.map((e) => e.split(",").first).toList(),
                    total: userList.length,
                    used: userList.length,
                    leftTicket: change.doc.data()['ticket_left'],
                    isClosed: change.doc.data()['isClosed']));
          }

          // print(records.indexWhere((element) => element.date == change.doc.id));
          // records[records.indexWhere((element) => element.date == change.doc.id)] = Record(
          //     date: change.doc.id, users: userList, total: userList.length, isClosed: change.doc.data()['isClosed']);
        }
      });
      setState(() {
        // records = records.reversed.toList();
      });
    });
  }

  Future fetchLunchList() async {
    QuerySnapshot querySnapshot = await firestore.collection("lunch").get();

    querySnapshot.forEach((element) {
      // print("${element.id}:${element.data()}");
      List<String> userList = List<String>.from(element.data()['users']);
      records.add(Record(
          date: element.id,
          users: userList.map((e) => e.split(",").first).toList(),
          total: userList.length,
          used: userList.length,
          leftTicket: element.data()['ticket_left'],
          isClosed: element.data()['isClosed']));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamLunchList();
    // fetchLunchList().then((value) {
    //   setState(() {
    //
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? "assets/img/logo_org.png"
                    : "assets/img/logo_gray.png",
                width: MediaQuery.of(context).size.width / 2.3,
              ),
              Row(
                children: [
                  Text("화면을 작게하면 모바일 처럼 사용이 가능합니다."),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WebRecordPrintPagePage(
                                  recordItems: [...records],
                                )));
                      },
                      child: Text("프린트하기")),
                ],
              ),
              DataTable(
                rows: records
                    .map((e) => DataRow(cells: [
                          DataCell(Text(e.date)),
                          DataCell(Text(e.total.toString())),
                          DataCell(Text("${e.leftTicket ?? "-"}")),
                          DataCell(Text("${e.users.toString()}")),
                          DataCell(e.isClosed ? Text("마감완료") : Text("미완료")),
                        ]))
                    .toList(),
                columns: [
                  DataColumn(
                    label: Text("날짜"),
                  ),
                  DataColumn(
                    label: Text("인원수"),
                  ),
                  DataColumn(
                    label: Text("잔여수량"),
                  ),
                  DataColumn(
                    label: Text("인원"),
                  ),
                  DataColumn(
                    label: Text("마감처리 여부"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (streamSubscription != null) {
      streamSubscription.cancel();
    }

    super.dispose();
  }
}
