import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/ui/mobile/about_page.dart';
import 'package:flutter_lunch_quest/src/ui/mobile/record/mobile_record_page.dart';
import 'package:flutter_lunch_quest/src/ui/wide_screen/wide_home_page.dart';

import 'package:responsive_builder/responsive_builder.dart';
import 'src/remote/api.dart';
import 'src/ui/mobile/black_market/bit_coin_page.dart';
import 'src/ui/mobile/bulletin_board_page.dart';
import 'src/ui/mobile/contact_page.dart';
import 'src/ui/mobile/home_page.dart';
import 'src/ui/mobile/quest/battle_page.dart';
import 'src/ui/mobile/record/mobile_record_print_page.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Lunch Quest',
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      initialRoute: "/",
      routes: {
        "/": (context) => ResponsiveBuilder(
              // Use the widget
              builder: (context, sizingInformation) {
                // Check the sizing information here and return your UI
                if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
                  return WideHomePage();
                  // return Scaffold(
                  //   body: Column(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     crossAxisAlignment: CrossAxisAlignment.center,
                  //     children: [
                  //       Image.asset(
                  //         "assets/img/casual-life-3d-meditation-crystal-1.png",
                  //         width: MediaQuery.of(context).size.width / 2,
                  //       ),
                  //       Text("개발중.."),
                  //     ],
                  //   ),
                  // );
                }

                if (sizingInformation.deviceScreenType == DeviceScreenType.watch) {
                  return Container(color: Colors.yellow);
                }

                // if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
                //   return Container(color: Colors.red);
                // }

                return MyHomePage(title: 'Lunch Quest');
              },
            ),
        "/about": (context) => AboutPage(),
        "/about/black_market": (context) => BitCoinPage(),
        "/contact": (context) => ContactPage(),
        "/bulletin_board": (context) => BulletinBoardPage(),
        "/data/record": (context) => MobileRecordPage(),
        "/quest/battle/monster": (context) => BattlePage(),

      },
    );
    // MyHomePage(title: 'Lunch Quest'),
  }
}
