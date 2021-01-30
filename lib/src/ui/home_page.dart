import 'dart:async';

import 'package:firebase/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/user.dart' as mUser;
import 'package:flutter_lunch_quest/src/remote/api.dart';
import 'package:flutter_lunch_quest/src/utils/character_style.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  CharacterStyle hero;
  bool isOpen = false;
  Timer loopTimer;
  StreamSubscription<QuerySnapshot> _streamSubscription;
  Firestore firestore = FirebaseInstance.instance.store;

  List<mUser.User> userList = [];

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
    _chooseHero();
    fetchAllUsers().then((value) {
      print(userList);
      setState(() {
        userList = value;
      });
    });

    // _streamSubscription = firestore.collection("team").onSnapshot.listen((event) {
    //   event.docs.forEach((element) {
    //     print(">>> element.id: ${element.id}");
    //     print(">>> element.ref.id : ${element.ref.id}");
    //     print(">>> element.ref.data : ${element.data()}");
    //     CollectionReference cr = element.ref.collection("users");
    //     print(">>> element.ref.collection(user) : ${element.ref.collection("users")}");
    //     print(">>> element.ref.collection(user) : ${cr.parent} / ${cr.path}");
    //     cr.onSnapshot.listen((userValue) {
    //       print(userValue.toString());
    //       userValue.docs.forEach((element) {
    //         print(">>> element.id: ${element.id}");
    //         print(">>> element.parent: ${element.ref.parent.id}");
    //         print(">>> element.parent parent: ${element.ref.parent.parent.id}");
    //         print(">>> element.id: ${element.data()}");
    //       });
    //     });
    //   });
    // });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    loopTimer?.cancel();
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width / 2,
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
        onPressed: () {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
