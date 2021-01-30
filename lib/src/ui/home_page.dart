import 'dart:async';

import 'package:fancy_drawer/fancy_drawer.dart';
import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_picker_timeline/flutter_date_picker_timeline.dart';
import 'package:flutter_lunch_quest/src/model/user.dart' as mUser;
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/utils/character_style.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:intl/intl.dart';

import 'about_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  CharacterStyle hero;
  bool isOpen = false;
  Timer loopTimer;
  StreamSubscription<QuerySnapshot> _streamSubscription;
  Firestore firestore = FirebaseInstance.instance.store;
  FancyDrawerController _controller;
  List<mUser.User> userList = [];
  bool isPlaying = false;
  AnimationController _animationController;
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String currentDate = DateTime.now().toString().split(" ").first;

  Future<List<mUser.User>> fetchAllUsers() async {
    List<mUser.User> dataList = [];
    var userList = [];
    var teamSnapshot = await firestore.collection("team").get();
    var teamList = teamSnapshot.docs;
    for (int i = 0; i < teamList.length; i++) {
      CollectionReference cr = teamList[i].ref.collection("users");
      print(">>> element.ref.collection(user) : ${teamList[i].ref.collection("users")}");
      print(">>> element.ref.collection(user) : ${cr.parent} / ${cr.path}");
      QuerySnapshot userQuerySnapshot = await cr.get();
      userList = userQuerySnapshot.docs;
      for (int j = 0; j < userList.length; j++) {
        print(">>> team: ${userList[j].ref.parent.parent.id}");
        // print(">>> userValue.element.id: ${element.data()}");
        print(">>> name: ${userList[j].data()["name"]}");
        dataList.add(mUser.User(name: userList[j].data()['name'], team: userList[j].ref.parent.parent.id));
      }
    }

    // userList =  userQuerySnapshot.docs.forEach((element) {
    //   // print(">>> userValue.element.id: ${element.id}");
    //   // print(">>> userValue.element.parent: ${element.ref.parent.id}");
    //
    // });

    return dataList;
  }

  @override
  void initState() {
    super.initState();
    print(">>> currentDate: $currentDate");
    _chooseHero();
    _controller = FancyDrawerController(vsync: this, duration: Duration(milliseconds: 150))
      ..addListener(() {
        // print(_controller.state);
        if (_controller.state == DrawerState.closing) {
          isPlaying = false;
        }
        setState(() {}); // Must call setState
      }); // This chunk of code is important
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
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
    _animationController.dispose();
    loopTimer?.cancel();
    _streamSubscription?.cancel();
    _controller.dispose(); // Dispose c
    super.dispose();
  }

  void _handleOnPressed() {
    setState(() {
      isPlaying = !isPlaying;
      isPlaying ? _animationController.forward() : _animationController.reverse();
    });
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FlutterDatePickerTimeline(
                          startDate: DateTime.now().add(Duration(days: -90)),
                          endDate: DateTime.now().add(Duration(days: 1)),
                          initialSelectedDate: DateTime.now(),
                          onSelectedDateChange: (DateTime dateTime) {
                            print(dateTime);
                            setState(() {
                              currentDate = DateFormat("yyyy-MM-dd").format(dateTime);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2,
                    child: Card(
                      child: userList.length > 0
                          ? ListView.separated(
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount: userList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(userList[index].name),
                                  subtitle: Text(userList[index].team),
                                );
                              })
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),

                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    'You have pushed the button this many times:',
                  ),
                  Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  // browser.browserAgent == BrowserAgent.Chrome
                  //     ? SizedBox(
                  //         width: 480,
                  //         height: 480,
                  //         child: FlareActor(
                  //           "assets/flare/UXResearcher.flr",
                  //           alignment: Alignment.center,
                  //           shouldClip: false,
                  //           fit: BoxFit.contain,
                  //           animation: isOpen ? "working" : "success",
                  //           controller: controls,
                  //         ),
                  //       )
                  //     :
                  // SizedBox(
                  //   height: 360,
                  //   width: 360,
                  //   child: Lottie.asset(
                  //     "assets/lottie/45722-rocket-loader.json",
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              print(currentDate);
              DocumentSnapshot querySnapshot = await firestore.collection("lunch").doc(currentDate).get();
              print(querySnapshot);
              if (querySnapshot == null || !querySnapshot.exists) {
                // Document with id == docId doesn't exist.
                print("Not exist");
                showDialog(
                  context: context,
                  builder: (context)=>AlertDialog(
                    content: Text("생성된 방이 없습니다."),
                    actions: [
                      ElevatedButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: Text("확인"))
                    ],
                  )
                );
              }else{
                Fluttertoast.showToast(msg: "생성된 방이 존재합니다.",
                webPosition: "center");
              }
            },
            tooltip: 'Increment',
            child: Icon(Icons.add),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
        drawerItems: [
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
        ],
        controller: _controller,
      ),
    );
  }

  void _chooseHero() {
    setState(() {
      hero = CharacterStyle.random();
    });
  }

// void _playSuccessAnimation() {
//   // Use the controls to trigger an animation.
//   if (isOpen) {
//     controls.play("idle");
//   } else {
//     controls.play("working");
//   }
//   setState(() {
//     isOpen = !isOpen;
//   });
// }
}
