
import 'package:http/http.dart' as http;

Future<String> getIP() async {
  try {
    const url = 'https://api.ipify.org';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    } else {
      print(response.body);
      return null;
    }
  } catch (exception) {
    print(exception);
    return null;
  }
}