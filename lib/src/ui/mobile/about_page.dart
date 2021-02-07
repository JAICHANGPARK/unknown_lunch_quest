import 'package:flutter/material.dart';
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

                          if (counter == 0) {
                            _animationController.forward();
                            await Future.delayed(Duration(milliseconds: 500));
                            Fluttertoast.showToast(
                                msg: "Welcome Black Market",
                                webPosition: "center",
                                toastLength: Toast.LENGTH_LONG,
                                timeInSecForIosWeb: 3);
                            Fluttertoast.showToast(
                                msg: "${textEditingController.text}, I waited for you to come here.",
                                webPosition: "center",
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
                  ),
                  Divider(
                    height: 8,
                  ),
                  ListTile(
                    title: Text("Changelog"),
                    subtitle: Text("버전기록"),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("CHANGELOG"),
                                content: SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ExpansionTile(
                                          title: Text("1.0.0"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 파일럿 버전 런칭"),
                                            Text("2. ✨ 신청하기, 삭제하기, 화면 UI 구현"),
                                            Text("3. ✨ 게시판, 문의하기 추가"),
                                          ],
                                        ),
                                        ExpansionTile(
                                          title: Text("1.0.1"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 식권 변동 기능 추가"),
                                            Text("2. ✨ 식권장부 보기 추가"),
                                            Text("3. ✨ 메뉴 개선"),
                                          ],
                                        ),
                                        ExpansionTile(
                                          title: Text("1.0.2"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 도시락 주문 기능 추가"),
                                          ],
                                        ),
                                        ExpansionTile(
                                          title: Text("1.0.3"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 도시락, 일반 구분"),
                                            Text("2. ✨ 도시락 주문 번호 추가(문자, 전화하기)"),
                                            Text("3. ✨ 데스크톱 프린트 기능 추가"),
                                          ],
                                        ),
                                        ExpansionTile(
                                          title: Text("1.0.4"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 장부에 일반과 도시락이 표기되는 문제를 수정했어요"),
                                            Text("2. ✨ 방만들기 후 새로고침이 안되던 문제를 수정했어요"),
                                            Text("3. ✨ 신청하기에 인원수 표기 추가"),
                                            Text("4. ✨ 팀별 참여신청 구분 기능 추가"),
                                            Text("5. ✨ 생성되지 않은 방임에도 종료문구 수정"),
                                          ],
                                        ),
                                        ExpansionTile(
                                          title: Text("1.0.5"),
                                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("1. ✨ 프린트화면에 출력물이 보이지 않는 문제를 수정했어요."),
                                            Text("2. ✨ 참가인원 확인을 위한 인디케이터를 추가했어요."),
                                            Text("3. ✨ 참가인원을 실시간으로 변동되도록 개선했어요."),
                                            Text("4. ✨ 동시성 개선."),
                                            Text("5. ✨ 시스템 안정화"),

                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ));
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
