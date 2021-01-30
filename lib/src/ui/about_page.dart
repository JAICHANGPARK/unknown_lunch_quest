import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/ui/common/web_network_image.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About"),
      ),
      body: Stack(
        children: [
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/img/the_last_supper.jpg"),
                  ListTile(
                    title: Text("개발"),
                    subtitle: Text("박제창(로봇연구개발팀)"),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
