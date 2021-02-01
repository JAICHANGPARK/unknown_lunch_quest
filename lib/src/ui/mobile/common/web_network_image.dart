import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebNetworkImage extends StatefulWidget {
  WebNetworkImage({this.src});

  final String src;

  @override
  _WebNetworkImageState createState() => _WebNetworkImageState();
}

class _WebNetworkImageState extends State<WebNetworkImage> {
  Uint8List _bytes;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    _bytes = (await http.get(widget.src)).bodyBytes;
    print(_bytes);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _bytes != null
        ? Image.memory(_bytes)
        : Container();
  }
}