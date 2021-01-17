import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'screens/widgetScreens/video_screen.dart';
import 'widget_depot_view_model.dart';

class WidgetDepotView extends StatelessWidget {
  static const String id = 'widget_depot_screen';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WidgetDepotViewModel>.reactive(
      viewModelBuilder: () => WidgetDepotViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('Widget Depot'),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text('Video View'),
              onTap: (){
                Navigator.of(context).pushNamed(VideoScreen.id);
              },
            )
          ],
        ),
      ),
    );
  }
}
