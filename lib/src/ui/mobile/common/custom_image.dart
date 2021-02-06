import 'dart:html';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CustomImage extends StatelessWidget {
  final String imageUrl;

  const CustomImage({Key key, this.imageUrl}) : super(key: key);

  Widget build(BuildContext context) {
    // ui.platformViewRegistry.registerViewFactory(
    //   imageUrl,
    //       (int viewId) => ImageElement()..src = imageUrl,
    // );
    return HtmlElementView(
      viewType: imageUrl,
    );
  }
}
