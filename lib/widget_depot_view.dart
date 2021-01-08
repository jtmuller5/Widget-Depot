import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:widget_depot/screens/placeholder.dart';
import 'package:widget_depot/widget_depot_view_model.dart';
import 'package:widget_depot/widgets_stacked/videoViewStacked/stacked_video_view.dart';

class WidgetDepotView extends StatelessWidget {

  static const String id = 'widget_depot_screen';

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WidgetDepotViewModel>.reactive(
      viewModelBuilder: () => WidgetDepotViewModel(),
      builder:(context, model, child) =>  Scaffold(
          appBar: AppBar(
            title: Text('Widget Depot'),
          ),
          body: Column(
            children: [
              Container(
                  height: 300,
                  width: MediaQuery.of(context).size.width,
                  child: StackedVideoView(showFull: false,)),
              RaisedButton(
                  child: Text('Next'),
                  onPressed: (){
                Navigator.of(context).pushNamed(PlaceholderScreen.id);
              })
            ],
          )

        /* ListView(
            children: [
              ListTile(
                title: Text('Video View'),
              )
            ],
          ),*/
         ),
    );
  }
}