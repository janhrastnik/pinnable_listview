import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  List widgetHeightList = [0, 0, 0, 0, 0, 0];
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<GlobalKey> globalKeys = List();
  List<Function> animationFunctionsList = List();
  List widgetList = [
    Text("red"), Text("orange"), Text("cyan"), Text("yellow"), Text("magenta"), Text("turquoise")
  ];
  List originalIndexList = [0, 1, 2, 3, 4, 5];
  int pinned;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      globalKeys.asMap().forEach((index, element) {
        widgetHeightList[index] = element.currentContext.findRenderObject().paintBounds.height;
      });
    });
  }

  addWidget(Function function, GlobalKey key) {
    globalKeys.add(key);
    animationFunctionsList.add(function);
  }

  callFunction(int index) {
      double widgetHeight = 0.0;
      if (pinned != null && index == 0) {
        widgetHeight = 0 - widgetHeightList[index];
        animationFunctionsList.sublist(1, originalIndexList[0]).forEach((function) {
          function(widgetHeight);
        });
      } else {
        widgetHeight = widgetHeightList[index];
        animationFunctionsList.sublist(0, index).forEach((function) {
          function(widgetHeight);
        });
      }
      Future.delayed(Duration(milliseconds: 300)).then((value) {
        if (pinned == null || index != 0) {
          Widget movableWidget = widgetList[index];
          widgetList.removeAt(index);
          widgetList.insert(0, movableWidget);
          double movableHeight = widgetHeightList[index];
          widgetHeightList.removeAt(index);
          widgetHeightList.insert(0, movableHeight);
          int movableIndex = originalIndexList[index];
          originalIndexList.removeAt(index);
          originalIndexList.insert(0, movableIndex);
          pinned = originalIndexList[0];
        } else {
          int originalIndex = originalIndexList[index];
          int removable = originalIndexList[originalIndex];

          print(globalKeys);
          globalKeys.removeAt(removable);
          animationFunctionsList.removeAt(removable);
          print(globalKeys);
          pinned = null;

          Widget movableWidget = widgetList[0];
          widgetList.removeAt(0);
          widgetList.insert(originalIndex, movableWidget);
          double movableHeight = widgetHeightList[0];
          widgetHeightList.removeAt(0);
          widgetHeightList.insert(originalIndex, movableHeight);
          int movableIndex = originalIndexList[0];
          originalIndexList.removeAt(0);
          originalIndexList.insert(originalIndex, movableIndex);
        }
      });
  }

  int getTrueIndex(int index) {
    return originalIndexList[index];
  }

  double getDistance(int index) {
    double travelDistance = 0.0;
    if (pinned != null && index == 0) {
      index = pinned;
    }
    widgetHeightList.sublist(0, index).forEach((element) {
      travelDistance += element;
    });
    return travelDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example"),
      ),
      body: AnimatedList(
        shrinkWrap: true,
        key: listKey,
        initialItemCount: widgetHeightList.length,
        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
          return PinTile(
            globalKeys: globalKeys,
            listKey: listKey,
            index: index,
            addWidget: addWidget,
            callFunction: callFunction,
            getTrueIndex: getTrueIndex,
            getDistance: getDistance,
            child: widgetList[index]
          );
        },
      ),
    );
  }
}

class PinTile extends StatefulWidget {
  final listKey;
  final globalKeys;
  final index;
  final Function(Function function, GlobalKey key) addWidget;
  final Function(int index) callFunction;
  final Function(int index) getTrueIndex;
  final Function(int index) getDistance;
  final Widget child;

  PinTile({Key key, this.listKey, this.globalKeys,
    this.index, this.addWidget, this.callFunction, this.getTrueIndex,
    this.child, this.getDistance}) : super(key: key);

  PinTileState createState() => PinTileState();
}

class PinTileState extends State<PinTile> with SingleTickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  double opacity = 1.0;
  AnimationController animationController;
  Animation<double> animation;

  runAnimation(double height) {
    // instantiate the animation now that you know the bounds it should have
    animation = Tween(begin: 0.0, end: height).animate(animationController);
    animationController.forward().then((_) => animationController.reset());
  }

  @override
  void initState() {
    super.initState();
    print(widget.child);
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    widget.addWidget(runAnimation, key);
    animation = Tween(begin: 0.0, end: 0.0).animate(animationController);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, child) => Transform.translate(
        offset: Offset(0.0, animation.value),
        child: child,
      ),
      child: Opacity(
          key: key,
          opacity: opacity,
          child: GestureDetector(
            child: widget.child,
            onTap: () {
              int trueIndex = widget.getTrueIndex(widget.index);
              widget.callFunction(widget.index);
              if (widget.index != 0 || widget.index == 0 && trueIndex == 0) {
                AnimatedListState animatedList = widget.listKey.currentState;
                double travelDistance = widget.getDistance(widget.index);
                double widgetHeight = context.findRenderObject().paintBounds.height;
                animatedList.removeItem(widget.globalKeys.length - 1, (context, animation) {
                  opacity = 0.0;
                  animation.addListener(() {
                    if (animation.isDismissed) {
                      setState(() {
                        opacity = 1.0;
                      });
                    }
                  });
                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(1.0, ( -widgetHeight * (widget.globalKeys.length - widget.index) - travelDistance + travelDistance * animation.value) * 1),
                    child: widget.child,
                  );
                });
                animatedList.insertItem(0);
              } else {
                AnimatedListState animatedList = widget.listKey.currentState;
                double travelDistance = widget.getDistance(widget.index);
                double widgetHeight = context.findRenderObject().paintBounds.height;
                animatedList.removeItem(0, (context, animation) {
                  return Transform(
                    transform: Matrix4.identity()
                      ..translate(1.0, travelDistance - travelDistance * animation.value),
                    child: widget.child,
                  );
                });
                animatedList.insertItem(trueIndex);
              }
            },
          )
      ),
    );
  }
}