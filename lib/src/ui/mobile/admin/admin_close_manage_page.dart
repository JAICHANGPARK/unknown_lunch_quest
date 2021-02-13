import 'dart:async';

import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/record.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';

class AdminCloseManagePage extends StatefulWidget {
  @override
  _AdminCloseManagePageState createState() => _AdminCloseManagePageState();
}

class _AdminCloseManagePageState extends State<AdminCloseManagePage> {
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
              used: userList.length,
              leftTicket: items[i].doc.data()['ticket_left'],
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
                    used: userList.length,
                    leftTicket: items[i].doc.data()['ticket_left'],
                    isClosed: items[i].doc.data()['isClosed']));
          }
        }
      }
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
          used: userList.length,
          leftTicket: element.data()['ticket_left'],
          isClosed: element.data()['isClosed']));
    });
  }

  Future onSetRoomClose(String date) async {
    await firestore.collection("lunch").doc(date).update(
      data: {"isClosed": true},
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamLunchList();
  }

  int totalTicket = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("방마감관리"),
        centerTitle: true,
        actions: [],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            rows: records
                .map((e) => DataRow(cells: [
                      DataCell(Text(e.date)),
              DataCell(Text(e.users.length.toString())),
                      DataCell(e.isClosed ? Text("마감완료") : Text("미완료")),
                      DataCell(e.isClosed
                          ? Container()
                          : ElevatedButton(
                              onPressed: () async {
                                await showDialog(
                                    context: context,
                                    builder: (context) => WillPopScope(
                                      child: AlertDialog(
                                            title: Text("퀘스트종료"),
                                            content: Text(
                                              "마감하고 방을 닫을까요?\n한번 닫으면 다시 열수 없습니다. 주의해주세요",
                                              style: TextStyle(
                                                fontFamily: "NanumBarunpenR",
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () async {
                                                    await onSetRoomClose(e.date);
                                                    totalTicket = await fetchTotalTicketCount();
                                                    await updateTotalTicketCount(e.users.length);
                                                    await onUpdateUsedTicket(e.date, totalTicket);
                                                    await onAddUsedTicketLog(
                                                        date: e.date, left: totalTicket, used: e.users.length);
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("확인")),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("취소")),
                                            ],
                                          ),
                                    ));
                              },
                              child: Text("마감하기"),
                            )),
                    ]))
                .toList(),
            columns: [
              DataColumn(
                label: Text("날짜"),
              ),
              DataColumn(
                label: Text("사용수량"),
              ),
              DataColumn(
                label: Text("마감처리 여부"),
              ),
              DataColumn(
                label: Text("처리"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> fetchTotalTicketCount() async {
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    return querySnapshot.docs.first.data()["count"];
  }

  Future<void> updateTotalTicketCount(int v) async {
    int total = await fetchTotalTicketCount();
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    await querySnapshot.docs.first.ref.update(data: {"count": (total - v)});
  }

  Future onUpdateUsedTicket(String date, int value) async {
    await firestore.collection("lunch").doc(date).update(
      data: {"ticket_left": value},
    );
  }

  Future onAddUsedTicketLog({String date, int used, int left}) async {
    await firestore
        .collection("ticket")
        .doc("log")
        .collection("used")
        .add({"date": DateTime.parse(date), "left": left, "used": used});
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
