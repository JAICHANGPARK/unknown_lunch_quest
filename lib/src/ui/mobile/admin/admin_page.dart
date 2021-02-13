import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int totalTicket;

  Future<void> onSetTotalTicketCount(int value) async {
    QuerySnapshot querySnapshot = await FirebaseInstance.instance.fireStore.collection("ticket").get();
    int total = querySnapshot.docs.first.data()["count"];
    await querySnapshot.docs.first.ref.update(data: {"count": (total + value)});
  }

  Future<void> onSetTotalTicketFixCount(int value) async {
    QuerySnapshot querySnapshot = await FirebaseInstance.instance.fireStore.collection("ticket").get();
    await querySnapshot.docs.first.ref.update(data: {"count": value});
  }

  Future<void> onSetTicketUpdateLog(int value) async {
    CollectionReference documentReference = FirebaseInstance.instance.fireStore.collection("ticket").doc("log").collection("update");
    // int total = querySnapshot.docs.first.data()["count"];
    await documentReference.add(
    {
        DateTime.now().toString(): {"timestamp": DateTime.now().toString(), "ticket": value}
      },
    );
  }
  Future<void> onSetTicketChangeLog(int value) async {
    CollectionReference documentReference = FirebaseInstance.instance.fireStore.collection("ticket").doc("log").collection("change");
    // int total = querySnapshot.docs.first.data()["count"];
    await documentReference.add(
      {
        DateTime.now().toString(): {"timestamp": DateTime.now().toString(), "ticket": value}
      },
    );
  }

  Future<int> fetchTotalTicketCount() async {
    QuerySnapshot querySnapshot = await FirebaseInstance.instance.fireStore.collection("ticket").get();
    // print(querySnapshot.docs);
    // print(querySnapshot.docs.first.data()["count"]);
    return querySnapshot.docs.first.data()["count"];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTotalTicketCount().then((value) {
      setState(() {
        totalTicket = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "관리자",
          style: TextStyle(
            fontFamily: "NanumBarunpenR",
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("관리",style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
            ),
            ListTile(
              title: Text(
                "마감처리",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed("/admin/home/manage/room");
              },
              subtitle: Text("마감처리를 진행합니다.",style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),
            SizedBox(height: 24,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("식권장부",style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
            ),
            ListTile(
              title: Text(
                "장부확인",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              onTap: () {
                Navigator.of(context).pushNamed("/data/record");
              },

            ),
            Divider(),
            SizedBox(height: 24,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("식권관리",style: TextStyle(
                fontFamily: "NanumBarunpenR",
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),),
            ),

            ListTile(
              onTap: () {},
              title: Text(
                "현재 식권수",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              trailing: Text("${totalTicket.toString()}장"),
            ),
            Divider(),
            ListTile(
              onTap: () {
                TextEditingController tmp = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: Text(
                            "구매 수량 추가하기",
                            style: TextStyle(
                              fontFamily: "NanumBarunpenR",
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "식권을 추가 구매했을 때 사용해주세요.",
                                style: TextStyle(
                                  fontFamily: "NanumBarunpenR",
                                ),
                              ),
                              TextField(
                                controller: tmp,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("취소하기"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (tmp.text.length > 0) {
                                  int v = int.parse(tmp.text);
                                  await onSetTotalTicketCount(v);
                                  await onSetTicketUpdateLog(v);
                                  totalTicket = await fetchTotalTicketCount();
                                  Fluttertoast.showToast(msg: "처리 완료");
                                  setState(() {});

                                  Navigator.of(context).pop();
                                } else {
                                  Fluttertoast.showToast(msg: "추가할 식권수를 입력해주세요");
                                }
                              },
                              child: Text("추가하기"),
                            ),
                          ],
                        ));
              },
              title: Text(
                "식권 추가",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              subtitle: Text("식권을 구매했을때 사용",style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),
            ListTile(
              onTap: () {
                TextEditingController tmp = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) =>
                        AlertDialog(
                          title: Text(
                            "식권 수정하기",
                            style: TextStyle(
                              fontFamily: "NanumBarunpenR",
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "현재 식권을 수정할때 사용해주세요. (입력: 현재 잔여 총 식권 수량)",
                                style: TextStyle(
                                  fontFamily: "NanumBarunpenR",
                                ),
                              ),
                              TextField(
                                controller: tmp,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("취소하기"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (tmp.text.length > 0) {
                                  int v = int.parse(tmp.text);
                                  await onSetTotalTicketFixCount(v);
                                  await onSetTicketChangeLog(v);
                                  totalTicket = await fetchTotalTicketCount();
                                  Fluttertoast.showToast(msg: "처리 완료");
                                  setState(() {});

                                  Navigator.of(context).pop();
                                } else {
                                  Fluttertoast.showToast(msg: "수정할 식권수를 입력해주세요");
                                }
                              },
                              child: Text("수정하기"),
                            ),
                          ],
                        ));
              },
              title: Text(
                "식권 수정",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              subtitle: Text("현재 식권의 수량을 재수정할때 사용",style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("식권이력",style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed( "/admin/home/ticket/record/use");
              },
              title: Text(
                "사용 이력",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              subtitle: Text("요일별 식권 사용량을 확인합니다.",style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed( "/admin/home/ticket/record/buy");
              },
              title: Text(
                "구매 이력",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
              subtitle: Text("구매 및 추가된 이력을 확인합니다.",style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),

            SizedBox(height: 24,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("보안",style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed("/admin/home/pwd_change");
              },
              title: Text(
                "비밀번호 변경",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.of(context).pushNamed("/admin/home/login/record");

              },
              title: Text(
                "로그인 이력",
                style: TextStyle(
                  fontFamily: "NanumBarunpenR",
                ),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
