import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:flutter_lunch_quest/src/enums/EnumPart.dart';
import 'package:flutter_lunch_quest/src/model/user.dart' as mUser;
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_browser_detect/web_browser_detect.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final browser = Browser();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  StreamSubscription<DocumentSnapshot> _streamSubscription;
  Firestore firestore = FirebaseInstance.instance.store;
  FancyDrawerController _controller;
  ConfettiController _controllerCenter;

  TabController _bottomSheetTabController;

  bool isOpen = false;
  bool existRoom = false;
  bool isPlaying = false;
  bool isClosed = false;

  List<mUser.User> userList = []; // 전체 사용자 리스트를 담는 변수
  List<mUser.User> enterUserList = []; // 참가한 사용자 리스트를 담는 변수

  int bentoUserLength = 0; //도시락 주문 인원을 받는 변수

  String currentDate = DateTime.now().toString().split(" ").first;
  int totalTicket;

  DateTime nowDateTime = DateTime.now(); // 생일자를 위한 매월 첫번째 주 월요일
  bool isParty = false;

  Future refreshEnterUserList() async {
    DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
    querySnapshot.data()["users"].forEach((element) {
      String part = "";
      if (element.toString().split(",").length == 1) {
        part = "일반";
      } else {
        part = element.toString().split(",").last;
      }
      String name = element.toString().split(",").first;
      enterUserList.add(mUser.User(name: name, team: "", part: part));
    });

    setState(() {});
  }

  Future onSetRoomClose(String date) async {
    await firestore.collection("lunch").doc(date).update(
      data: {"isClosed": true},
    );
  }

  Future onCheckRoomClosed(String date) async {
    DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(date).get();
    isClosed = await querySnapshot.data()["isClosed"];
    setState(() {});
  }

  //TODO: 사용자랑 생성된 날짜에 데이터가 있는지 확인
  Future checkExistRoom(String date) async {
    if (enterUserList.length > 0) enterUserList.clear();
    DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(date).get();
    if (querySnapshot == null || !querySnapshot.exists) {
      existRoom = false;
      isClosed = false;
    } else {
      existRoom = true;
      isClosed = querySnapshot.data()["isClosed"];
      print(isClosed);
      // print("querySnapshot.data() : ${querySnapshot.data()}");
      _streamSubscription = firestore.collection("lunch").doc(date).onSnapshot.listen((documentSnapshot) {
        if (enterUserList.length > 0) enterUserList.clear();
        // print(">>> documentSnapshot: ${documentSnapshot.get("users")}");
        // print(">>>> documentSnapshot data: ${documentSnapshot.data()}");
        documentSnapshot.get("users").forEach((element) {
          String part = "";
          if (element.toString().split(",").length == 1) {
            part = "일반";
          } else {
            part = element.toString().split(",").last;
          }
          String name = element.toString().split(",").first;
          enterUserList.add(mUser.User(name: name, team: "", part: part));
        });
        // print("도ㅓ시락사람: ${enterUserList.where((element) => element.name.split(',').last =="도시락").toList()}");
        setState(() {});
      });

      // querySnapshot.data()["users"].forEach((element) {
      //   String part = "";
      //   if (element.toString().split(",").length == 1) {
      //     part = "일반";
      //   } else {
      //     part = element.toString().split(",").last;
      //   }
      //   String name = element.toString().split(",").first;
      //   enterUserList.add(mUser.User(name: name, team: "", part: part));
      // });
    }
  }

  Future<int> fetchTotalTicketCount() async {
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    // print(querySnapshot.docs.first.data()["count"]);
    return querySnapshot.docs.first.data()["count"];
  }

  Future<int> updateTotalTicketCount(int v) async {
    int total = await fetchTotalTicketCount();
    print(total);
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    // print(querySnapshot.docs.first.data()["count"]);
    print(querySnapshot.docs.first.id);
    await querySnapshot.docs.first.ref.update(data: {"count": (total - v)});
  }

  @override
  void initState() {
    super.initState();
    print(">>> currentDate: $currentDate");
    _bottomSheetTabController = TabController(length: 10, vsync: this);
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 7));

    print("nowDateTime.day: ${nowDateTime.day},weekday: ${nowDateTime.weekday} ");
    if (nowDateTime.day < 7 && nowDateTime.weekday == 1) {
      print("party");
      _controllerCenter.play();
      setState(() {
        isParty = true;
      });
    }

    // Fluttertoast.showToast(msg: "The browser is ${browser.browser}");

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
    if (_streamSubscription != null) _streamSubscription.cancel();
    _controller.dispose(); // Dispose c
    _controllerCenter.dispose();
    super.dispose();
  }

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
                        tooltip: "메뉴",
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

                  //TODO: 캘린더 뷰
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
                  //TODO: 시간이랑 식권 뷰
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
                                ? GestureDetector(
                                    onTap: () {
                                      TextEditingController tmp = TextEditingController();
                                      showDialog(
                                          context: _drawerKey.currentContext,
                                          builder: (context) => AlertDialog(
                                                title: Text("식권 수정하기"),
                                                content: TextField(
                                                  controller: tmp,
                                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (tmp.text.length > 0) {
                                                      } else {}
                                                    },
                                                    child: Text("추가하기"),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Text("확인"),
                                                  ),
                                                ],
                                              ));
                                    },
                                    child: Row(
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
                                    ),
                                  )
                                : Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  isParty
                      ? SizedBox(
                          height: 64,
                          child: Card(
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: ConfettiWidget(
                                    confettiController: _controllerCenter,
                                    blastDirectionality:
                                        BlastDirectionality.explosive, // don't specify a direction, blast randomly
                                    shouldLoop: true, // start again as soon as the animation is finished
                                    colors: const [
                                      Colors.green,
                                      Colors.blue,
                                      Colors.pink,
                                      Colors.orange,
                                      Colors.purple
                                    ], // manually specify the colors to be used
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "오늘 파티가 예정되어있습니다.\n생일자분들 축하합니다.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(),

                  //TODO: 참가인원 뷰
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    width: MediaQuery.of(context).size.width,
                    child: existRoom
                        ? isClosed
                            ? buildQuestDoneWidget()
                            : Card(
                                child: enterUserList.length > 0
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
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
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                            child: Padding(
                                                          padding: const EdgeInsets.only(left: 8),
                                                          child: Text("도시락 파티"),
                                                        )),
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: LinearPercentIndicator(
                                                                  lineHeight: 6.0,
                                                                  percent: (enterUserList
                                                                          .where((element) => element.part == "도시락")
                                                                          .toList()
                                                                          .length /
                                                                      enterUserList.length),
                                                                  progressColor: Theme.of(context).accentColor,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${enterUserList.where((element) => element.part == "도시락").toList().length}/${enterUserList.length}명",
                                                                style: TextStyle(fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(child: Text("일반 파티")),
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: LinearPercentIndicator(
                                                                  lineHeight: 6.0,
                                                                  percent: (enterUserList
                                                                          .where((element) => element.part == "일반")
                                                                          .toList()
                                                                          .length /
                                                                      enterUserList.length),
                                                                  progressColor: Colors.red,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${enterUserList.where((element) => element.part == "일반").toList().length}/${enterUserList.length}명",
                                                                style: TextStyle(fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 24,
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(child: Text("미참가")),
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: FirebaseInstance.instance.allUserList.length > 0
                                                                    ? LinearPercentIndicator(
                                                                        lineHeight: 6.0,
                                                                        percent: (FirebaseInstance
                                                                                    .instance.allUserList.length -
                                                                                enterUserList.length) /
                                                                            FirebaseInstance
                                                                                .instance.allUserList.length,
                                                                        progressColor: Colors.blueGrey,
                                                                      )
                                                                    : LinearPercentIndicator(
                                                                        lineHeight: 6.0,
                                                                        percent: 0.0,
                                                                        progressColor: Colors.blueGrey,
                                                                      ),
                                                              ),
                                                              Text(
                                                                FirebaseInstance.instance.allUserList.length > 0
                                                                    ? "${FirebaseInstance.instance.allUserList.length - enterUserList.length}/${FirebaseInstance.instance.allUserList.length}명"
                                                                    : "?/?명",
                                                                style: TextStyle(fontSize: 12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: MaterialButton(
                                                  minWidth: double.infinity,
                                                  color: Colors.black,
                                                  onPressed: () {
                                                    Navigator.of(context).pushNamed("/quest/battle/monster");
                                                  },
                                                  child: Text(
                                                    "퀘스트참가",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                )),
                                          ),
                                          Expanded(
                                            flex: 2,
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
                                                      tooltip: "새로고침",
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
                                            flex: 15,
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
                                                    child: Tooltip(
                                                      message: "${enterUserList[index].name}",
                                                      child: ListTile(
                                                          leading: Text(index.toString()),
                                                          title: Text(enterUserList[index].name),
                                                          trailing:
                                                              Text(enterUserList[index].part == "도시락" ? "도시락" : "일반")),
                                                    ),
                                                    secondaryActions: <Widget>[
                                                      Tooltip(
                                                        message: '수정하기',
                                                        child: IconSlideAction(
                                                            caption: '수정',
                                                            color: Colors.blue,
                                                            icon: Icons.edit_outlined,
                                                            onTap: () async {
                                                              EnumPart p = enterUserList[index].part == "일반"
                                                                  ? EnumPart.normal
                                                                  : EnumPart.bento;
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      content: StatefulBuilder(
                                                                        builder: (BuildContext context,
                                                                            void Function(void Function()) setState) {
                                                                          return Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            children: [
                                                                              RadioListTile(
                                                                                  title: Text("일반"),
                                                                                  value: EnumPart.normal,
                                                                                  groupValue: p,
                                                                                  onChanged: (v) {
                                                                                    setState(() {
                                                                                      p = v;
                                                                                    });
                                                                                  }),
                                                                              RadioListTile(
                                                                                  title: Text("도시락"),
                                                                                  value: EnumPart.bento,
                                                                                  groupValue: p,
                                                                                  onChanged: (v) {
                                                                                    setState(() {
                                                                                      p = v;
                                                                                    });
                                                                                  })
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                      title: Text("수정"),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child: Text("취소")),
                                                                        ElevatedButton(
                                                                            onPressed: () async {
                                                                              List<mUser.User> copyList = enterUserList;
                                                                              if (p == EnumPart.normal) {
                                                                                copyList
                                                                                    .singleWhere((element) =>
                                                                                        element.name ==
                                                                                        enterUserList[index].name)
                                                                                    .part = "일반";
                                                                              } else {
                                                                                copyList
                                                                                    .singleWhere((element) =>
                                                                                        element.name ==
                                                                                        enterUserList[index].name)
                                                                                    .part = "도시락";
                                                                              }

                                                                              await firestore
                                                                                  .collection("lunch")
                                                                                  .doc(currentDate)
                                                                                  .update(data: {
                                                                                "users": copyList
                                                                                    .map((e) => "${e.name},${e.part}")
                                                                                    .toList()
                                                                              });

                                                                              // setState(() {
                                                                              //   enterUserList.clear();
                                                                              // });
                                                                              // await refreshEnterUserList();
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child: Text("네")),
                                                                      ],
                                                                    );
                                                                    return StatefulBuilder(
                                                                      builder: (BuildContext context,
                                                                          void Function(void Function()) setState) {
                                                                        EnumPart p = enterUserList[index].part == "일반"
                                                                            ? EnumPart.normal
                                                                            : EnumPart.bento;
                                                                        return AlertDialog(
                                                                          title: Text("수정"),
                                                                          content: Column(
                                                                            children: [
                                                                              RadioListTile(
                                                                                  title: Text("일반"),
                                                                                  value: EnumPart.normal,
                                                                                  groupValue: p,
                                                                                  onChanged: (v) {
                                                                                    setState(() {
                                                                                      p = v;
                                                                                    });
                                                                                  }),
                                                                              RadioListTile(
                                                                                  title: Text("도시락"),
                                                                                  value: EnumPart.bento,
                                                                                  groupValue: p,
                                                                                  onChanged: (v) {
                                                                                    setState(() {
                                                                                      p = v;
                                                                                    });
                                                                                  })
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                                child: Text("취소")),
                                                                            ElevatedButton(
                                                                                onPressed: () async {
                                                                                  List<mUser.User> copyList =
                                                                                      enterUserList;
                                                                                  copyList.removeWhere((element) =>
                                                                                      element.name ==
                                                                                      enterUserList[index].name);

                                                                                  await firestore
                                                                                      .collection("lunch")
                                                                                      .doc(currentDate)
                                                                                      .update(data: {
                                                                                    "users": copyList
                                                                                        .map((e) =>
                                                                                            "${e.name},${e.part}")
                                                                                        .toList()
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
                                                                      },
                                                                    );
                                                                  });
                                                            }),
                                                      ),
                                                      Tooltip(
                                                        message: '삭제하기',
                                                        child: IconSlideAction(
                                                            caption: '삭제',
                                                            color: Colors.red,
                                                            icon: Icons.delete,
                                                            onTap: () async {
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return AlertDialog(
                                                                      title: Text("경고"),
                                                                      content: Text(
                                                                          "${enterUserList[index].name} 님을 방에서 제거할까요?"),
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
                                                                                  element.name ==
                                                                                  enterUserList[index].name);

                                                                              await firestore
                                                                                  .collection("lunch")
                                                                                  .doc(currentDate)
                                                                                  .update(data: {
                                                                                "users": copyList
                                                                                    .map((e) => "${e.name},${e.part}")
                                                                                    .toList()
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
                                                      ),
                                                    ],
                                                  );
                                                }),
                                          ),
                                        ],
                                      )
                                    : buildLoadingWidget("참가 대기중"))
                        : buildEmptyRoomWidget(),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 12.0,
            child: Container(
              height: 72,
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
                      onPressed: existRoom
                          ? () {
                              if (isClosed) {
                                showDialog(
                                    context: _drawerKey.currentContext,
                                    builder: (context) => AlertDialog(
                                          title: Text("안내"),
                                          content: Text(
                                            "이미 종료된 방입니다.",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text("확인")),
                                          ],
                                        ));
                              } else {
                                showDialog(
                                    context: _drawerKey.currentContext,
                                    builder: (context) => AlertDialog(
                                          title: Text("퀘스트종료"),
                                          content: Text(
                                            "마감하고 방을 닫을까요? 한번 닫으면 다시 열수 없습니다. 주의해주세요",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await onSetRoomClose(currentDate);
                                                  await onCheckRoomClosed(currentDate);
                                                  await updateTotalTicketCount(enterUserList.length);
                                                  totalTicket = await fetchTotalTicketCount();
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
                                        ));
                              }
                            }
                          : null,
                    ),
                  )),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 64, right: 16),
                    child: Tooltip(
                      message: "참가신청",
                      child: MaterialButton(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text("참가신청", style: TextStyle(color: Colors.white, fontSize: 20)),
                        color: Colors.black,
                        onPressed: existRoom
                            ? () async {
                                if (isClosed) {
                                  showDialog(
                                      context: _drawerKey.currentContext,
                                      builder: (context) => AlertDialog(
                                            title: Text("안내"),
                                            content: Text(
                                              "이미 종료된 방입니다. 다음에 다시 참여해주세요!",
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("확인")),
                                            ],
                                          ));
                                } else {
                                  if (userList.isNotEmpty) userList.clear();
                                  print("allUserList.length: ${FirebaseInstance.instance.allUserList.length}");

                                  userList.addAll(FirebaseInstance.instance.allUserList);
                                  print("userList size: ${userList.length}");
                                  if (userList.length > 0) {
                                    //TODO: 전체 사용자를 복사함
                                    List<mUser.User> leftUserItems = userList;
                                    print("enterUserList size: ${enterUserList.length}");
                                    //TODO: 방에 있는 인원(이미 신청된 인원의 목록을 돌려 전체 사용자에서 제거
                                    enterUserList.forEach((element) {
                                      leftUserItems.removeWhere((v) => v.name == element.name);
                                      // userList.where((v) => v.name != element.name).toList();
                                      // 중복된 값을 제거해야함. 이미 포함된 사용자를 제외하고 값을 얻고자함.
                                    });

                                    //TODO: 남은 사용사의 체크 목록을 초기화
                                    for (int i = 0; i < leftUserItems.length; i++) {
                                      leftUserItems[i].isCheck = false;
                                    }

                                    await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Container(
                                            height: MediaQuery.of(context).size.height / 1.15,
                                            child: StatefulBuilder(
                                              builder: (BuildContext context, void Function(void Function()) setState) {
                                                return Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 16,
                                                    ),
                                                    Container(
                                                      height: 4,
                                                      width: 32,
                                                      decoration: BoxDecoration(
                                                          color: Colors.grey, borderRadius: BorderRadius.circular(8)),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                                      child: Text(
                                                        "대기인원 목록",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    TabBar(
                                                      isScrollable: true,
                                                      labelColor: Theme.of(context).accentColor,
                                                      unselectedLabelColor: Colors.grey,
                                                      controller: _bottomSheetTabController,
                                                      indicatorSize: TabBarIndicatorSize.label,
                                                      indicatorColor: Theme.of(context).accentColor,
                                                      tabs: [
                                                        Tab(text: "c_level"),
                                                        Tab(text: "기타"),
                                                        Tab(text: "대외협력팀"),
                                                        Tab(text: "로봇연구개발팀"),
                                                        Tab(text: "로봇재활지원팀"),
                                                        Tab(text: "생산총괄팀"),
                                                        Tab(text: "영업팀"),
                                                        Tab(text: "인사총무팀"),
                                                        Tab(text: "재무회계팀"),
                                                        Tab(text: "홍보마케팅"),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: MediaQuery.of(context).size.height / 2,
                                                      child:
                                                          TabBarView(controller: _bottomSheetTabController, children: [
                                                        //TODO clevel
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "c_level") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "c_level") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "c_level")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "c_level").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "c_level")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "c_level")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where((element) =>
                                                                                  element.team == "c_level")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "c_level")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Container(
                                                        //   height: MediaQuery.of(context).size.height / 2,
                                                        //   child: ListView.separated(
                                                        //     itemCount: leftUserItems.length,
                                                        //     itemBuilder: (context, index) {
                                                        //       return Tooltip(
                                                        //         message: '${leftUserItems[index].name}',
                                                        //         child: CheckboxListTile(
                                                        //           title: Text(leftUserItems[index].name),
                                                        //           subtitle: Text(leftUserItems[index].team),
                                                        //           onChanged: (bool value) {
                                                        //             print(value);
                                                        //             setState(() {
                                                        //               leftUserItems[index].isCheck = value;
                                                        //             });
                                                        //           },
                                                        //           value: leftUserItems[index].isCheck,
                                                        //         ),
                                                        //       );
                                                        //     },
                                                        //     separatorBuilder: (BuildContext context, int index) {
                                                        //       return Divider(
                                                        //         height: 6,
                                                        //       );
                                                        //     },
                                                        //   ),
                                                        // ),
                                                        //TODO 기타
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "기타") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "기타") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "기타")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "기타").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "기타")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "기타")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where((element) => element.team == "기타")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "기타")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO 대외 협력팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "대외협력팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "대외협력팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "대외협력팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "대외협력팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "대외협력팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "대외협력팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where(
                                                                                  (element) => element.team == "대외협력팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "대외협력팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  로봇연구개발팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "로봇연구개발팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "로봇연구개발팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "로봇연구개발팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "로봇연구개발팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "로봇연구개발팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "로봇연구개발팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where((element) =>
                                                                                  element.team == "로봇연구개발팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "로봇연구개발팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  로봇재활지원팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "로봇재활지원팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "로봇재활지원팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "로봇재활지원팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "로봇재활지원팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "로봇재활지원팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "로봇재활지원팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where((element) =>
                                                                                  element.team == "로봇재활지원팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "로봇재활지원팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  생산총괄팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "생산총괄팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "생산총괄팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "생산총괄팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "생산총괄팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "생산총괄팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "생산총괄팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where(
                                                                                  (element) => element.team == "생산총괄팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "생산총괄팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  영업팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "영업팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "영업팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "영업팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "영업팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "영업팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "영업팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where((element) => element.team == "영업팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "영업팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  인사총무팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "인사총무팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "인사총무팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "인사총무팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "인사총무팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "인사총무팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "인사총무팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where(
                                                                                  (element) => element.team == "인사총무팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "인사총무팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  재무회계팀
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "재무회계팀") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "재무회계팀") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "재무회계팀")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "재무회계팀").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "재무회계팀")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "재무회계팀")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where(
                                                                                  (element) => element.team == "재무회계팀")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "재무회계팀")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        //TODO  홍보마케팅
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Expanded(
                                                              flex: 2,
                                                              child: ButtonBar(
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "홍보마케팅") {
                                                                          leftUserItems[i].isCheck = false;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체취소"),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      for (int i = 0; i < leftUserItems.length; i++) {
                                                                        if (leftUserItems[i].team == "홍보마케팅") {
                                                                          leftUserItems[i].isCheck = true;
                                                                        }
                                                                      }
                                                                      setState(() {});
                                                                    },
                                                                    child: Text("전체선택"),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 8,
                                                            ),
                                                            Expanded(
                                                              flex: 12,
                                                              child: ListView.separated(
                                                                itemCount: leftUserItems
                                                                    .where((element) => element.team == "홍보마케팅")
                                                                    .length,
                                                                itemBuilder: (context, index) {
                                                                  return Tooltip(
                                                                    message:
                                                                        '${leftUserItems.where((element) => element.team == "홍보마케팅").toList()[index].name}',
                                                                    child: CheckboxListTile(
                                                                      title: Text(leftUserItems
                                                                          .where((element) => element.team == "홍보마케팅")
                                                                          .toList()[index]
                                                                          .name),
                                                                      subtitle: Text(leftUserItems
                                                                          .where((element) => element.team == "홍보마케팅")
                                                                          .toList()[index]
                                                                          .team),
                                                                      onChanged: (bool value) {
                                                                        print(value);
                                                                        setState(() {
                                                                          leftUserItems
                                                                              .where(
                                                                                  (element) => element.team == "홍보마케팅")
                                                                              .toList()[index]
                                                                              .isCheck = value;
                                                                        });
                                                                      },
                                                                      value: leftUserItems
                                                                          .where((element) => element.team == "홍보마케팅")
                                                                          .toList()[index]
                                                                          .isCheck,
                                                                    ),
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    height: 6,
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ]),
                                                    ),
                                                    SizedBox(
                                                      height: 16,
                                                    ),
                                                    Tooltip(
                                                      message: '신청하기',
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          await onRegistrationUser(leftUserItems);
                                                        },
                                                        child: Container(
                                                          height: 72,
                                                          decoration: BoxDecoration(color: Colors.black),
                                                          child: Center(
                                                            child: Text(
                                                              "신청하기 (${leftUserItems.where((element) => element.isCheck == true).toList().length}명)",
                                                              style: TextStyle(color: Colors.white, fontSize: 18),
                                                            ),
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
                              }
                            : null,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (isClosed) {
                showDialog(
                    context: _drawerKey.currentContext,
                    builder: (context) => AlertDialog(
                          title: Text("안내"),
                          content: Text(
                            "이미 종료된 방입니다.",
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("확인")),
                          ],
                        ));
                return;
              }
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

                                  Fluttertoast.showToast(msg: "방만들기 성공", webPosition: "center");
                                  setState(() {
                                    existRoom = true;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text("방만들기"))
                          ],
                        ));
              } else {
                Fluttertoast.showToast(msg: "이미 생성된 방이 존재합니다.", webPosition: "center");
              }
            },
            tooltip: '방만들기',
            child: Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        drawerItems: buildDrawerMenuWidgets(),
        controller: _controller,
      ),
    );
  }

  Future onRegistrationUser(List<mUser.User> leftUserItems) async {
    bool isBento = false;
    List<mUser.User> checkUserList = leftUserItems.where((element) => element.isCheck == true).toList();
    if (checkUserList.length > 0) {
      bentoUserLength = checkUserList.length;
      await showDialog(
          context: _drawerKey.currentContext,
          builder: (context) => WillPopScope(
                onWillPop: () {},
                child: AlertDialog(
                  title: Text("안내"),
                  content: Text("혹시 도시락 주문하세요?"),
                  actions: [
                    ButtonBar(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              isBento = true;
                              Navigator.of(context).pop();
                            },
                            child: Text("네")),
                        ElevatedButton(
                          onPressed: () async {
                            isBento = false;
                            Navigator.of(context).pop();
                          },
                          child: Text("아니요"),
                        )
                      ],
                    ),
                  ],
                ),
              ));
      if (isBento) {
        await showDialog(
            context: _drawerKey.currentContext,
            builder: (context) => WillPopScope(
                  onWillPop: () {},
                  child: StatefulBuilder(
                    builder: (BuildContext context, void Function(void Function()) setState) {
                      String bentoTime = "";
                      return AlertDialog(
                        title: Text("안내"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("잠깐만요! 어떤 핸드폰 사용하세요?"
                                "\n제가 문자로 바로 전달할 수 있도록 도와줄게요."),
                            TimePickerSpinner(
                              is24HourMode: true,
                              highlightedTextStyle: TextStyle(color: Theme.of(context).accentColor, fontSize: 32),
                              normalTextStyle: TextStyle(color: Theme.of(context).accentColor, fontSize: 32),
                              onTimeChange: (time) {
                                bentoTime = DateFormat("HH시mm분").format(time);
                              },
                            )
                          ],
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: Text("괜찮아")),
                          ElevatedButton(
                              onPressed: () async {
                                String url = 'tel:01020138844';
                                launch(url);
                                Navigator.of(context).pop();
                              },
                              child: Text("전화로하기")),
                          ElevatedButton(
                              onPressed: () async {
                                String url =
                                    'sms:01020138844&body=안녕하세요 6층 엔젤로보틱스 $bentoUserLength명 $bentoTime에 도시락 받으러갈게요!';
                                launch(url);
                                Navigator.of(context).pop();
                              },
                              child: Text("아이폰")),
                          ElevatedButton(
                            onPressed: () async {
                              // Fluttertoast.showToast(
                              //     msg: "웹이에요");
                              String url =
                                  'sms:01020138844?body=안녕하세요 6층 엔젤로보틱스 $bentoUserLength명 $bentoTime에 도시락 받으러갈게요!';
                              launch(url);
                              Navigator.of(context).pop();
                            },
                            child: Text("안드로이드"),
                          )
                        ],
                      );
                    },
                  ),
                ));

        //TODO enterUserList는 기존에 방에 들어가있는 사람의 목록이다.
        //TODO 도시락인 경우 도시락 사람만 도시락으로 쓰기
        for (int i = 0; i < checkUserList.length; i++) {
          checkUserList[i].part = "도시락";
        }
        checkUserList.addAll(enterUserList);
        List<String> nameList = [];

        checkUserList.forEach((u) {
          //TODO 도시락이랑 일반이랑 구분하기 위함.
          // print(u.name.split(',').length);
          // print(" ${u.name.split(',').first}  /  ${u.name.split(',').last}");

          nameList.add("${u.name},${u.part}");
          // nameList.add("${u.name}");
        });
        print(checkUserList.length);
        await firestore.collection("lunch").doc(currentDate).update(data: {"users": nameList});

        setState(() {
          enterUserList.clear();
        });
        await refreshEnterUserList();
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "신청이 완료되었어요.", webPosition: "center");
      } else {
        List<String> nameList = [];

        for (int i = 0; i < checkUserList.length; i++) {
          checkUserList[i].part = "일반";
        }
        checkUserList.addAll(enterUserList);

        checkUserList.forEach((u) {
          //TODO 도시락이랑 일반이랑 구분하기 위함.
          // print(u.name.split(',').length);
          // print(" ${u.name.split(',').first}  /  ${u.name.split(',').last}");

          nameList.add("${u.name},${u.part}");
          // nameList.add("${u.name}");
        });
        print(checkUserList.length);
        await firestore.collection("lunch").doc(currentDate).update(data: {"users": nameList});

        setState(() {
          enterUserList.clear();
        });
        await refreshEnterUserList();
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "신청이 완료되었어요.", webPosition: "center");
      }

      // await firestore.collection("lunch").doc(currentDate).set({"users": []});
    } else {
      Fluttertoast.showToast(msg: "1명 이상 선택해야 참가가 가능합니다.", webPosition: "center");
      Navigator.of(context).pop();
    }
  }

  Widget buildQuestDoneWidget() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/pixeltrue-welcome.png",
            width: MediaQuery.of(context).size.width / 1.5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "퀘스트가 종료되었습니다.",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          MaterialButton(
            onPressed: () {
              showDialog(
                  context: _drawerKey.currentContext,
                  builder: (context) => AlertDialog(
                        title: Text("참가인원(${enterUserList.length}명)"),
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height / 2.5,
                          width: MediaQuery.of(context).size.width / 1.3,
                          child: ListView.builder(
                              itemCount: enterUserList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Text("$index"),
                                  title: Text("${enterUserList[index].name}"),
                                  trailing: Text("${enterUserList[index].part}"),
                                );
                              }),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("확인"))
                        ],
                      ));
            },
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "참가인원보기",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyRoomWidget() {
    return Card(
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
      Image.asset(
        "assets/img/animation_640_kkkzx3os.gif",
        width: MediaQuery.of(context).size.width / 2.5,
        fit: BoxFit.fitWidth,
      ),
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
        height: 4,
        endIndent: 32,
        color: Colors.grey,
      ),
      ListTile(
        title: Text(
          "기록/데이터",
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(
          Icons.list_rounded,
          color: Colors.black,
        ),
        onTap: () {
          Navigator.of(context).pushNamed("/data/record");
          // showDialog(
          //     context: context,
          //     builder: (context) {
          //
          //       return AlertDialog(
          //         content: Text("개발중."),
          //         actions: [
          //           Tooltip(
          //               message: '확인',
          //               child: ElevatedButton(
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                 },
          //                 child: Text("확인"),
          //               ))
          //         ],
          //       );
          //     });
        },
      ),
      Divider(
        height: 4,
        endIndent: 32,
        color: Colors.grey,
      ),
      Tooltip(
        message: "게시판이동",
        child: ListTile(
          title: Text(
            "자유게시판",
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(
            Icons.developer_board_outlined,
            color: Colors.black,
          ),
          onTap: () async {
            _controller.close();
            await Future.delayed(Duration(milliseconds: 500));
            Navigator.of(context).pushNamed("/bulletin_board");
          },
        ),
      ),
      Tooltip(
        message: "문의하기 이동",
        child: ListTile(
          title: Text(
            "문의하기",
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(
            Icons.mode_edit,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.of(context).pushNamed("/contact");
          },
        ),
      ),
      Divider(
        height: 4,
        endIndent: 32,
        color: Colors.grey,
      ),
      Tooltip(
        message: '메뉴선택',
        child: ListTile(
          title: Text(
            "메뉴선택",
            style: TextStyle(color: Colors.black),
          ),
          leading: Icon(
            Icons.restaurant_menu,
            color: Colors.black,
          ),
          onTap: () {
            showDialog(
                context: _drawerKey.currentContext,
                builder: (context) => AlertDialog(
                      content: Image.asset("assets/img/food_table_01.png"),
                    ));
            // Navigator.of(context).pushNamed("/about");
          },
        ),
      ),
      Tooltip(
        message: '개발 정보',
        child: ListTile(
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
        ),
      )
    ];
  }
}
