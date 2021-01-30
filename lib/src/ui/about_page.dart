import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/ui/common/web_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int counter = 0;
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
                  GestureDetector(
                    onTap: (){
                      counter++;
                      if(counter == 2){
                        Fluttertoast.showToast(msg: "???", webPosition: "center");
                      }
                      if(counter == 5){
                        Fluttertoast.showToast(msg: "??????!!", webPosition: "center");
                      }
                      if(counter == 7){
                        Fluttertoast.showToast(msg: "Wait", webPosition: "center");
                      }
                      if(counter == 10){
                        Navigator.of(context).pushNamed("/about/black_market");
                        Fluttertoast.showToast(msg: "Welcome", webPosition: "center");
                        counter = 0;

                      }
                    },
                      child: Image.asset("assets/img/the_last_supper.jpg")),
                  ListTile(
                    title: Text("개발"),
                    subtitle: Text("박제창(로봇연구개발팀)"),
                  ),
                  Divider(
                    height: 8,
                  ),
                  ListTile(
                    title: Text("연락처"),
                    subtitle: Text("jaichang@angel-robotics.com"),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
