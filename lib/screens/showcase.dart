import 'package:flutter/material.dart';

// A screen to showcase a single widget
class Showcase extends StatelessWidget {
  final String name;
  final Widget widget;

  const Showcase(this.widget, this.name, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Container(
            width: 300,
            height: 300,
            child: widget),
      ),
    );
  }
}
