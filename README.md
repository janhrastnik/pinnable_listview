# PinnableListView
A Flutter ListView widget that allows pinning a ListView child to the top of the list.
## Demo

<img src="https://github.com/janhrastnik/assets/blob/master/demo2.gif" height="720px" hspace="10">

## Getting Started

Define the list
```
  PinController pinController = PinController();

  @override
  Widget build(BuildContext context) {
      return PinnableListView(
          pinController: pinController,
          children: listOfWidgets
      );
  }
```

Then pin a widget with
```
  pinController.pin(index)
```
*index* meaning the child which you'd like to pin/unpin.

See the [example](https://github.com/janhrastnik/pinnable_listview/tree/master/example) app for more details.

## Problems
- Calling setState on PinnableListView after it has changed will crash the list, because it will try to reload the original list.
- Missing implementation for PinnableListView.builder.
- Changing the size of a child after first build will crash the list, as the list calculates widget heights based on the render boxes at the beginning of the app.
