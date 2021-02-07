import 'dart:async';

import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/record.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';

import 'mobile_record_print_page.dart';

class MobileRecordPage extends StatefulWidget {
  @override
  _MobileRecordPageState createState() => _MobileRecordPageState();
}

class _MobileRecordPageState extends State<MobileRecordPage> {
  Firestore firestore = FirebaseInstance.instance.store;

  List<Record> records = [];
  StreamSubscription streamSubscription;

  void streamLunchList() {
    CollectionReference ref = firestore.collection('lunch');

    streamSubscription = ref.onSnapshot.listen((querySnapshot) {
      // print("record Clear");
      // if (records.isNotEmpty) records.clear();
      List<DocumentChange> items = querySnapshot.docChanges();
      for (int i = 0; i < items.length; i++) {
        List<String> userList = List<String>.from(items[i].doc.data()['users']);
        if (['added'].contains(items[i].type)) {
          // print("added");
          records.add(Record(
              date: items[i].doc.id,
              users: userList.map((e) => e.split(",").first).toList(),
              total: userList.length,
              isClosed: items[i].doc.data()['isClosed']));
        } else if (['modified'].contains(items[i].type)) {
          // print("modified");
          // print(items[i].doc.id);

          int idx = records.indexWhere((element) => element.date == items[i].doc.id);
          // print(idx);
          if (idx != -1) {
            records.removeAt(idx);
            records.insert(
                idx,
                Record(
                    date: items[i].doc.id,
                    users: userList.map((e) => e.split(",").first).toList(),
                    total: userList.length,
                    isClosed: items[i].doc.data()['isClosed']));
          }
        }
      }
      // querySnapshot.docChanges().forEach((change) {
      //   List<String> userList = List<String>.from(change.doc.data()['users']);
      //   if (['added'].contains(change.type)) {
      //     print("added");
      //     records.add(Record(
      //         date: change.doc.id,
      //         users: userList.map((e) => e.split(",").first).toList(),
      //         total: userList.length,
      //         isClosed: change.doc.data()['isClosed']));
      //   } else if (['modified'].contains(change.type)) {
      //     print("modified");
      //     print(change.doc.id);
      //
      //     int idx = records.indexWhere((element) => element.date == change.doc.id);
      //     print(idx);
      //     if (idx != -1) {
      //       records.removeAt(idx);
      //       records.insert(
      //           idx,
      //           Record(
      //               date: change.doc.id,
      //               users: userList.map((e) => e.split(",").first).toList(),
      //               total: userList.length,
      //               isClosed: change.doc.data()['isClosed']));
      //     }
      //
      //     // print(records.indexWhere((element) => element.date == change.doc.id));
      //     // records[records.indexWhere((element) => element.date == change.doc.id)] = Record(
      //     //     date: change.doc.id, users: userList, total: userList.length, isClosed: change.doc.data()['isClosed']);
      //   }
      // });

      setState(() {});
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
          isClosed: element.data()['isClosed']));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamLunchList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("식권장부"),
        actions: [
          IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => MobileRecordPrintPagePage(
                          recordItems: [...records],
                        )));
              })
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            rows: records
                .map((e) => DataRow(cells: [
                      DataCell(Text(e.date)),
                      DataCell(Text(e.total.toString())),
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
                label: Text("인원"),
              ),
              DataColumn(
                label: Text("마감처리 여부"),
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
