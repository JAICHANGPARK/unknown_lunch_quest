import 'dart:convert';

import 'package:flutter_lunch_quest/src/model/bit_coin.dart';
import 'package:flutter_lunch_quest/src/remote/coin_key.dart';
import 'package:http/http.dart' as http;

Future<Bitcoin> fetchLatestBitcoin() async {
  print(">>> Call fetchLatestBitcoin");
  String baseUrl = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest?limit=50";
  var response = await http.get(
    baseUrl,
    headers: {
      "Accepts": "application/json",
      "X-CMC_PRO_API_KEY": COIN_API_KEY,
      "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      "Access-Control-Allow-Methods": "GET, HEAD"
    },
  );
  print("response.statusCode : ${response.statusCode}");
  if (response.statusCode == 200) {
    print("Success");
    Bitcoin bitcoin = Bitcoin.fromJson(jsonDecode(response.body));
    return bitcoin;
  }
}
