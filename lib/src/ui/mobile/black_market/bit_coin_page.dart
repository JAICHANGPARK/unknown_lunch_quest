import 'package:flutter/material.dart';
import 'package:flutter_lunch_quest/src/model/bit_coin.dart';
import 'package:flutter_lunch_quest/src/model/coingeko.dart';
import 'package:flutter_lunch_quest/src/model/exchage_rate.dart';
import 'package:flutter_lunch_quest/src/remote/coin_api.dart';

import 'coin_detail_page.dart';

class BitCoinPage extends StatefulWidget {
  @override
  _BitCoinPageState createState() => _BitCoinPageState();
}

class _BitCoinPageState extends State<BitCoinPage> {
  List<Coingeko> bitcoin = [];
  ExchangeRate exchangeRate;
  List<Eth> ethItems = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCoingecko(30, true).then((value) {
      setState(() {
        bitcoin = value;
      });
    });

    fetchExchangeRate().then((value) {
      setState(() {
        exchangeRate = value;
        ethItems.add(exchangeRate.rates.eth);
        ethItems.add(exchangeRate.rates.usd);
        ethItems.add(exchangeRate.rates.cny);
        ethItems.add(exchangeRate.rates.hkd);
        ethItems.add(exchangeRate.rates.krw);
        ethItems.add(exchangeRate.rates.jpy);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Black Market"),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.local_atm_outlined),
                  text: "Price",
                ),

                Tab(
                  icon: Icon(Icons.monetization_on_outlined),
                  text: "ExRate",
                ),
                Tab(
                  icon: Icon(Icons.notes_rounded),
                  text: "Coin",
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TabBarView(
              children: [
                bitcoin.length > 0
                    ? Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ListView.separated(
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CoinDetailPage(
                                          coingeko: bitcoin[index],
                                        )));
                              },
                              leading: CircleAvatar(
                                child: Text(bitcoin[index].id.substring(0, 3)),
                              ),
                              title: Text("${bitcoin[index].name}"),
                              subtitle: Text("${bitcoin[index].symbol}"),
                              trailing: Text("US\$ ${bitcoin[index].currentPrice}"),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider();
                          },
                          itemCount: bitcoin.length),
                    )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [CircularProgressIndicator(), Text("기다리는중...")],
                      ),

                ethItems.length > 0  ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(itemBuilder: (context, index){
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text("${ethItems[index].unit}"),
                      ),
                      title: Text("${ethItems[index].name}"),
                      trailing: Text("${ethItems[index].unit} ${ethItems[index].value}"),
                    );
                  }, separatorBuilder: (context, index){
                    return Divider();
                  }, itemCount: ethItems.length),
                ) : Center(
                  child: Text("데이터 없음."),
                ),
                Container(
                  child: Center(
                    child: Text("Now in development"),
                  ),
                ),
              ],
            ),
          ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () async{
            if(ethItems.isNotEmpty) {
              setState(() {
                ethItems.clear();
              });
            }
            if(bitcoin.isNotEmpty) {
              setState(() {
                bitcoin.clear();
              });
            }

            fetchCoingecko(30, true).then((value) {
              setState(() {
                bitcoin = value;
              });
            });
            fetchExchangeRate().then((value) {
              setState(() {
                exchangeRate = value;
                ethItems.add(exchangeRate.rates.eth);
                ethItems.add(exchangeRate.rates.usd);
                ethItems.add(exchangeRate.rates.cny);
                ethItems.add(exchangeRate.rates.hkd);
                ethItems.add(exchangeRate.rates.krw);
                ethItems.add(exchangeRate.rates.jpy);
              });
            });

          },
          child: Icon(Icons.refresh),
        ),
      ),
    );
  }
}
