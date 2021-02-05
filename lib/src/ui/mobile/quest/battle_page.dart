import 'package:flutter/material.dart';

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
            child: Card(
              child: InkWell(
                onTap: (){
                  setState(() {

                    damage++;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/img/animation_640_kksar3b6.gif",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}
