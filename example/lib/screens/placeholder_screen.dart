import 'package:flutter/material.dart';
import 'file:///H:/Mullr/Mobile%20Apps/Flutter%20Apps/widget_depot/example/lib/widget_depot_view.dart';

class PlaceholderScreen extends StatelessWidget {
  static const String id = 'placeholder_screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('Placeholder'),
              RaisedButton(
                  child: Text('Widget Depot'),
                  onPressed: () {
                    Navigator.of(context).pushNamed(WidgetDepotView.id);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
