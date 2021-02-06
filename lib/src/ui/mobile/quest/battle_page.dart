import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/db/pref_api.dart';
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/routes/arg_quest_date.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'dart:html' as html;

import 'package:shared_preferences/shared_preferences.dart';

class BattlePage extends StatefulWidget {
  //
  // final ArgumentQuestDate args;
  // Map arguments;
  // BattlePage({Key key,this.arguments}) : super(key: key);

  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int totalHP = 2000;
  int damage = 0;
  StreamSubscription _streamSubscription;
  StreamSubscription _windowStreamSubscription;
  StreamSubscription _windowStreamSubscription1;
  StreamSubscription _windowStreamSubscription2;

  List<DateTime> questEnteredUsers = [];
  int _tabCounter = 0;
  bool isQuestClear = false;

  ConfettiController _controllerCenter;
  DateTime userDateTimeId = DateTime.now();
  String backupDate;
  String inputDate;

  Future updateEnterUser(List<DateTime> items) async {
    await FirebaseInstance.instance.fireStore.collection("lunch").doc(inputDate).update(
      data: {"quest_entered": items},
    );
  }

  Future fetchCurrentEnteredUser() async {
    DocumentSnapshot snapshot = await FirebaseInstance.instance.fireStore.collection('lunch').doc(inputDate).get();
    List<DateTime> items = List.from(snapshot.get("quest_entered"));
    items.add(userDateTimeId);
    return items;
  }

  Future logoutUser() async {
    questEnteredUsers.removeWhere((element) => element == userDateTimeId);
    FirebaseInstance.instance.fireStore.collection("lunch").doc(inputDate).update(
      data: {"quest_entered": questEnteredUsers},
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    logoutUser();
    if (_windowStreamSubscription != null) _windowStreamSubscription.cancel();
    if (_windowStreamSubscription1 != null) _windowStreamSubscription1.cancel();
    if (_windowStreamSubscription2 != null) _windowStreamSubscription2.cancel();
    if (_streamSubscription != null) _streamSubscription.cancel();
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    backupDate = inputDate;
    super.didChangeDependencies();
    print(">>>didChangeDependencies");
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    print("inintState");
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 7));
    // print(">>> widget.date: ${widget.date}");
    // print(DateTime.now().toString());
    //TODO: 아이폰 사파리에서 기본적으로 pagehide가 먹히질 않아 이벤트를 생성해서 만들어주었음.
    //TODO: 참고 https://developer.apple.com/library/archive/documentation/AppleApplications/Reference/SafariWebContent/HandlingEvents/HandlingEvents.html#//apple_ref/doc/uid/TP40006511-SW5
    // html.window.addEventListener("pagehide", (event) {
    //   print("event: onPageHide");
    //   logoutUser();
    //   if (_windowStreamSubscription != null) _windowStreamSubscription.cancel();
    //   if (_windowStreamSubscription1 != null) _windowStreamSubscription1.cancel();
    //   if (_windowStreamSubscription2 != null) _windowStreamSubscription2.cancel();
    //   if (_streamSubscription != null) _streamSubscription.cancel();
    //   // _controllerCenter.dispose();
    // });

    _windowStreamSubscription1 = html.window.onPageHide.listen((event) {
      print("event: onPageHide");
      // Fluttertoast.showToast(msg: "event: onPageHide");
      logoutUser();
      if (_windowStreamSubscription != null) _windowStreamSubscription.cancel();
      if (_windowStreamSubscription1 != null) _windowStreamSubscription1.cancel();
      if (_windowStreamSubscription2 != null) _windowStreamSubscription2.cancel();
      if (_streamSubscription != null) _streamSubscription.cancel();
      if (_controllerCenter != null) _controllerCenter.dispose();
    });

    // html.window.location.reload();
    // TODo: 화면중에 새로고침했을떄
    // _windowStreamSubscription2 = html.window.onBeforeUnload.listen((event) {
    //   // print(event.);
    //
    //   print("event: onBeforeUnload");
    //   // Fluttertoast.showToast(msg: "event: onBeforeUnload");
    //   logoutUser();
    //   if (_windowStreamSubscription != null) _windowStreamSubscription.cancel();
    //   if (_windowStreamSubscription1 != null) _windowStreamSubscription1.cancel();
    //   if (_windowStreamSubscription2 != null) _windowStreamSubscription2.cancel();
    //   if (_streamSubscription != null) _streamSubscription.cancel();
    //   _controllerCenter.dispose();
    // });
    // _windowStreamSubscription = html.window.onUnload.listen((event) {
    //   print("event: onUnload");
    //   // logoutUser();
    //   // Fluttertoast.showToast(msg: "event: onUnload");
    //   if (_windowStreamSubscription != null) _windowStreamSubscription.cancel();
    //   if (_windowStreamSubscription1 != null) _windowStreamSubscription1.cancel();
    //   if (_windowStreamSubscription2 != null) _windowStreamSubscription2.cancel();
    //   if (_streamSubscription != null) _streamSubscription.cancel();
    //   // _controllerCenter.dispose();
    // });

