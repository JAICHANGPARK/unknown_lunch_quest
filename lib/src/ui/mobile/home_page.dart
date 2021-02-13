import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:flutter_lunch_quest/src/db/pref_api.dart';
import 'package:flutter_lunch_quest/src/enums/EnumPart.dart';
import 'package:flutter_lunch_quest/src/enums/enum_order_time.dart';
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

import 'common/web_network_image.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final browser = Browser();
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  StreamSubscription<QuerySnapshot> _streamSubscription;
  Firestore firestore = FirebaseInstance.instance.store;
  FancyDrawerController _controller;
  ConfettiController _controllerCenter;

  TabController _bottomSheetTabController;

  bool existRoom = false; // 방이 존재하는지 확인
  bool isPlaying = false;
  bool isClosed = false; // 방의 마감여부확인
  bool isWeekend = false; // 주말인지 확인
  bool isInit = false;

  List<mUser.User> userList = []; // 전체 사용자 리스트를 담는 변수
  List<mUser.User> enterUserList = []; // 참가한 사용자 리스트를 담는 변수

  int bentoUserLength = 0; //도시락 주문 인원을 받는 변수

  String currentDate = DateTime.now().toString().split(" ").first;
  int totalTicket;

  DateTime nowDateTime = DateTime.now(); // 생일자를 위한 매월 첫번째 주 월요일
  String initDateTime;

  bool isParty = false;
  int questUserCount = 0;

  Future refreshEnterUserList() async {
    if (enterUserList.length > 0) enterUserList.clear();
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

  Future onUpdateUsedTicket(String date, int value) async {
    await firestore.collection("lunch").doc(date).update(
      data: {"ticket_left": value},
    );
  }

  Future onAddUsedTicketLog({String date, int used, int left}) async {
    await firestore.collection("ticket").doc("log").collection("used").add({"date": DateTime.parse(date), "left": left, "used": used});
  }

  void streamLunchCollection() {
    _streamSubscription = firestore.collection("lunch").onSnapshot.listen((querySnapshot) {
      if (enterUserList.length > 0) enterUserList.clear();
      querySnapshot.docChanges().forEach((change) {
        if (change.type == "added" || change.type == "modified") {
          // Do something with change.doc
          // print("change : added or modified");
          // print(change.doc.id);
          if (change.doc.id == currentDate) {
            questUserCount = List.from(change.doc.get("quest_entered")).length;
            // print("Entered Process : $currentDate");
            List<String> userList = List<String>.from(change.doc.data()['users']);
            userList.forEach((element) {
              String part = "";
              if (element.toString().split(",").length == 1) {
                part = "일반";
              } else {
                part = element.toString().split(",").last;
              }
              String name = element.toString().split(",").first;
              // print("$name / $part");
              enterUserList.add(mUser.User(name: name, team: "", part: part));
            });
          }
        }
        setState(() {});
        // else if (change.type == "modified") {
        //   print("change : modified");
        //   print(change.doc.id);
        // }
      });

      // print(">>> documentSnapshot: ${documentSnapshot.get("users")}");
      // print(">>>> documentSnapshot data: ${documentSnapshot.data()}");
      // questUserCount = List.from(documentSnapshot.get("quest_entered")).length;
      // documentSnapshot.get("users").forEach((element) {
      //   String part = "";
      //   if (element.toString().split(",").length == 1) {
      //     part = "일반";
      //   } else {
      //     part = element.toString().split(",").last;
      //   }
      //   String name = element.toString().split(",").first;
      //   enterUserList.add(mUser.User(name: name, team: "", part: part));
      // });
      // // print("도ㅓ시락사람: ${enterUserList.where((element) => element.name.split(',').last =="도시락").toList()}");
      // setState(() {});
    });

    // _streamSubscription = firestore.collection("lunch").doc(date).onSnapshot.listen((documentSnapshot) {
    //   if (enterUserList.length > 0) enterUserList.clear();
    //   // print(">>> documentSnapshot: ${documentSnapshot.get("users")}");
    //   // print(">>>> documentSnapshot data: ${documentSnapshot.data()}");
    //   questUserCount = List.from(documentSnapshot.get("quest_entered")).length;
    //   documentSnapshot.get("users").forEach((element) {
    //     String part = "";
    //     if (element.toString().split(",").length == 1) {
    //       part = "일반";
    //     } else {
    //       part = element.toString().split(",").last;
    //     }
    //     String name = element.toString().split(",").first;
    //     enterUserList.add(mUser.User(name: name, team: "", part: part));
    //   });
    //   // print("도ㅓ시락사람: ${enterUserList.where((element) => element.name.split(',').last =="도시락").toList()}");
    //   setState(() {});
    // });
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
      // print(isClosed);
      // print("querySnapshot.data() : ${querySnapshot.data()}");
      // _streamSubscription = firestore.collection("lunch").doc(date).onSnapshot.listen((documentSnapshot) {
      //   if (enterUserList.length > 0) enterUserList.clear();
      //   // print(">>> documentSnapshot: ${documentSnapshot.get("users")}");
      //   // print(">>>> documentSnapshot data: ${documentSnapshot.data()}");
      //   questUserCount = List.from(documentSnapshot.get("quest_entered")).length;
      //   documentSnapshot.get("users").forEach((element) {
      //     String part = "";
      //     if (element.toString().split(",").length == 1) {
      //       part = "일반";
      //     } else {
      //       part = element.toString().split(",").last;
      //     }
      //     String name = element.toString().split(",").first;
      //     enterUserList.add(mUser.User(name: name, team: "", part: part));
      //   });
      //   // print("도ㅓ시락사람: ${enterUserList.where((element) => element.name.split(',').last =="도시락").toList()}");
      //   setState(() {});
      // });
      if (isInit) {
        questUserCount = List.from(querySnapshot.data()["quest_entered"] ?? []).length;
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
      }
    }
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

  Future<void> onSetTotalTicketCount(int value) async {
    QuerySnapshot querySnapshot = await firestore.collection("ticket").get();
    int total = querySnapshot.docs.first.data()["count"];
    await querySnapshot.docs.first.ref.update(data: {"count": (total + value)});
  }

  @override
  void initState() {
    super.initState();
    // print(">>> currentDate: $currentDate");
    _bottomSheetTabController = TabController(length: 10, vsync: this);
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 7));

    _controller = FancyDrawerController(vsync: this, duration: Duration(milliseconds: 150))
      ..addListener(() {
        if (_controller.state == DrawerState.closing) {
          isPlaying = false;
        }
        setState(() {}); // Must call setState
      }); // This chunk of code is important

    if (nowDateTime.weekday == 6 || nowDateTime.weekday == 7) {
      setState(() {
        isWeekend = true;
      });
    }
    if (nowDateTime.day < 7 && nowDateTime.weekday == 1) {
      _controllerCenter.play();
      setState(() {
        isParty = true;
      });
    }

    checkExistRoom(currentDate).then((value) {
      setState(() {});
    });

    fetchTotalTicketCount().then((value) {
      setState(() {
        totalTicket = value;
      });
    });
    streamLunchCollection();
    isInit = true; // checkExistRoom에서 처음에 stream과 중복되서 사용자를 가져오는것을 방지하기 위함
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    readSelectDate().then((value) {
      if (value != null) {
        setState(() {
          initDateTime = value;
        });
      }
    });
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
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlutterDatePickerTimeline(
                          startDate: DateTime.now().add(Duration(days: -14)),
                          endDate: DateTime.now(),
                          initialSelectedDate: DateTime.now(),
                          onSelectedDateChange: (DateTime dateTime) async {
                            // print(dateTime);
                            if (dateTime.weekday == 6 || dateTime.weekday == 7) {
                              setState(() {
                                isWeekend = true;
                              });
                            } else {
                              setState(() {
                                isWeekend = false;
                              });
                            }
                            currentDate = DateFormat("yyyy-MM-dd").format(dateTime);
                            await saveSelectDate(dateTime.toString());
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
                          child: Center(
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "현재시각",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "NanumBarunpenR",
                                      ),
                                    ),
                                    Spacer(),
                                    DigitalClock(
                                      areaDecoration: BoxDecoration(color: Colors.transparent),
                                      areaAligment: AlignmentDirectional.centerEnd,
                                      hourMinuteDigitDecoration: BoxDecoration(color: Colors.transparent),
                                      hourMinuteDigitTextStyle: TextStyle(fontSize: 14),
                                      secondDigitTextStyle: TextStyle(fontSize: 14),
                                    )
                                  ],
                                )),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: totalTicket != null
                                ? GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          "총 식권수",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "NanumBarunpenR",
                                          ),
                                        ),
                                        Spacer(),
                                        Text(
                                          "$totalTicket 장",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: "NanumBarunpenR",
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
                  SizedBox(
                    height: 4,
                  ),
                  //TODO: 참가인원 뷰
                  SizedBox(
                      height: (isClosed || isWeekend || !existRoom || enterUserList.length == 0)
                          ? MediaQuery.of(context).size.height / 1.6
                          : MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: !isWeekend
                          ? existRoom
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
                                                Divider(height: 6),
                                                //TODO: 파티 목록
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                  child: Padding(
                                                                padding: const EdgeInsets.only(left: 8),
                                                                child: Text(
                                                                  "도시락 파티",
                                                                  style: TextStyle(
                                                                    fontFamily: "NanumBarunpenR",
                                                                  ),
                                                                ),
                                                              )),
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: LinearPercentIndicator(
                                                                        lineHeight: 6.0,
                                                                        percent: (enterUserList
                                                                                .where(
                                                                                    (element) => element.part == "도시락")
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
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                "일반 파티",
                                                                style: TextStyle(
                                                                  fontFamily: "NanumBarunpenR",
                                                                ),
                                                              )),
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: LinearPercentIndicator(
                                                                        lineHeight: 6.0,
                                                                        percent: (enterUserList
                                                                                .where(
                                                                                    (element) => element.part == "일반")
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
                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                            children: [
                                                              Expanded(
                                                                  child: Text(
                                                                "미참가",
                                                                style: TextStyle(
                                                                  fontFamily: "NanumBarunpenR",
                                                                ),
                                                              )),
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          FirebaseInstance.instance.allUserList.length >
                                                                                  0
                                                                              ? LinearPercentIndicator(
                                                                                  lineHeight: 6.0,
                                                                                  percent: (FirebaseInstance.instance
                                                                                              .allUserList.length -
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
                                                //TODO: 퀘스트 참가 버튼
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: MaterialButton(
                                                        minWidth: double.infinity,
                                                        color: Colors.black,
                                                        onPressed: () async {
                                                          await saveDateCounter(currentDate);
                                                          Navigator.of(context).pushNamed("/quest/battle/monster");
                                                        },
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                                          child: Center(
                                                            child: Text(
                                                              "퀘스트참가 (현재 $questUserCount명 참가 중)",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontFamily: "NanumBarunpenR",
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )),
                                                ),
                                                //TODO: 참가 인원 뷰
                                                Expanded(
                                                  flex: 3,
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
                                                //TODO: 참가 인원 리스트뷰
                                                Expanded(
                                                  flex: 26,
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
                                                                trailing: Text(
                                                                    enterUserList[index].part == "도시락" ? "도시락" : "일반")),
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
                                                                        context: _drawerKey.currentContext,
                                                                        builder: (context) {
                                                                          return AlertDialog(
                                                                            content: StatefulBuilder(
                                                                              builder: (BuildContext context,
                                                                                  void Function(void Function())
                                                                                      setState) {
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
                                                                                    List<mUser.User> copyList =
                                                                                        enterUserList;
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
                                                                                          .map((e) =>
                                                                                              "${e.name},${e.part}")
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
                                                                                void Function(void Function())
                                                                                    setState) {
                                                                              EnumPart p =
                                                                                  enterUserList[index].part == "일반"
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
                                                                                        copyList.removeWhere(
                                                                                            (element) =>
                                                                                                element.name ==
                                                                                                enterUserList[index]
                                                                                                    .name);

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
                                                                        context: _drawerKey.currentContext,
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
                              : buildEmptyRoomWidget()
                          : buildWeekendWidget()),
                  SizedBox(height: 24),

                  //TODO: 도시락 나중에 한꺼번에 신청 뷰
                  (!isWeekend && existRoom && !isClosed && enterUserList.length > 0)
                      ? MaterialButton(
                          onPressed: () async {
                            var bentoTempItems = enterUserList.where((element) => element.part == "도시락").toList();
                            OrderTime orderTime = OrderTime.one;
                            String orderTimeText = "11시";
                            if (bentoTempItems.length > 0) {
                              await showDialog(
                                  context: _drawerKey.currentContext,
                                  builder: (context) {
                                    for (int i = 0; i < bentoTempItems.length; i++) {
                                      bentoTempItems[i].isCheck = true;
                                    }
                                    return AlertDialog(
                                      title: Text("도시락 예약하기"),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context, void Function(void Function()) setState) {
                                          return SizedBox(
                                            height: MediaQuery.of(context).size.height / 1.5,
                                            width: MediaQuery.of(context).size.width,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "1층 회사식당에 도시락을 예약합니다.",
                                                  style: TextStyle(
                                                    fontFamily: "NanumBarunpenR",
                                                  ),
                                                ),
                                                Text(
                                                  "현재 기능은 모바일에서만 가능합니다.",
                                                  style: TextStyle(
                                                    fontFamily: "NanumBarunpenR",
                                                  ),
                                                ),
                                                Divider(
                                                  color: Colors.grey,
                                                ),
                                                Text(
                                                  "수령할 시간을 선택하세요.",
                                                  style: TextStyle(
                                                    fontFamily: "NanumBarunpenR",
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    scrollDirection: Axis.horizontal,
                                                    children: [
                                                      ChoiceChip(
                                                        label: Text("11:00"),
                                                        selected: orderTime == OrderTime.one,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.one;
                                                            orderTimeText = "11시";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("11:10"),
                                                        selected: orderTime == OrderTime.two,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.two;
                                                            orderTimeText = "11시 10분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("11:20"),
                                                        selected: orderTime == OrderTime.three,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.three;
                                                            orderTimeText = "11시 20분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("11:30"),
                                                        selected: orderTime == OrderTime.fore,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.fore;
                                                            orderTimeText = "11시 30분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("11:40"),
                                                        selected: orderTime == OrderTime.five,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.five;
                                                            orderTimeText = "11시 40분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("11:50"),
                                                        selected: orderTime == OrderTime.six,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.six;
                                                            orderTimeText = "11시 50분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("12:00"),
                                                        selected: orderTime == OrderTime.seven,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.seven;
                                                            orderTimeText = "12시 00분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("12:10"),
                                                        selected: orderTime == OrderTime.eight,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.eight;
                                                            orderTimeText = "12시 10분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("12:20"),
                                                        selected: orderTime == OrderTime.nine,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.nine;
                                                            orderTimeText = "12시 20분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      ChoiceChip(
                                                        label: Text("12:30"),
                                                        selected: orderTime == OrderTime.ten,
                                                        onSelected: (b) {
                                                          setState(() {
                                                            orderTime = OrderTime.ten;
                                                            orderTimeText = "12시 30분";
                                                          });
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 10,
                                                  child: ListView.builder(
                                                      itemCount: bentoTempItems.length,
                                                      itemBuilder: (context, index) {
                                                        return CheckboxListTile(
                                                          title: Text(bentoTempItems[index].name),
                                                          onChanged: (bool value) {
                                                            // print(">>> value : $value");
                                                            bentoTempItems[index].isCheck = value;
                                                            setState(() {});
                                                          },
                                                          value: bentoTempItems[index].isCheck,
                                                        );
                                                      }),
                                                ),
                                                Divider(
                                                  color: Colors.grey,
                                                ),
                                                Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text("총 인원"),
                                                            Text(
                                                                "${bentoTempItems.where((element) => element.isCheck == true).length}명")
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [Text("예약시간"), Text(orderTimeText)],
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      actions: [
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
                                                  'sms:01020138844&body=안녕하세요 6층 엔젤로보틱스 ${bentoTempItems.where((element) => element.isCheck == true).length}명 $orderTimeText에 도시락 받으러갈게요!';
                                              launch(url);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("아이폰")),
                                        ElevatedButton(
                                          onPressed: () async {
                                            // Fluttertoast.showToast(
                                            //     msg: "웹이에요");
                                            String url =
                                                'sms:01020138844?body=안녕하세요 6층 엔젤로보틱스 ${bentoTempItems.where((element) => element.isCheck == true).length}명 $orderTimeText에 도시락 받으러갈게요!';
                                            launch(url);
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("안드로이드"),
                                        )
                                      ],
                                    );
                                  });
                            } else {
                              showDialog(
                                context: _drawerKey.currentContext,
                                builder: (context) => AlertDialog(
                                  content: Text(
                                    "현재 도시락 파티에 참가한 참가자가 없습니다.",
                                    style: TextStyle(
                                      fontFamily: "NanumBarunpenR",
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("확인"))
                                  ],
                                ),
                              );
                            }
                          },
                          color: Colors.black,
                          minWidth: double.infinity,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "도시락 예약",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "NanumBarunpenR",
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 48),
                ],
              ),
            ),
          ),
          bottomNavigationBar: isWeekend || isClosed ? null : buildBottomAppBar(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: isWeekend || isClosed ? null : buildFABButton(),
        ),
        drawerItems: buildDrawerMenuWidgets(),
        controller: _controller,
      ),
    );
  }

  bool checkDuplicatedUser(List<mUser.User> leftUserItems) {
    List<mUser.User> tmp = [];
    for (int i = 0; i < enterUserList.length; i++) {
      for (int j = 0; j < leftUserItems.length; j++) {
        if (enterUserList[i].name == leftUserItems[j].name) {
          tmp.add(enterUserList[i]);
        }
      }
    }
    if (tmp.length > 0) return true;
    return false;
  }

  Future onRegistrationUser(List<mUser.User> leftUserItems) async {
    bool isBento = false;
    bool isCancel = false;
    bool isOrder = false;
    List<mUser.User> checkUserList = leftUserItems.where((element) => element.isCheck == true).toList();
    if (checkUserList.length > 0) {
      bentoUserLength = checkUserList.length;
      await showDialog(
          context: _drawerKey.currentContext,
          builder: (context) => WillPopScope(
                onWillPop: () async {
                  return false;
                },
                child: AlertDialog(
                  title: Text("안내"),
                  content: Text("혹시 도시락 주문하세요?"),
                  actions: [
                    ButtonBar(
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              isCancel = true;
                              isBento = false;
                              Navigator.of(context).pop();
                              return;
                            },
                            child: Text("취소하기")),
                        ElevatedButton(
                            onPressed: () async {
                              isBento = true;
                              Navigator.of(context).pop();
                            },
                            child: Text("네 (도시락)")),
                        ElevatedButton(
                          onPressed: () async {
                            isBento = false;
                            Navigator.of(context).pop();
                          },
                          child: Text("아니요 (일반)"),
                        )
                      ],
                    ),
                  ],
                ),
              ));
      if (isCancel) {
        Navigator.of(context).pop();
        return;
      }
      if (isBento) {
        //TODO: 도시락인 사람에 대해서 처리하기
        await showDialog(
            context: _drawerKey.currentContext,
            builder: (context) => WillPopScope(
                  onWillPop: () async {
                    return false;
                  },
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
                                String url = 'tel:01020138844';
                                launch(url);
                                Navigator.of(context).pop();
                              },
                              child: Text("전화로하기")),
                          ElevatedButton(
                            onPressed: () async {
                              String url =
                                  'sms:01020138844?body=안녕하세요 6층 엔젤로보틱스 $bentoUserLength명 $bentoTime에 도시락 받으러갈게요!';
                              launch(url);
                              Navigator.of(context).pop();
                            },
                            child: Text("안드로이드"),
                          ),
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
                                Navigator.of(_drawerKey.currentContext).pop();
                                isOrder = true;
                              },
                              child: Text("괜찮아(나중에)")),
                        ],
                      );
                    },
                  ),
                ));

        //TODO: 도시락 주문을 지금하지 않은  경우

        if (isOrder) {
          for (int i = 0; i < checkUserList.length; i++) {
            checkUserList[i].part = "도시락";
          }
          // checkDuplicatedUser(checkUserList);
          await refreshEnterUserList();
          //ToDO: 이부분이 중복을 발생시키지 않을까?
          checkUserList.addAll(enterUserList);
          List<String> nameList = [];
          List<String> orderNameList = [];
          checkUserList.forEach((u) {
            //TODO 도시락이랑 일반이랑 구분하기 위함.
            nameList.add("${u.name},${u.part}");
          });
          await firestore.collection("lunch").doc(currentDate).update(data: {"users": nameList});

          setState(() {
            enterUserList.clear();
          });
          await refreshEnterUserList();
          Navigator.of(_drawerKey.currentContext).pop();
          Fluttertoast.showToast(msg: "신청이 완료되었어요.", webPosition: "center");
          return;
        } else {
          await showDialog(
              context: _drawerKey.currentContext,
              builder: (context) => WillPopScope(
                    onWillPop: () async {
                      return false;
                    },
                    child: AlertDialog(
                      title: Text("안내"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("마지막으로 확인하나만 할게요!"),
                          Text("주문에 대한 확정이 필요해요"),
                          Text("문자나 전화로 예약을 완료했나요?"),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: Text("아니요")),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            //TODO enterUserList는 기존에 방에 들어가있는 사람의 목록이다.
                            //TODO 도시락인 경우 도시락 사람만 도시락으로 쓰기
                            for (int i = 0; i < checkUserList.length; i++) {
                              checkUserList[i].part = "도시락";
                            }
                            // checkDuplicatedUser(checkUserList);
                            await refreshEnterUserList();
                            //ToDO: 이부분이 중복을 발생시키지 않을까?
                            List<mUser.User> orderUserList = [];
                            orderUserList.addAll(checkUserList);
                            checkUserList.addAll(enterUserList);
                            List<String> nameList = [];
                            List<String> orderNameList = [];
                            checkUserList.forEach((u) {
                              //TODO 도시락이랑 일반이랑 구분하기 위함.
                              nameList.add("${u.name},${u.part}");
                              // print(u.name.split(',').length);
                              // print(" ${u.name.split(',').first}  /  ${u.name.split(',').last}");
                              // nameList.add("${u.name}");
                            });
                            // print(checkUserList.length);
                            await firestore.collection("lunch").doc(currentDate).update(data: {"users": nameList});

                            orderUserList.forEach((element) {
                              orderNameList.add("${element.name},${element.part},${element.team}");
                            });
                            await firestore
                                .collection("lunch")
                                .doc(currentDate)
                                .collection("order")
                                .add({"datetime": DateTime.now(), "users": orderNameList});

                            setState(() {
                              enterUserList.clear();
                            });
                            await refreshEnterUserList();
                            Navigator.of(_drawerKey.currentContext).pop();
                            Fluttertoast.showToast(msg: "신청이 완료되었어요.", webPosition: "center");
                          },
                          child: Text("네"),
                        )
                      ],
                    ),
                  ));
        }
      } else {
        //TODO: 도시락이 아닌 일반 신청 사용자인 경우

        List<String> nameList = [];
        for (int i = 0; i < checkUserList.length; i++) {
          checkUserList[i].part = "일반";
        }
        checkUserList.addAll(enterUserList);
        checkUserList.forEach((u) {
          //TODO 도시락이랑 일반이랑 구분하기 위함.
          nameList.add("${u.name},${u.part}");
          // print(u.name.split(',').length);
          // print(" ${u.name.split(',').first}  /  ${u.name.split(',').last}");
          // nameList.add("${u.name}");
        });
        // print(checkUserList.length);
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

  Widget buildFABButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isWeekend) {
          return;
        }
        if (isClosed) {
          showDialog(
              context: _drawerKey.currentContext,
              builder: (context) => AlertDialog(
                    title: Text("안내"),
                    content: Text(
                      "이미 종료된 방입니다.",
                      style: TextStyle(
                        fontFamily: "NanumBarunpenR",
                      ),
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
          // print("Not exist");
          showDialog(
              context: _drawerKey.currentContext,
              builder: (context) => AlertDialog(
                    content: Text(
                      "생성된 방이 없습니다.",
                      style: TextStyle(
                        fontFamily: "NanumBarunpenR",
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("확인")),
                      ElevatedButton(
                          onPressed: () async {
                            // DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
                            await firestore.collection("lunch").doc(currentDate).set({
                              "users": [],
                              "isClosed": false,
                              "damage": 0,
                              "quest_entered": [],
                              "pizza": 0,
                              "hamburger": 0,
                              "sushi": 0,
                              "taco": 0,
                              "broccoli": 0,
                              "hit": 0
                            });

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
    );
  }

  Widget buildBottomAppBar() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 12.0,
      child: Container(
        height: 72,
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(right: 64, left: 16, top: 8, bottom: 8),
              child: Tooltip(
                message: "마감하기",
                child: OutlinedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "마감",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "NanumBarunpenR",
                      ),
                    ),
                  ),
                  onPressed: isWeekend
                      ? () {
                          return;
                        }
                      : existRoom
                          ? () {
                              if (isClosed) {
                                //TODO: 방이 이미 닫힌경우
                                showDialog(
                                    context: _drawerKey.currentContext,
                                    builder: (context) => AlertDialog(
                                          title: Text("안내"),
                                          content: Text(
                                            "이미 종료된 방입니다.",
                                            style: TextStyle(
                                              fontFamily: "NanumBarunpenR",
                                            ),
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
                                            "마감하고 방을 닫을까요?\n한번 닫으면 다시 열수 없습니다. 주의해주세요",
                                            style: TextStyle(
                                              fontFamily: "NanumBarunpenR",
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  await onSetRoomClose(currentDate);
                                                  await onCheckRoomClosed(currentDate);
                                                  await updateTotalTicketCount(enterUserList.length);

                                                  totalTicket = await fetchTotalTicketCount();
                                                  await onUpdateUsedTicket(currentDate, totalTicket);
                                                  await onAddUsedTicketLog(
                                                      date: currentDate, left: totalTicket, used: enterUserList.length);
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
              ),
            )),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 64, right: 16),
              child: Tooltip(
                message: "참가신청",
                child: MaterialButton(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "참가신청",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "NanumBarunpenR",
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.black,
                  onPressed: isWeekend
                      ? () {
                          Fluttertoast.showToast(msg: "주말은 쉬어갑니다");
                          return;
                        }
                      : existRoom
                          ? () async {
                              if (isClosed) {
                                showDialog(
                                    context: _drawerKey.currentContext,
                                    builder: (context) => AlertDialog(
                                          title: Text("안내"),
                                          content: Text(
                                            "이미 종료된 방입니다. 다음에 다시 참여해주세요!",
                                            style: TextStyle(
                                              fontFamily: "NanumBarunpenR",
                                            ),
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
                                // print("allUserList.length: ${FirebaseInstance.instance.allUserList.length}");

                                userList.addAll(FirebaseInstance.instance.allUserList);
                                // print("userList size: ${userList.length}");
                                if (userList.length > 0) {
                                  //TODO: 전체 사용자를 복사함
                                  List<mUser.User> leftUserItems = userList;
                                  // print("enterUserList size: ${enterUserList.length}");
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

                                  //TODO: 참가 인원선택을 위한 BottomSheet
                                  await showModalBottomSheet(
                                      context: _drawerKey.currentContext,
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
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                                                        fontFamily: "NanumBarunpenR",
                                                      ),
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
                                                    child: TabBarView(controller: _bottomSheetTabController, children: [
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where(
                                                                                (element) => element.team == "c_level")
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
                                                                      // print(value);
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where((element) => element.team == "대외협력팀")
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where(
                                                                                (element) => element.team == "로봇연구개발팀")
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where(
                                                                                (element) => element.team == "로봇재활지원팀")
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where((element) => element.team == "생산총괄팀")
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
                                                                      // print(value);
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where((element) => element.team == "인사총무팀")
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where((element) => element.team == "재무회계팀")
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
                                                                      // print(value);
                                                                      setState(() {
                                                                        leftUserItems
                                                                            .where((element) => element.team == "홍보마케팅")
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
                                                        //TODO: 이미 신청되었는데 다시 신청하는 경우 막기 (중복검사)
                                                        //TODO: 체크된 인원 리스트 확인
                                                        //TODO: leftUserItems는 신청되지 않은 남은 사용자
                                                        List<mUser.User> checkUserList = leftUserItems
                                                            .where((element) => element.isCheck == true)
                                                            .toList();
                                                        //TODO: enter된 인원 리스트 확인
                                                        //TODO: enter된 리스트에 체크된 인원이 있다면 리턴.
                                                        List<mUser.User> tmp = [];
                                                        for (int i = 0; i < enterUserList.length; i++) {
                                                          for (int j = 0; j < checkUserList.length; j++) {
                                                            if (enterUserList[i].name == checkUserList[j].name) {
                                                              tmp.add(enterUserList[i]);
                                                            }
                                                          }
                                                        }
                                                        //TODO: 실시간으로 등록된 사람 이 있는지 확인하기 & 등록하기
                                                        // print(tmp.length);
                                                        if (tmp.length > 0) {
                                                          showDialog(
                                                              context: _drawerKey.currentContext,
                                                              builder: (context) {
                                                                return AlertDialog(
                                                                  title: Text("오류"),
                                                                  content: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      Text("신청하는 사이에 참가한 인원이 있어요!"),
                                                                      Text("확인 후 다시 시도해주세요."),
                                                                      ...tmp
                                                                          .map((e) => ListTile(
                                                                                title: Text(e.name),
                                                                              ))
                                                                          .toList()
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                        onPressed: () {
                                                                          Navigator.of(context).pop();
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        child: Text("확인"))
                                                                  ],
                                                                );
                                                              });
                                                          return;
                                                        } else {
                                                          //TODO: 중복이 없다면? 등록하기
                                                          await onRegistrationUser(leftUserItems);
                                                        }
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
    );
  }

  Widget buildWeekendWidget() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/pixeltrue-sleeping.png",
            width: MediaQuery.of(context).size.width / 1.5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "주말은 쉬어요",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "NanumBarunpenR",
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
        ],
      ),
    );
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
                fontFamily: "NanumBarunpenR",
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Tooltip(
            message: "참가인원보기",
            child: MaterialButton(
              onPressed: () {
                // print(enterUserList);
                showDialog(
                    context: _drawerKey.currentContext,
                    builder: (context) => AlertDialog(
                          contentPadding: EdgeInsets.all(12),
                          title: Text("참가인원(${enterUserList.length}명)"),
                          content: Builder(
                            builder: (BuildContext context) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height / 2,
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/img/shield_1f6e1-fe0f.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      Text(
                                                        "도시락 파티",
                                                        style: TextStyle(
                                                          fontFamily: "NanumBarunpenR",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: LinearPercentIndicator(
                                                          lineHeight: 6.0,
                                                          percent: enterUserList.length > 0
                                                              ? (enterUserList
                                                                      .where((element) => element.part == "도시락")
                                                                      .toList()
                                                                      .length /
                                                                  enterUserList.length)
                                                              : 0.0,
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
                                                Expanded(
                                                    child: Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        "assets/img/crossed-swords_2694-fe0f.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      Text(
                                                        "일반 파티",
                                                        style: TextStyle(
                                                          fontFamily: "NanumBarunpenR",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: LinearPercentIndicator(
                                                          lineHeight: 6.0,
                                                          percent: enterUserList.length > 0
                                                              ? (enterUserList
                                                                      .where((element) => element.part == "일반")
                                                                      .toList()
                                                                      .length /
                                                                  enterUserList.length)
                                                              : 0.0,
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
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: enterUserList.where((element) => element.part == "도시락").length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  var normal =
                                                      enterUserList.where((element) => element.part == "도시락").toList();
                                                  return ListTile(
                                                    onTap: () {
                                                      showDialog(
                                                          context: _drawerKey.currentContext,
                                                          builder: (context) => AlertDialog(
                                                                title: Text("Don't panic"),
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Center(
                                                                      child: CircleAvatar(
                                                                        radius: MediaQuery.of(context).size.width / 2,
                                                                        backgroundImage: NetworkImage(
                                                                            "https://thispersondoesnotexist.com/image"),
                                                                        // Image.network()
                                                                      ),
                                                                    ),
                                                                    Text("StyleGAN [AI]으로 생성된 가상의 인물입니다.")
                                                                  ],
                                                                ),
                                                              ));
                                                    },
                                                    title: Text(
                                                      "${index + 1} ${normal[index].name}",
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                    trailing: Text(
                                                      "${normal[index].part}",
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                  );
                                                }),
                                          ),
                                          VerticalDivider(),
                                          Expanded(
                                            child: ListView.builder(
                                                itemCount: enterUserList.where((element) => element.part == "일반").length,
                                                shrinkWrap: true,
                                                itemBuilder: (context, index) {
                                                  var normal =
                                                      enterUserList.where((element) => element.part == "일반").toList();
                                                  return ListTile(
                                                    onTap: () {
                                                      showDialog(
                                                          context: _drawerKey.currentContext,
                                                          builder: (context) => AlertDialog(
                                                                title: Text("Don't panic"),
                                                                content: Column(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    Center(
                                                                      child: CircleAvatar(
                                                                        radius: MediaQuery.of(context).size.width / 2,
                                                                        backgroundImage: NetworkImage(
                                                                            "https://thispersondoesnotexist.com/image"),
                                                                        // Image.network()
                                                                      ),
                                                                    ),
                                                                    Text("StyleGAN [AI]으로 생성된 가상의 인물입니다.")
                                                                  ],
                                                                ),
                                                              ));
                                                    },
                                                    title: Text(
                                                      "${index + 1} ${normal[index].name}",
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                    trailing: Text(
                                                      "${normal[index].part}",
                                                      style: TextStyle(fontSize: 10),
                                                    ),
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                      // child:
                                      // ListView.builder(
                                      //     itemCount: enterUserList.length,
                                      //     shrinkWrap: true,
                                      //     itemBuilder: (context, index) {
                                      //
                                      //       return ListTile(
                                      //         leading: Text("$index"),
                                      //         title: Text("${enterUserList[index].name}"),
                                      //         trailing: Text("${enterUserList[index].part}"),
                                      //       );
                                      //     }),
                                    ),
                                  ],
                                ),
                              );
                            },
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: "NanumBarunpenR",
                  ),
                ),
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
          Text(
            msg,
            style: TextStyle(
              fontSize: 18,
              fontFamily: "NanumBarunpenR",
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildDrawerMenuWidgets() {
    return [
      GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed("/admin/login");
        },
        child: Image.asset(
          "assets/img/animation_640_kkkzx3os.gif",
          width: MediaQuery.of(context).size.width / 2.5,
          fit: BoxFit.fitWidth,
        ),
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
            "정보",
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
