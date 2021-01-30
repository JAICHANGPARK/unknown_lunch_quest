import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'src/remote/api.dart';
import 'src/ui/home_page.dart';
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


