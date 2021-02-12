import 'package:shared_preferences/shared_preferences.dart';

Future saveSelectDate(String date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // int counter = (prefs.getInt('counter') ?? 0) + 1;
  // print('saveSelectDate $date');
  await prefs.setString('select_date', date);
}

Future<String> readSelectDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // int counter = (prefs.getInt('counter') ?? 0) + 1;
  return prefs.getString('select_date');
}

Future saveDateCounter(String date) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // int counter = (prefs.getInt('counter') ?? 0) + 1;
  // print('Pressed $date times.');
  await prefs.setString('currentDate', date);
}

Future<String> readDateCounter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // int counter = (prefs.getInt('counter') ?? 0) + 1;
  return prefs.getString('currentDate');
}
