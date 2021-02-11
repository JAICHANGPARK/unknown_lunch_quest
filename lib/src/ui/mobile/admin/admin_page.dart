import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("관리자" ,style: TextStyle(
          fontFamily: "NanumBarunpenR",
        ),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Divider(),
            ListTile(
              onTap: (){
                TextEditingController tmp = TextEditingController();
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("식권 수정하기",style: TextStyle(
                        fontFamily: "NanumBarunpenR",
                      ),),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("식권을 추가 구매했을 때 사용해주세요.",style: TextStyle(
                            fontFamily: "NanumBarunpenR",
                          ),),
                          TextField(
                            controller: tmp,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () async {
                            if (tmp.text.length > 0) {
                              int v = int.parse(tmp.text);
                              // await onSetTotalTicketCount(v);
                              // totalTicket = await fetchTotalTicketCount();
                              // Fluttertoast.showToast(msg: "처리 완료");
                              setState(() {});

                              Navigator.of(context).pop();
                            } else {
                              Fluttertoast.showToast(msg: "추가할 식권수를 입력해주세요");
                            }
                          },
                          child: Text("추가하기"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("확인"),
                        ),
                      ],
                    ));
              },
              title: Text("식권 수정" ,style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),
            ListTile(
              onTap: (){
                Navigator.of(context).pushNamed( "/admin/home/pwd_change");
              },
              title: Text("비밀번호 변경" ,style: TextStyle(
                fontFamily: "NanumBarunpenR",
              ),),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
