import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'src/remote/api.dart';
import 'src/utils/character_style.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final firebase = FirebaseInstance.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(">>> Called MyApp");
    return MaterialApp(
      title: 'Lunch Quest',
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: MyHomePage(title: 'Lunch Quest'),
    );
  }
}

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
  StreamSubscription _streamSubscription;
  final FlareControls controls = FlareControls();


  @override
  void initState() {
    super.initState();
    _chooseHero();

    loopTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      _playSuccessAnimation();
    });
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
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
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

  void _playSuccessAnimation() {
    // Use the controls to trigger an animation.
    if (isOpen) {
      controls.play("idle");
    } else {
      controls.play("working");
    }
    setState(() {
      isOpen = !isOpen;
    });
  }
}
