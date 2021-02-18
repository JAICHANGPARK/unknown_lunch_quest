import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/db/pref_api.dart';
import 'package:flutter_lunch_quest/src/model/user.dart' as mUser;
import 'package:flutter_lunch_quest/src/remote/api.dart';

class EnterUserListPage extends StatefulWidget {
  EnterUserListPage({Key key}) : super(key: key);

  @override
  _EnterUserListPageState createState() => _EnterUserListPageState();
}

class _EnterUserListPageState extends State<EnterUserListPage> {
  List<mUser.User> enterUserList = []; // 참가한 사용자 리스트를 담는 변수
  List<mUser.User> normalUserList = []; // 참가한 사용자 리스트를 담는 변수
  List<mUser.User> bentoUserList = []; // 참가한 사용자 리스트를 담는 변수


  Future fetchEnterUserList() async {
    if (enterUserList.length > 0) enterUserList.clear();
    if (normalUserList.length > 0) normalUserList.clear();
    if (bentoUserList.length > 0) bentoUserList.clear();
    String selectDate = await readSelectDate();
    DocumentSnapshot querySnapshot =
        await FirebaseInstance.instance.fireStore.collection("lunch").doc(selectDate.split(" ").first).get();

    querySnapshot.data()["users"].forEach((element) {
      String part = "";
      if (element.toString().split(",").length == 1) {
        part = "일반";
      } else {
        part = element.toString().split(",")[1];
      }
      String name = element.toString().split(",").first;
      String team = element.toString().split(",").length > 2 ? element.toString().split(",").last : "";
      enterUserList.add(mUser.User(name: name, team: team, part: part));
    });
    normalUserList = enterUserList.where((element) => element.part =="일반").toList();
    bentoUserList = enterUserList.where((element) => element.part =="도시락").toList();
    setState(() {});
  }

  Future refreshEnterUserList() async {
    if (enterUserList.length > 0) enterUserList.clear();
    setState(() {});
    String selectDate = await readSelectDate();
    DocumentSnapshot querySnapshot =
        await FirebaseInstance.instance.fireStore.collection("lunch").doc(selectDate.split(" ").first).get();

    querySnapshot.data()["users"].forEach((element) {
      String part = "";
      if (element.toString().split(",").length == 1) {
        part = "일반";
      } else {
        part = element.toString().split(",")[1];
      }
      String name = element.toString().split(",").first;
      String team = element.toString().split(",").length > 2 ? element.toString().split(",").last : "";
      enterUserList.add(mUser.User(name: name, team: team, part: part));
    });

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEnterUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("신청목록"),
      ),
      body: RefreshIndicator(
          onRefresh: refreshEnterUserList,
          child: enterUserList.length > 0
              ? Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(normalUserList[index].name),
                            trailing: Text(normalUserList[index].part),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 8,
                            color: Colors.grey,
                            endIndent: 8,
                            indent: 8,
                          );
                        },
                        itemCount: normalUserList.length),
                  ),
                  Expanded(
                    child: ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(bentoUserList[index].name),
                            trailing: Text(bentoUserList[index].part),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 8,
                            color: Colors.grey,
                            endIndent: 8,
                            indent: 8,
                          );
                        },
                        itemCount: bentoUserList.length),
                  ),
                ],
              )
              : Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
