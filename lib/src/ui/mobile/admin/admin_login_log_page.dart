import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';

class AdminLoginLog {
  final DateTime datetime;
  final String ip;

  AdminLoginLog(this.datetime, this.ip);
}

class AdminLoginLogPage extends StatefulWidget {
  @override
  _AdminLoginLogPageState createState() => _AdminLoginLogPageState();
}

class _AdminLoginLogPageState extends State<AdminLoginLogPage> {
  List<AdminLoginLog> items = [];

  Future<void> fetchAdminLoginLog() async {
    QuerySnapshot querySnapshot =
        await FirebaseInstance.instance.fireStore.collection("login").doc("admin").collection("log").get();
    querySnapshot.docs.forEach((element) {
      var item = element.data();
      items.add(AdminLoginLog(item["datetime"], item["ip"]));
      // element.data().forEach((key, value) {
      //   print(key);
      //   print(value);
      //   if(value is DateTime){
      //     items.add(value,);
      //   }
      // });
    });
    // print(items);
    items.sort((a, b) => b.datetime.compareTo(a.datetime));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAdminLoginLog().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("로그인이력"),
      ),
      body: items.length > 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].datetime.toString()),
                    trailing: Text(items[index].ip),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 8,
                  );
                },
                itemCount: items.length,
              ),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text("정보 가져오는중..."),
                ],
              ),
            ),
    );
  }
}
