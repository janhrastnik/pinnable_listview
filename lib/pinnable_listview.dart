library pinnable_listview;
import 'package:flutter/material.dart';

class PinnableListView extends StatefulWidget {
  final List<Widget> children;
  List<GlobalKey> globalKeys = List();
  List<Function> animFunctions = List();
  List<Function> pinFunctions = List();
  List<int> originalIndexes = List();
  PinController pinController;
  int pinned;
  PinnableListView({Key key, @required this.children, this.pinned, @required this.pinController}) : super(key: key);

  @override
  PinnableListViewState createState() => PinnableListViewState();
}

class PinnableListViewState extends State<PinnableListView> {

  addData(Function animFunction, Function pinFunction, GlobalKey key) {
    widget.globalKeys.add(key);
    widget.animFunctions.add(animFunction);
    widget.pinFunctions.add(pinFunction);
  }

  callFunctions(int index) {
    if (widget.pinned == null || index != 0) {
      widget.animFunctions.sublist(0, index).forEach((function) {
        double widgetHeight = widget.globalKeys[index].currentContext.findRenderObject().paintBounds.height;
        function(widgetHeight, false);
      });
      Future.delayed(Duration(milliseconds: 600)).then((_) {
        setState(() {
          widget.pinned = widget.originalIndexes[index];
          int moveIndex = widget.originalIndexes[index];
          widget.originalIndexes.removeAt(index);
          widget.originalIndexes.insert(0, moveIndex);

          Widget moveWidget = widget.children[index];
          widget.children.removeAt(index);
          widget.children.insert(0, moveWidget);
        });
      });
    } else {
      widget.animFunctions.sublist(1, widget.originalIndexes[index]+1).forEach((function) {
        double widgetHeight = widget.globalKeys[index].currentContext.findRenderObject().paintBounds.height;
        function(widgetHeight, true);
      });
      Future.delayed(Duration(milliseconds: 600)).then((_) {
        setState(() {
          widget.pinned = null;
          int moveIndex = widget.originalIndexes[0];
          widget.originalIndexes.removeAt(0);
          widget.originalIndexes.insert(moveIndex, moveIndex);

          Widget moveWidget = widget.children[0];
          widget.children.removeAt(0);
          widget.children.insert(moveIndex, moveWidget);
        });
      });
    }
  }

  getData(int index) {
    double distance;
    double widgetHeight = widget.globalKeys[index].currentContext.findRenderObject().paintBounds.height;
    if (widget.pinned == widget.originalIndexes[index]) {
      distance = -widget.pinned * widgetHeight;
    } else {
      distance = index * widgetHeight;
    }
    return [distance, widget.originalIndexes[index]];
  }

  setPin() {
    int moveIndex = widget.originalIndexes[widget.pinned];
    widget.originalIndexes.removeAt(widget.pinned);
    widget.originalIndexes.insert(0, moveIndex);

    Widget moveWidget = widget.children[widget.pinned];
    widget.children.removeAt(widget.pinned);
    widget.children.insert(0, moveWidget);
  }

  @override
  void initState() {
    super.initState();
    widget.originalIndexes = Iterable<int>.generate(widget.children.length).toList();
    widget.pinController.addListener(() {
      int trueIndex = widget.originalIndexes.indexOf(widget.pinController.index);
      widget.pinFunctions[trueIndex]();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pinned != null) {
        setPin();
      }
    });
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
            addData: addData,
            callFunctions: callFunctions,
            getData: getData,
          );
        },
      ),
    );
  }
}

class PinWidget extends StatefulWidget {
  // widget used for pinnable listview to handle individual events on children
  final Widget child;
  final int index;
  final Function(Function animFunction, Function pinFunction, GlobalKey key) addData;
  final Function(int index) callFunctions;
  final Function(int index) getData;
  PinWidget({Key key, this.child, this.index, this.addData,
    this.getData, this.callFunctions}): super(key: key);
  PinWidgetState createState() => PinWidgetState();
}

class PinWidgetState extends State<PinWidget> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  var tween;
  GlobalKey key;
  double distance = 0.0;

  move(double height, bool isPinned) {
    // called when a different pin widget gets pinned/unpinned, so that this one moves up or down
    if (isPinned) {
      distance = height;
    } else {
      distance = -height;
    }
    animationController.forward();
    Future.delayed(Duration(milliseconds: 600)).then((_) {
      animationController.reset();
    });
  }

  pin() {
    // called when this widget should get pinned/unpinned
    distance = widget.getData(widget.index)[0];
    widget.callFunctions(widget.index);
    animationController.forward();
    Future.delayed(Duration(milliseconds: 600)).then((_) {
      animationController.reset();
    });
  }

  @override
  void initState() {
    super.initState();
    key = GlobalKey();
    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600)
    );
    tween = Tween(
        begin: 0.0,
        end: 1.0
    ).animate(CurvedAnimation(
        parent: animationController,
        curve: Curves.ease
    ));
    widget.addData(move, pin, key);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.translate(
              offset: Offset(1.0, -distance * tween.value),
              child: GestureDetector(
                child: Container(
                  child: widget.child,
                  key: key,
                ),
                onTap: () {
                  pin();
                },
              )
          );
        });
  }
}

class PinController extends ChangeNotifier {
  // used to handle pin events on pinnable listview
  int index;

  pin(int i) {
    index = i;
    notifyListeners();
  }
}