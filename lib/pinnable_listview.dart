library pinnable_listview;
import 'package:flutter/material.dart';

class PinnableListView extends StatefulWidget {
  final List<Widget> children;
  List<GlobalKey> globalKeys = List();
  List<Function> animFunctions = List();
  List<Function> pinFunctions = List();
  List<int> originalIndexes = List();
  PinController pinController;
  PinnableListView({Key key, @required this.children, @required this.pinController}) : super(key: key);

  @override
  PinnableListViewState createState() => PinnableListViewState();
}

class PinnableListViewState extends State<PinnableListView> {

  void addData(Function animFunction, Function pinFunction, GlobalKey key) {
    widget.globalKeys.add(key);
    widget.animFunctions.add(animFunction);
    widget.pinFunctions.add(pinFunction);
  }

  Future<void> callFunctions(int index) async {
    if (widget.pinController.pinned == null || index != 0) {
      widget.animFunctions.sublist(0, index).forEach((function) {
        double widgetHeight = getWidgetHeight(index);
        function(widgetHeight, false);
      });
      await Future.delayed(Duration(milliseconds: 600));
      setState(() {
        widget.pinController.pinned = widget.originalIndexes[index];
        int moveIndex = widget.originalIndexes[index];
        widget.originalIndexes.removeAt(index);
        widget.originalIndexes.insert(0, moveIndex);

        Widget moveWidget = widget.children[index];
        widget.children.removeAt(index);
        widget.children.insert(0, moveWidget);

        GlobalKey moveKey = widget.globalKeys[index];
        widget.globalKeys.removeAt(index);
        widget.globalKeys.insert(0, moveKey);
      });
    } else {
      widget.animFunctions.sublist(1, widget.originalIndexes[index]+1).forEach((function) {
        double widgetHeight = getWidgetHeight(index);
        function(widgetHeight, true);
      });
      await Future.delayed(Duration(milliseconds: 600));
      setState(() {
        widget.pinController.pinned = null;
        int moveIndex = widget.originalIndexes[0];
        widget.originalIndexes.removeAt(0);
        widget.originalIndexes.insert(moveIndex, moveIndex);

        Widget moveWidget = widget.children[0];
        widget.children.removeAt(0);
        widget.children.insert(moveIndex, moveWidget);

        GlobalKey moveKey = widget.globalKeys[0];
        widget.globalKeys.removeAt(0);
        widget.globalKeys.insert(moveIndex, moveKey);
      });
    }
  }

  double getData(int index) {
    double distance = 0.0;
    if (widget.pinController.pinned == widget.originalIndexes[index]) {
      for (int i = 0; i < widget.pinController.pinned; i++) {
        distance -= getWidgetHeight(i);
      }
    } else {
      for (int i = 0; i < index; i++) {
        distance += getWidgetHeight(i);
      }
    }
    return distance;
  }

  void setPin() {
    int moveIndex = widget.originalIndexes[widget.pinController.pinned];
    widget.originalIndexes.removeAt(widget.pinController.pinned);
    widget.originalIndexes.insert(0, moveIndex);

    Widget moveWidget = widget.children[widget.pinController.pinned];
    widget.children.removeAt(widget.pinController.pinned);
    widget.children.insert(0, moveWidget);
  }

  double getWidgetHeight(index) {
    return widget.globalKeys[index].currentContext.findRenderObject().paintBounds.height;
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
      if (widget.pinController.pinned != null) {
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

class PinWidgetState extends State<PinWidget> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController animationController;
  var tween;
  GlobalKey globalKey = GlobalKey(); // needed to get widget height
  PageStorageKey storageKey; // needed to keep widget alive during scrolling
  double distance = 0.0;

  @override
  bool get wantKeepAlive => true;

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
    distance = widget.getData(widget.index);
    widget.callFunctions(widget.index);
    animationController.forward();
    Future.delayed(Duration(milliseconds: 600)).then((_) {
      animationController.reset();
    });
  }

  @override
  void initState() {
    super.initState();
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
    storageKey = PageStorageKey(widget.index);
    widget.addData(move, pin, globalKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: storageKey,
      child: AnimatedBuilder(
          key: globalKey,
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return Transform.translate(
                offset: Offset(1.0, -distance * tween.value),
                child: Container(
                  child: widget.child,
                )
            );
          }),
    );
  }
}

class PinController extends ChangeNotifier {
  // used to handle pin events on pinnable listview
  int index; // the last pressed pin tile
  int pinned; // the currently pinned tile original index

  Future<void> pin(int i) async {
    index = i;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 600));
  }
}