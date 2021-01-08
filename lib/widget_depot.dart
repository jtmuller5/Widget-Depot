import 'package:flutter/material.dart';

class WidgetDepot extends StatefulWidget {
  WidgetDepot({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WidgetDepotState createState() => _WidgetDepotState();
}

class _WidgetDepotState extends State<WidgetDepot> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            // Do something
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ));
  }
}