import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/coingeko.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class CoinDetailPage extends StatefulWidget {
  final Coingeko coingeko;

  CoinDetailPage({this.coingeko});

  @override
  _CoinDetailPageState createState() => _CoinDetailPageState();
}

class _CoinDetailPageState extends State<CoinDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coingeko.id),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.coingeko.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "US\$ ${widget.coingeko.currentPrice}",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 32,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 3,
                child: Sparkline(
                  data: widget.coingeko.sparklineIn7d.price,
                ),
              ),
              ListTile(
                title: Text("Rank"),
                trailing: Text(widget.coingeko.marketCapRank.toString()),
              ),
              ListTile(
                title: Text("Market Cap"),
                trailing: Text("US\$ ${widget.coingeko.marketCap.toString()}"),
              ),
              ListTile(
                title: Text("Total Volume"),
                trailing: Text("${widget.coingeko.totalVolume.toString()}"),
              ),
              ListTile(
                title: Text("Total Supply"),
                trailing: Text("${widget.coingeko.totalSupply.toString()}"),
              ),
              Divider(),
              ListTile(
                title: Text("24h 최대 "),
                trailing: Text(widget.coingeko.high24h.toString()),
              ),
              ListTile(
                title: Text("24h 최소"),
                trailing: Text(widget.coingeko.low24h.toString()),
              ),
              ListTile(
                title: Text("24h"),
                trailing: Text(widget.coingeko.priceChange24h.toString()),
              ),
              ListTile(
                title: Text("24h %"),
                trailing: Text(widget.coingeko.priceChangePercentage24h.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
