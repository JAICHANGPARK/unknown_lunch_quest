import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/ui/about_page.dart';
import 'package:flutter_lunch_quest/src/ui/black_market/bit_coin_page.dart';
import 'package:flutter_lunch_quest/src/ui/bulletin_board_page.dart';
import 'package:flutter_lunch_quest/src/ui/common/web_network_image.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'src/remote/api.dart';
import 'src/ui/contact_page.dart';
import 'src/ui/home_page.dart';

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
                  return Scaffold(
                    body: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/casual-life-3d-meditation-crystal-1.png",
                          width: MediaQuery.of(context).size.width / 2,
                        ),
                        Text("개발중.."),
                      ],
                    ),
                  );
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
        "/contact" : (context) => ContactPage(),
        "/bulletin_board" : (context) => BulletinBoardPage(),
      },
    );
    // MyHomePage(title: 'Lunch Quest'),
  }
}
