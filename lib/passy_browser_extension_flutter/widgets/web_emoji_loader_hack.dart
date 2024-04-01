import 'package:flutter/material.dart';

class WebEmojiLoaderHack extends StatelessWidget {
  const WebEmojiLoaderHack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Offstage(
      // Insert invisible emoji in order to load the emoji font in CanvasKit
      // on startup.
      child: Text('✨'),
    );
  }
}
