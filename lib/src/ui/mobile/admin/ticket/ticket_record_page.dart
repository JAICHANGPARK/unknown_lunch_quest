import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/ticket_record.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';

class TicketRecordPage extends StatefulWidget {
  @override
  _TicketRecordPageState createState() => _TicketRecordPageState();
}

class _TicketRecordPageState extends State<TicketRecordPage> {
  List<TicketRecord> items = [];

  Future<void> fetchTicketLog() async {
    QuerySnapshot querySnapshot =
        await FirebaseInstance.instance.fireStore.collection("ticket").doc("log").collection("update").get();
    querySnapshot.docs.forEach((element) {
      element.data().forEach((key, value) {
        // print(key);
        // print(value);
        items.add(TicketRecord(ticket: value["ticket"].toString(), datetime: value["timestamp"].toString()));
      });
    });
    // print(items);
    items.sort((a, b) => DateTime.parse(b.datetime).compareTo(DateTime.parse(a.datetime)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTicketLog().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("구매 및 추가 이력",style: TextStyle(
          fontFamily: "NanumBarunpenR",
        ),),
      ),
      body: items.length > 0
          ? ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].datetime),
                  trailing: Text("${items[index].ticket}장"),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 8,
                );
              },
              itemCount: items.length,
            )
          : Center(
              child: Column(
                children: [
                  Text("가져오는중"),
                  CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }
}