    Future.delayed(Duration.zero, () async {
      inputDate = await readDateCounter();

      fetchCurrentEnteredUser().then((value) => updateEnterUser(value));
      _streamSubscription =
          FirebaseInstance.instance.fireStore.collection('lunch').doc(inputDate).onSnapshot.listen((documentReference) {
        // print(">>> documentReference.get : ${documentReference.get("quest_entered")}");
        if (questEnteredUsers.length > 0) questEnteredUsers.clear();
        questEnteredUsers = List.from(documentReference.get("quest_entered"));
        damage = documentReference.get("damage");
        // print(damage);
        if (damage >= totalHP) {
          isQuestClear = true;
          _controllerCenter.play();
        }
        setState(() {});
      });
    });

    // ref.onSnapshot.listen((querySnapshot) {
    //   querySnapshot.docChanges().forEach((change) {
    //
    //   });
    // });
  }

  void castVote(int hit) {
    _tabCounter++;
    final ref = FirebaseInstance.instance.fireStore.doc('lunch/${inputDate}');
    // print(ref.id);
    ref.get().then((snapshot) {
      if (snapshot.exists) {
        // final data = snapshot.data();
        // final count = data['damage'] as num;
        ref.update(data: {'damage': damage + hit});
      } else {
        print('damage doesnt exist');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("assets/img/animation_300_kkt435kx.gif"), context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Lunch Monster"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isQuestClear
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _controllerCenter,
                      blastDirectionality: BlastDirectionality.explosive, // don't specify a direction, blast randomly
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
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Image.asset("assets/img/urban-line-success.png"),
                    ),
                  ),
                  Text(
                    "퀘스트 완료",
                    style: TextStyle(fontFamily: "MaruBuri", fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: Colors.black,
                    height: 48,
                    minWidth: MediaQuery.of(context).size.width / 1.2,
                    child: Text(
                      "나가기",
                      style: TextStyle(color: Colors.white, fontFamily: "MaruBuri"),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //     width: MediaQuery.of(context).size.width,
                  //     child: LinearProgressIndicator(
                  //       minHeight: 16,
                  //     )),
                  Text("몬스터에게 음식을 먹이세요"),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: LinearPercentIndicator(
                      center: Text(
                        "${(totalHP - damage)}/$totalHP",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24),
                      ),
                      lineHeight: 32.0,
                      percent: ((totalHP - damage) / totalHP),
                      progressColor: Colors.red,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width / 1.4,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          top: 0,
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                "assets/img/animation_300_kkt435kx.gif",
                              ),
                            ),
                          ),
                        ),
                        PimpedButton(
                          particle: DemoParticle(),
                          pimpedWidgetBuilder: (context, controller) {
                            return InkWell(
                              onTap: () {
                                controller.forward(from: 0.0);
                                castVote(1);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  SizedBox(
                    height: 72,
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Card(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            "현재 참가인원",
                            style: TextStyle(fontFamily: "MaruBuri"),
                          ),
                          Spacer(),
                          Text(
                            "${questEnteredUsers.length}명",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "MaruBuri"),
                          ),
                        ],
                      ),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        PimpedButton(
                          particle: DemoParticle(),
                          pimpedWidgetBuilder: (context, controller) {
                            return InkWell(
                              onTap: () {
                                castVote(2);
                                controller.forward(from: 0.0);
                              },
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset("assets/img/pizza_1f355.png"),
                                ),
                              ),
                            );
                          },
                        ),
                        PimpedButton(
                          particle: DemoParticle(),
                          pimpedWidgetBuilder: (context, controller) {
                            return InkWell(
                              onTap: () {
                                castVote(3);
                                controller.forward(from: 0.0);
                              },
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset("assets/img/hamburger_1f354.png"),
                                ),
                              ),
                            );
                          },
                        ),
                        PimpedButton(
                          particle: DemoParticle(),
                          pimpedWidgetBuilder: (context, controller) {
                            return InkWell(
                              onTap: () {
                                castVote(2);
                                controller.forward(from: 0.0);
                              },
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset("assets/img/taco_1f32e.png"),
                                ),
                              ),
                            );
                          },
                        ),
                        PimpedButton(
                          particle: DemoParticle(),
                          pimpedWidgetBuilder: (context, controller) {
                            return InkWell(
                              onTap: () {
                                castVote(5);
                                controller.forward(from: 0.0);
                              },
                              child: CircleAvatar(
                                radius: 36,
                                backgroundColor: Colors.grey[300],
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Image.asset("assets/img/sushi_1f363.png"),
                                ),
                                // child: Text(
                                //   '4',
                                //   style: TextStyle(fontSize: 24),
                                // ),
                              ),
                            );
                          },
                        ),
                        _tabCounter > 10
                            ? PimpedButton(
                                particle: DemoParticle(),
                                pimpedWidgetBuilder: (context, controller) {
                                  return InkWell(
                                    onTap: () {
                                      castVote(20);
                                      controller.forward(from: 0.0);
                                      _tabCounter = 0;
                                    },
                                    child: CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.yellow[300],
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Image.asset("assets/img/broccoli_1f966.png"),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: Colors.black,
                    height: 48,
                    minWidth: MediaQuery.of(context).size.width / 1.2,
                    child: Text(
                      "나가기",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Spacer(),
                  // SizedBox(
                  //     width: MediaQuery.of(context).size.width,
                  //     child: LinearProgressIndicator(
                  //       minHeight: 16,
                  //     )),
                ],
              ),
      ),
    );
  }
}
