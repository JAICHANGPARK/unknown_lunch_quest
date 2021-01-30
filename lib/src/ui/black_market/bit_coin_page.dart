import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/bit_coin.dart';
import 'package:flutter_lunch_quest/src/remote/coin_api.dart';

class BitCoinPage  extends StatefulWidget {
  @override
  _BitCoinPageState createState() => _BitCoinPageState();
}

class _BitCoinPageState extends State<BitCoinPage> {
  Bitcoin bitcoin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLatestBitcoin().then((value) {
      bitcoin = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Black Market"),
      ),
      body:
      bitcoin != null ?
      ListView.separated(itemBuilder: (context, index){
        return ListTile(
          title: Text("${bitcoin.data[index].name}"),
          trailing: Text("\$${bitcoin.data[index].quote.uSD.price}"),
        );
      }, separatorBuilder: (context, index){
        return Divider();
      }, itemCount: bitcoin.data.length) : Column(
        children: [
          CircularProgressIndicator(),
          Text("기다리는중...")
        ],
      ),
    );
  }
}
