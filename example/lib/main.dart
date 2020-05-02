import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinnablelistview/pinlistview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  PinController pinController = PinController();

  Widget tileWidget(i) {
    return GestureDetector(
      child: Container(
        height: 50.0,
        color: Colors.blue[100 + i*100],
        child: Center(child: Text(i.toString()),)
      ),
      onTap: () {
        pinController.pin(i);
      },
    );
  }

  List<Widget> testList = [
    GestureDetector(
      child: Container(
        color: Colors.red,
      ),
      onTap: () {
      },
    ),
    GestureDetector(
      child: Container(
        color: Colors.red,
      ),
      onTap: () {
      },
    ),
    GestureDetector(
      child: Container(
        color: Colors.red,
      ),
      onTap: () {
      },
    )
  ];

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
          children: Iterable<int>.generate(5).map((i) => tileWidget(i)).toList()
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            pinController.pin(4);
          },
        ),
      )
    );
  }
}