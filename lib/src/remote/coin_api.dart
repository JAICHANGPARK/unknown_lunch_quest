import 'dart:convert';

import 'package:flutter_lunch_quest/src/model/bit_coin.dart';
import 'package:flutter_lunch_quest/src/model/coingeko.dart';
import 'package:flutter_lunch_quest/src/model/exchage_rate.dart';
import 'package:flutter_lunch_quest/src/remote/coin_key.dart';
import 'package:http/http.dart' as http;

Future<Bitcoin> fetchLatestBitcoin() async {
  // print(">>> Call fetchLatestBitcoin");
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
  // print("response.statusCode : ${response.statusCode}");
  if (response.statusCode == 200) {
    // print("Success");
    Bitcoin bitcoin = Bitcoin.fromJson(jsonDecode(response.body));
    return bitcoin;
  }
}

Future<List<Coingeko>> fetchCoingecko(int limit, bool sparkline) async {
  String baseUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=${limit}&page=1&sparkline=${sparkline}";
  var response = await http.get(baseUrl);
  // print("response.statusCode : ${response.statusCode}");
  List<Coingeko> bitcoin = [];
  if (response.statusCode == 200) {
    // print("Success");
    List<dynamic> list = json.decode(response.body);
    list.forEach((element) {
      // print(element);
      Coingeko coingeko = Coingeko.fromJson(element);
      // print(coingeko.name);
      bitcoin.add(coingeko);
    });
    //
    // Coingeko bitcoin = Coingeko.fromJson(jsonDecode(response.body));
  }
  return bitcoin;
}

Future<ExchangeRate> fetchExchangeRate()async{
  String baseUrl =
      "https://api.coingecko.com/api/v3/exchange_rates";
  var response = await http.get(baseUrl);
  // print("response.statusCode : ${response.statusCode}");
  if (response.statusCode == 200) {
    ExchangeRate rate = ExchangeRate.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    return rate;
  }
}