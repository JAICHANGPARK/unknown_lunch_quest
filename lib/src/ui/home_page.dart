import 'dart:async';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:flutter_lunch_quest/src/model/user.dart' as mUser;
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/utils/character_style.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:intl/intl.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

import 'about_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  StreamSubscription<QuerySnapshot> _streamSubscription;
  Firestore firestore = FirebaseInstance.instance.store;
  FancyDrawerController _controller;

  bool isOpen = false;
  bool existRoom = false;
  bool isPlaying = false;

  List<mUser.User> userList = [];
  List<mUser.User> enterUserList = [];

  String currentDate = DateTime.now().toString().split(" ").first;
  int totalTicket;

  Future refreshEnterUserList() async {
    DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
    querySnapshot.data()["users"].forEach((element) {
      String name = element.toString();
      enterUserList.add(mUser.User(name: name, team: ""));
    });

    setState(() {});
  }

  Future checkExistRoom(String date) async {
    if (enterUserList.length > 0) enterUserList.clear();
    DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(date).get();
    if (querySnapshot == null || !querySnapshot.exists) {
      existRoom = false;
    } else {
      existRoom = true;
      // print("querySnapshot.data() : ${querySnapshot.data()}");
      querySnapshot.data()["users"].forEach((element) {
        String name = element.toString();
        // print(element);
        enterUserList.add(mUser.User(name: name, team: ""));
      });
    }
  }

  Future<int> fetchTotalTicketCount() async {
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    // print(querySnapshot.docs.first.data()["count"]);
    return querySnapshot.docs.first.data()["count"];
  }

  @override
  void initState() {
    super.initState();
    print(">>> currentDate: $currentDate");
    checkExistRoom(currentDate).then((value) {
      setState(() {});
    });
    fetchTotalTicketCount().then((value) {
      setState(() {
        totalTicket = value;
      });
    });
    _controller = FancyDrawerController(vsync: this, duration: Duration(milliseconds: 150))
      ..addListener(() {
        // print(_controller.state);
        if (_controller.state == DrawerState.closing) {
          isPlaying = false;
        }
        setState(() {}); // Must call setState
      }); // This chunk of code is important

    //생성된 방이 있는지 확인

    // fetchAllUsers().then((value) {
    //   print(userList);
    //   setState(() {
    //     userList = value;
    //   });
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamSubscription?.cancel();
    _controller.dispose(); // Dispose c
    super.dispose();
  }

  List<bool> _isChecked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyDrawerWrapper(
        backgroundColor: Colors.white,
        child: Scaffold(
          key: _drawerKey,
          endDrawerEnableOpenDragGesture: false,
          drawer: Drawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        iconSize: 32,
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          if (!isPlaying) {
                            _controller.open();
                          } else {
                            _controller.close();
                          }
                          isPlaying = !isPlaying;
                        },
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Image.asset(
                        Theme.of(context).brightness == Brightness.light
                            ? "assets/img/logo_org.png"
                            : "assets/img/logo_gray.png",
                        width: MediaQuery.of(context).size.width / 2.3,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlutterDatePickerTimeline(
                          startDate: DateTime.now().add(Duration(days: -30)),
                          endDate: DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          onSelectedDateChange: (DateTime dateTime) async {
                            print(dateTime);
                            currentDate = DateFormat("yyyy-MM-dd").format(dateTime);
                            await checkExistRoom(currentDate);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Text(
                                    "현재시각",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  DigitalClock(
                                    areaDecoration: BoxDecoration(color: Colors.transparent),
                                    areaAligment: AlignmentDirectional.centerEnd,
                                    hourMinuteDigitDecoration: BoxDecoration(color: Colors.transparent),
                                    hourMinuteDigitTextStyle: TextStyle(fontSize: 16),
                                    secondDigitTextStyle: TextStyle(fontSize: 14),
                                  )
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: totalTicket != null
                                ? Row(
                                    children: [
                                      Text(
                                        "총 식권수",
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),
                                      Text(
                                        "$totalTicket 장",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.6,
                    width: MediaQuery.of(context).size.width,
                    child: existRoom
                        ? Card(
                            child: enterUserList.length > 0
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "총 인원수",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                "${enterUserList.length}명",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        height: 6,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "참가인원목록",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons.refresh),
                                                  onPressed: () async {
                                                    setState(() {
                                                      enterUserList.clear();
                                                    });
                                                    await refreshEnterUserList();
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: ListView.separated(
                                            separatorBuilder: (context, index) {
                                              return Divider(
                                                height: 10,
                                              );
                                            },
                                            itemCount: enterUserList.length,
                                            itemBuilder: (context, index) {
                                              return Slidable(
                                                actionPane: SlidableScrollActionPane(),
                                                child: ListTile(
                                                  title: Text(enterUserList[index].name),
                                                  // subtitle: Text(userList[index].team),
                                                ),
                                                secondaryActions: <Widget>[
                                                  IconSlideAction(
                                                      caption: 'Delete',
                                                      color: Colors.red,
                                                      icon: Icons.delete,
                                                      onTap: () async {
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text("경고"),
                                                                content:
                                                                    Text("${enterUserList[index].name} 님을 방에서 제거할까요?"),
                                                                actions: [
                                                                  ElevatedButton(
                                                                      onPressed: () {
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text("취소")),
                                                                  ElevatedButton(
                                                                      onPressed: () async {
                                                                        List<mUser.User> copyList = enterUserList;
                                                                        copyList.removeWhere((element) =>
                                                                            element.name == enterUserList[index].name);

                                                                        await firestore
                                                                            .collection("lunch")
                                                                            .doc(currentDate)
                                                                            .update(data: {
                                                                          "users": copyList.map((e) => e.name).toList()
                                                                        });

                                                                        setState(() {
                                                                          enterUserList.clear();
                                                                        });
                                                                        await refreshEnterUserList();
                                                                        Navigator.of(context).pop();
                                                                      },
                                                                      child: Text("네")),
                                                                ],
                                                              );
                                                            });
                                                      }),
                                                ],
                                              );
                                            }),
                                      ),
                                    ],
                                  )
                                : buildLoadingWidget("참가 대기중"))
                        : Card(
                            child: Stack(
                              children: [
                                Positioned(left: 0, right: 0, bottom: 0, top: 0, child: buildLoadingWidget("생성된 방 없음")),
                                Positioned(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  top: 0,
                                ),
                              ],
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 12.0,
            child: Container(
              height: 84,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 64, left: 16, top: 8, bottom: 8),
                    child: OutlinedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "마감",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      onPressed: existRoom ? () {} : null,
                    ),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 64, right: 16),
                    child: MaterialButton(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text("참가신청", style: TextStyle(color: Colors.white, fontSize: 20)),
                      color: Colors.black,
                      onPressed: existRoom
                          ? () {
                              if (userList.isNotEmpty) userList.clear();
                              print(
                                  "FirebaseInstance.instance.allUserList.length: ${FirebaseInstance.instance.allUserList.length}");

                              userList.addAll(FirebaseInstance.instance.allUserList);
                              print("userList size: ${userList.length}");
                              if (userList.length > 0) {
                                List<mUser.User> leftUserItems = userList;
                                print("enterUserList size: ${enterUserList.length}");
                                enterUserList.forEach((element) {
                                  leftUserItems.removeWhere((v) => v.name == element.name);
                                  // userList.where((v) => v.name != element.name).toList();
                                  // 중복된 값을 제거해야함. 이미 포함된 사용자를 제외하고 값을 얻고자함.
                                });
                                for(int i =0; i<leftUserItems.length; i++){
                                  leftUserItems[i].isCheck = false;
                                }

                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return Container(
                                        height: MediaQuery.of(context).size.height / 1.5,
                                        child: StatefulBuilder(
                                          builder: (BuildContext context, void Function(void Function()) setState) {
                                            return Column(
                                              children: [
                                                SizedBox(height: 16,),
                                                Container(
                                                  height: 4,
                                                  width: 32,
                                                  color: Colors.grey,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  child: Text("대기인원 목록", style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold
                                                  ),),
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context).size.height / 2.1,
                                                  child: ListView.separated(
                                                    itemCount: leftUserItems.length,
                                                    itemBuilder: (context, index) {
                                                      return CheckboxListTile(
                                                        title: Text(leftUserItems[index].name),
                                                        subtitle: Text(leftUserItems[index].team),
                                                        onChanged: (bool value) {
                                                          print(value);
                                                          setState(() {
                                                            leftUserItems[index].isCheck = value;
                                                          });
                                                        },
                                                        value: leftUserItems[index].isCheck,
                                                      );
                                                    },
                                                    separatorBuilder: (BuildContext context, int index) {
                                                      return Divider(
                                                        height: 6,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 16,),
                                                GestureDetector(
                                                  onTap: () async {
                                                    List<mUser.User> checkUserList = leftUserItems
                                                        .where((element) => element.isCheck == true)
                                                        .toList();
                                                    if (checkUserList.length > 0) {
                                                      checkUserList.addAll(enterUserList);
                                                      List<String> nameList = [];
                                                      checkUserList.forEach((u) {
                                                        nameList.add(u.name);
                                                      });
                                                      print(checkUserList.length);
                                                      await firestore
                                                          .collection("lunch")
                                                          .doc(currentDate)
                                                          .update(data: {"users": nameList});

                                                      setState(() {
                                                        enterUserList.clear();
                                                      });
                                                      await refreshEnterUserList();
                                                      Navigator.of(context).pop();
                                                      // await firestore.collection("lunch").doc(currentDate).set({"users": []});
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg: "1명 이상 선택해야 참가가 가능합니다.", webPosition: "center");
                                                      Navigator.of(context).pop();

                                                    }
                                                  },
                                                  child: Container(
                                                    height: 72,
                                                    decoration: BoxDecoration(color: Colors.black),
                                                    child: Center(
                                                      child: Text(
                                                        "신청하기",
                                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    });
                              } else {
                                Fluttertoast.showToast(
                                  msg: "정보를 가져오고 있습니다. 잠시만 기다려주세요",
                                );
                              }
                            }
                          : null,
                    ),
                  )),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // print(currentDate);
              DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
              // print(querySnapshot);
              if (querySnapshot == null || !querySnapshot.exists) {
                // Document with id == docId doesn't exist.
                print("Not exist");
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text("생성된 방이 없습니다."),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("확인")),
                            ElevatedButton(
                                onPressed: () async {
                                  // DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
                                  await firestore
                                      .collection("lunch")
                                      .doc(currentDate)
                                      .set({"users": [], "isClosed": false});
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(msg: "방만들기 성공", webPosition: "center");
                                  setState(() {});
                                },
                                child: Text("방만들기"))
                          ],
                        ));
              } else {
                Fluttertoast.showToast(msg: "이미 생성된 방이 존재합니다.", webPosition: "center");
              }
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        drawerItems: buildDrawerMenuWidgets(),
        controller: _controller,
      ),
    );
  }

  Widget buildLoadingWidget(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/pixeltrue-space-discovery.png",
            width: MediaQuery.of(context).size.width / 1.6,
          ),
          SizedBox(
            height: 16,
          ),
          CircularProgressIndicator(),
          SizedBox(
            height: 16,
          ),
          Text(msg),
        ],
      ),
    );
  }

  List<Widget> buildDrawerMenuWidgets() {
    return [
      Row(
        children: [
          Text(
            "LUNCH",
            style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            "QUEST",
            style: TextStyle(fontSize: 17, color: Colors.blue[200], fontWeight: FontWeight.bold),
          )
        ],
      ),
      Divider(
        endIndent: 32,
      ),
      ListTile(
        title: Text(
          "데이터",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.list_rounded,
          color: Colors.black,
        ),
        onTap: () {},
      ),
      Divider(
        endIndent: 32,
      ),
      ListTile(
        title: Text(
          "게시판",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.info_outline,
          color: Colors.black,
        ),
        onTap: () async {
          _controller.close();
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pushNamed("/bulletin_board");
        },
      ),
      ListTile(
        title: Text(
          "문의하기",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.info_outline,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/contact");
        },
      ),
      ListTile(
        title: Text(
          "About",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.info_outline,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/about");
        },
      )
    ];
  }
}
