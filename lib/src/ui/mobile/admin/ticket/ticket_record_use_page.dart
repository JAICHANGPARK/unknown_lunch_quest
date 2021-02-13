import 'package:firebase/firebase.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/ticket_record.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';

class TicketUseRecordPage extends StatefulWidget {
  @override
  _TicketUseRecordPageState createState() => _TicketUseRecordPageState();
}

class _TicketUseRecordPageState extends State<TicketUseRecordPage> {
  List<TicketUseRecord> items = [];

  Future<void> fetchTicketLog() async {
    QuerySnapshot querySnapshot =
        await FirebaseInstance.instance.fireStore.collection("ticket").doc("log").collection("used").get();
    querySnapshot.docs.forEach((element) {
      // print(element.data());
      var item = element.data();
      items.add(TicketUseRecord(date: item["date"], left: item["left"], used: item["used"]));
      // element.data().forEach((key, value) {
      //   print(key);
      //   print(value);
      //   if (key == "date") {
      //     print("true");
      //   }
      // });
    });
    items.sort((a, b) => a.date.compareTo(b.date));
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
        title: Text(
          "사용이력",
          style: TextStyle(
            fontFamily: "NanumBarunpenR",
          ),
        ),
      ),
      body: items.length > 0
          ? ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(items[index].date.toString().split(" ").first),
                  trailing: Text("사용: ${items[index].used} 잔여: ${items[index].left}"),
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
