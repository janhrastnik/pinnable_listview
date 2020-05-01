import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PinList(children: <Widget>[
        Container(
          height: 50.0,
          color: Colors.red,
          child: Text("A"),
        ),
        Container(
          height: 50.0,
          color: Colors.amber,
          child: Text("B"),

        ),
        Container(
          height: 50.0,
          color: Colors.green,
          child: Text("C"),

        ),
        Container(
          height: 50.0,
          color: Colors.blue,
          child: Text("D"),

        ),
        Container(
          height: 50.0,
          color: Colors.purple,
          child: Text("E"),

        )
      ],),
    );
  }
}

class PinList extends StatefulWidget {
  final List<Widget> children;
  List<double> widgetHeightList = List();
  List<Function> animFunctions = List();
  int pinned;
  PinList({Key key, this.children, this.pinned}) : super(key: key);
  List<int> originalIndexes;

  @override
  PinListState createState() => PinListState();
}

class PinListState extends State<PinList> {

  addFunction(Function function) {
    print("event");
    widget.animFunctions.add(function);
  }

  callFunctions(int index) {
      print(widget.animFunctions.length);
      if (widget.pinned == null || index != 0) {
        widget.animFunctions.sublist(0, index).forEach((function) {
            function(50.0, false);
        });
        Future.delayed(Duration(seconds: 1)).then((_) {
          setState(() {
            widget.pinned = widget.originalIndexes[index];
            int moveIndex = widget.originalIndexes[index];
            widget.originalIndexes.removeAt(index);
            widget.originalIndexes.insert(0, moveIndex);

            Widget moveWidget = widget.children[index];
            print(moveWidget);
            widget.children.removeAt(index);
            widget.children.insert(0, moveWidget);
            print(widget.originalIndexes);
          });
        });
      } else {
        print("this gets run");
        widget.animFunctions.sublist(1, widget.originalIndexes[index]+1).forEach((function) {
          function(50.0, true);
        });
        Future.delayed(Duration(seconds: 1)).then((_) {
          setState(() {
            widget.pinned = null;
            int moveIndex = widget.originalIndexes[0];
            widget.originalIndexes.removeAt(0);
            widget.originalIndexes.insert(moveIndex, moveIndex);

            Widget moveWidget = widget.children[0];
            print(moveWidget);
            widget.children.removeAt(0);
            widget.children.insert(moveIndex, moveWidget);
            print(widget.originalIndexes);
          });
        });
      }
  }

  getData(int index) {
    double distance;
    if (widget.pinned == widget.originalIndexes[index]) {
      distance = -widget.pinned * 50.0;
    } else {
      distance = index * 50.0;
    }
    return [distance, widget.originalIndexes[index]];
  }

  @override
  void initState() {
    super.initState();
    for (Widget w in widget.children) {
      w.
    }
    widget.originalIndexes = Iterable<int>.generate(widget.children.length).toList();
    if (widget.pinned != null) {
      int moveIndex = widget.originalIndexes[widget.pinned];
      widget.originalIndexes.removeAt(widget.pinned);
      widget.originalIndexes.insert(0, moveIndex);

      Widget moveWidget = widget.children[widget.pinned];
      print(moveWidget);
      widget.children.removeAt(widget.pinned);
      widget.children.insert(0, moveWidget);
      print(widget.originalIndexes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.children.length,
        itemBuilder: (BuildContext context, int index) {
          return PinWidget(
              child: widget.children[index],
              index: index,
              addFunction: addFunction,
              callFunctions: callFunctions,
              getData: getData,
          );
        },
      ),
    );
  }
}

class PinWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final Function(Function function) addFunction;
  final Function(int index) callFunctions;
  final Function(int index) getData;
  PinWidget({Key key, this.child, this.index, this.addFunction,
    this.getData, this.callFunctions}): super(key: key);
  PinWidgetState createState() => PinWidgetState();
}

class PinWidgetState extends State<PinWidget> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  double distance = 0.0;

  move(double height, bool isPinned) {
    if (isPinned) {
      distance = height;
    } else {
      distance = -height;
    }
    animationController.forward();
    Future.delayed(Duration(seconds: 1)).then((_) {
      animationController.reset();
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1)
    );
    widget.addFunction(move);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.translate(
              offset: Offset(1.0, -distance * animationController.value),
              child: GestureDetector(
                child: widget.child,
                onTap: () {
                  distance = widget.getData(widget.index)[0];
                  print(distance);
                  int originalIndex = widget.getData(widget.index)[1];
                  widget.callFunctions(widget.index);
                  animationController.forward();
                  Future.delayed(Duration(seconds: 1)).then((_) {
                    animationController.reset();
                  });
                },
              )
          );
        });
  }
}

