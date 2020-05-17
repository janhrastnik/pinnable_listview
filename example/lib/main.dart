import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pinnablelistview/pinnable_listview.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text("PinnableListView Examples"),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: "Example One"),
                Tab(text: "Example Two"),
                Tab(text: "Example Three")
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ExampleOne(),
              ExampleTwo(),
              ExampleThree()
            ],
          ),
        ),
      ),
    );
  }
}

class ExampleOne extends StatelessWidget {
  /*
    demonstrates how to highlight the pinned widget
   */
  final PinController pinController = PinController();

  @override
  Widget build(BuildContext context) {
    return PinnableListView(
        pinController: pinController,
        children: Iterable<int>.generate(5)
            .map((i) => MyTile(
          i: i,
          pinController: pinController,
        )).toList());
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
  /*
     create a class for your children in pinnablelistview, from where you can handle
     the state of each child
   */

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

class ExampleTwo extends StatelessWidget {
  /*
    an example that uses a larger list, with differing widget sizes
   */
  final PinController pinController = PinController();

  getRandomNum() {
    return Random.secure().nextInt(50);
  }

  @override
  Widget build(BuildContext context) {
    return PinnableListView(
      pinController: pinController,
      children: Iterable.generate(100).map((i) {
        double height = 50.0 + getRandomNum();
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black
            )
          ),
          height: height,
          child: Center(
            child: ListTile(
              leading: FlatButton(
                color: Colors.blue,
                child: Text("pin/unpin"),
                onPressed: () {
                  pinController.pin(i);
                },
              ),
              title: Text(i.toString()),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ExampleThree extends StatelessWidget {
  /*
    an example that uses the initially pinned property
   */
  final PinController pinController = PinController();

  getRandomNum() {
    return Random.secure().nextInt(50);
  }

  @override
  Widget build(BuildContext context) {
    return PinnableListView(
      initiallyPinned: 3,
      pinController: pinController,
      children: Iterable.generate(10).map((i) {
        return ListTile(
          leading: FlatButton(
            color: Colors.blue,
            child: Text("pin/unpin"),
            onPressed: () {
              pinController.pin(i);
            },
          ),
          title: Text(i.toString()),
        );
      }).toList(),
    );
  }
}