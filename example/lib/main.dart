import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinnablelistview/pinnable_listview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  PinController pinController = PinController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: PinnableListView(
              pinController: pinController,
              children: Iterable<int>.generate(5)
                  .map((i) => MyTile(
                        i: i,
                        pinController: pinController,
                      ))
                  .toList()),
        ));
  }
}

class MyTile extends StatefulWidget {
  final int i;
  final PinController pinController;

  MyTile({Key key, @required this.i, @required this.pinController})
      : super(key: key);

  MyTileState createState() => MyTileState();
}

class MyTileState extends State<MyTile> {
  String text;

  @override
  Widget build(BuildContext context) {
    text = (widget.i * 5).toString();
    return Card(
      child: GestureDetector(
        child: Container(
            height: 50.0,
            color: Colors.blue[100 + widget.i * 100],
            child: Center(child: Icon(widget.i == widget.pinController.pinned ? Icons.star : Icons.star_border))),
        onTap: () {
          widget.pinController.pin(widget.i);
        },
      ),
    );
  }
}
