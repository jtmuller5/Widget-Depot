import 'package:example/screens/widgetScreens/object_detector_screen.dart';
import 'package:example/screens/widgetScreens/video_frame_screen.dart';
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
            ),
            ListTile(
              title: Text('Video Frame Selector'),
              onTap: (){
                Navigator.of(context).pushNamed(VideoFrameScreen.id);
              },
            ),
            ListTile(
              title: Text('Object Detector'),
              onTap: (){
                Navigator.of(context).pushNamed(ObjectDetectorScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
