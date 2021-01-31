import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/ui/common/web_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  AnimationController _animationController;

  int counter = 0;

  Animation<double> _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 1.0, end: 1.3).animate(_animationController);
  }
  TextEditingController textEditingController = TextEditingController();
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
                      onTap: () async {
                        counter++;
                        if (counter == 2) {
                          Fluttertoast.showToast(msg: "Knock Knock", webPosition: "center");
                        }
                        if (counter == 3) {
                          Fluttertoast.showToast(msg: "???", webPosition: "center");
                        }
                        if (counter == 5) {
                          Fluttertoast.showToast(msg: "????!!!!", webPosition: "center");
                        }

                        if (counter == 7) {
                          _animationController.forward();
                          Fluttertoast.showToast(msg: "Wait", webPosition: "center");
                        }

                        if (counter == 10) {
                          _animationController.reverse();
                          Fluttertoast.showToast(msg: "Who are you?", webPosition: "center", timeInSecForIosWeb: 2);
                        }
                        if (counter == 12) {
                          await showDialog(
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                  child: AlertDialog(
                                    title: Text("I am"),
                                    content: TextField(
                                      controller: textEditingController,
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            counter = 1;
                                            return;
                                          },
                                          child: Text("Sorry")),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            counter = 0;
                                            return;
                                          },
                                          child: Text("Enter"))
                                    ],
                                  ),
                                );
                              },
                              context: context);


                          if(counter == 0){
                            _animationController.forward();
                            await Future.delayed(Duration(milliseconds: 500));
                            Fluttertoast.showToast(msg: "Welcome Black Market", webPosition: "center",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 3);
                            Fluttertoast.showToast(msg: "${textEditingController.text}, I waited for you to come here.", webPosition: "center",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 3);
                            textEditingController.clear();
                            await Navigator.of(context).pushNamed("/about/black_market");
                            _animationController.reverse();
                          }

                        }
                      },
                      child: ScaleTransition(scale: _animation, child: Image.asset("assets/img/the_last_supper.jpg"))),
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
                  ),
                  Divider(
                    height: 8,
                  ),
                  ListTile(
                    title: Text("라이선스"),
                    subtitle: Text("오픈소스 라이선스"),
                    onTap: () {
                      showLicensePage(context: context);
                    },
                  )
                ],
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textEditingController.clear();
    textEditingController.dispose();
    if (_animationController != null) {
      _animationController.stop();
      _animationController.dispose();
    }

    super.dispose();
  }
}
