import 'package:flutter/material.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

class BattlePage extends StatefulWidget {
  @override
  _BattlePageState createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  int totalHP = 1000;
  int damage = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quest"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${totalHP - damage}/${totalHP}"),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 1.2,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/img/animation_640_kksar3b6.gif",
                      fit: BoxFit.cover,
                    ),
                  )),

                  PimpedButton(
                    particle: DemoParticle(),
                    pimpedWidgetBuilder: (context, controller) {
                      return InkWell(
                        onTap: (){
                          controller.forward(from: 0.0);
                        },

                      );
                    },
                  ),

              ],
            ),
          ),
          
        ],
      ),
    );
  }
}
