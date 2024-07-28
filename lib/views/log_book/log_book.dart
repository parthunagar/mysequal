import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/activities_types/goal_activities.dart';
import 'package:peloton/models/story.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/views/story_page.dart';

class LogBookwidget extends StatefulWidget {
  final Story story;
  @override
  LogBookwidget({this.story});
  @override
  _LogBookwidgetState createState() => _LogBookwidgetState();
}

class _LogBookwidgetState extends State<LogBookwidget> {
  bool isEditing = false;
  String getTimeComponents(Timestamp createdAt) {
    DateTime parseDt = createdAt.toDate();
    var newFormat = intl.DateFormat('EEE, MMM d ' + 'h:mm a');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  void _onViewItem() {
    print('view item: ');
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryPageWidget(story: widget.story),
        ));
  }

  // void _onEditItem() {
  //   print('edit item: ');
  // }

  void _onDeleteItem() {
    print('delete item: ');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.clip,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        OverlayableContainerOnLongPress(
          onTap: () {
            print('tap');
          },
          overlayContentBuilder:
              (BuildContext context, VoidCallback onHideOverlay) {
            return Stack(
              overflow: Overflow.clip,
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xff003561).withOpacity(0.7),
                  ),
                  margin: EdgeInsetsDirectional.only(
                      start: 12, top: 25, bottom: 12, end: 12),
                  //  padding: EdgeInsetsDirectional.only(
                  //   start: 12, top: 10, bottom: 12),
                  height: double.infinity,

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x26000000),
                                    offset: Offset(0, 0),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                  ),
                                ],
                                color: const Color(0xffffffff)),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xff3c84f2),
                              ),
                              onPressed: () {
                                onHideOverlay();
                                _onDeleteItem();
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Edit",
                            style: const TextStyle(
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 35,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x26000000),
                                      offset: Offset(0, 0),
                                      blurRadius: 10,
                                      spreadRadius: 0)
                                ],
                                color: const Color(0xffffffff)),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xff3c84f2),
                              ),
                              onPressed: () {
                                onHideOverlay();
                                _onDeleteItem();
                              },
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Delete",
                            style: const TextStyle(
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PositionedDirectional(
                  start: 5,
                  top: 12,
                  child: Container(
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xff3c84f2),
                    ),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(17),
                      color: Colors.white,
                    ),
                  ),
                ),
                widget.story.mood != null
                    ? PositionedDirectional(
                        end: 50,
                        top: 0,
                        child: Container(
                          width: 55,
                          height: 25.1,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadiusDirectional.only(
                                  topEnd: Radius.circular(25),
                                  topStart: Radius.circular(25)),
                              color: Color(0xff003561).withOpacity(0.7)),
                        ),
                      )
                    : Container(),
              ],
            );
          },
          child: GestureDetector(
            onTap: () {
              print('inside tap');
              _onViewItem();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x1a000000),
                      offset: Offset(0, 0),
                      blurRadius: 42,
                      spreadRadius: 0),
                ],
              ),
              margin: EdgeInsetsDirectional.only(
                  start: 12, top: 25, bottom: 12, end: 12),
              padding:
                  EdgeInsetsDirectional.only(start: 12, top: 10, bottom: 12),
              child: GestureDetector(
                onTap: null,
                //  () {
                //   print('container tap');
                // },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              constraints: BoxConstraints(maxWidth: 220),
                              margin: EdgeInsetsDirectional.only(end: 70),
                              child: Text(
                                widget.story.title,
                                maxLines: 2,
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.0),
                              ),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(getTimeComponents(widget.story.createAt),
                                style: const TextStyle(
                                    color: const Color(0xff4a4a4a),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14.0)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: null,
                          //() {
                          //   print('edit');
                          //   setState(() {
                          //     isEditing = !isEditing;
                          //   });
                          // },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        widget.story.media != null
                            ? Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Hero(
                                    tag: widget.story.id,
                                    child: Image.network(
                                      (widget.story.media['type'] == 'image')
                                          ? widget.story.media['url']
                                          : widget.story.media['thumbnail'] ??
                                              '',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height:
                                          100, //sizingInformation.scaleByWidth(152),
                                    ),
                                  ),
                                  widget.story.media['type'] == 'video'
                                      ? Container(
                                          padding: EdgeInsets.all(8),
                                          child: Image.asset(
                                            'assets/multimedia-option.png',
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topLeft,
                                            width: 48,
                                          ),
                                        )
                                      : Container(),
                                ],
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                child: Center(
                                  child: Image.asset(
                                    'assets/placeholder.png',
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    width: 75,
                                    height: 60,
                                  ),
                                ),
                              ),
                        SizedBox(
                          width: 25,
                        ),
                        Container(
                          child: Expanded(
                            child: Builder(
                              builder: (_) {
                                List<Widget> result = [];
                                for (var item
                                    in widget.story.healthProfile.take(6)) {
                                  result.add(StoryActivity(
                                    activity: item,
                                    showName: false,
                                  ));
                                }
                                return Wrap(
                                  spacing: 18,
                                  runSpacing: 10,
                                  direction: Axis.horizontal,
                                  children: result,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Text(
                    //   widget.story.description ?? '',
                    //   style: const TextStyle(
                    //       color: const Color(0xff00183c),
                    //       fontWeight: FontWeight.w400,
                    //       fontFamily: "Inter",
                    //       fontStyle: FontStyle.normal,
                    //       fontSize: 16.0),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
        widget.story.mood != null
            ? PositionedDirectional(
                end: 50,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: isEditing ? Colors.transparent : Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/bface${widget.story.mood}.png',
                        height: 35,
                        width: 35,
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}

class StoryActivity extends StatelessWidget {
  final GoalJournalActivity activity;
  final bool showName;
  @override
  StoryActivity({this.activity, this.showName});
  Widget getActivityIcon() {
    if (activity.type == 'slider') {
      return Text(
        '${activity.value}/${activity.maxValue}',
        style: const TextStyle(
            color: const Color(0xff3c84f2),
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
            fontStyle: FontStyle.normal,
            fontSize: 9.0),
      );
    } else if (activity.type == 'stepper') {
      return Text(
        '${activity.value}',
        style: const TextStyle(
            color: const Color(0xff3c84f2),
            fontWeight: FontWeight.w700,
            fontFamily: "Inter",
            fontStyle: FontStyle.normal,
            fontSize: 9.0),
      );
    } else {
      return Icon(activity.value == 1 ? Icons.check : Icons.close,
          color: Colors.blue, size: 12);
    }
  }

  String getActivityName(GoalJournalActivity activity, context) {
    if (activity.id != null) {
      var name = AppLocalizations.of(context).translate('${activity.id}');

      if (name != null) {
        return name;
      } else {
        var name = AppLocalizations.of(context).translate('${activity.name}');
        if (name != null) {
          return name;
        } else {
          return '';
        }
      }
    } else {
      var name = AppLocalizations.of(context).translate('${activity.name}');
      if (name != null) {
        return name;
      } else {
        return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35 / 2),
                    color: Colors.blue),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.network(
                    activity.iconUrl,
                    height: 37,
                    width: 37,
                    color: Colors.white,
                  ),
                ),
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.5),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x2b000000),
                            offset: Offset(0, 0),
                            blurRadius: 7,
                            spreadRadius: 0)
                      ],
                      color: const Color(0xffffffff)),
                  child: Center(
                    child: getActivityIcon(),
                  ),
                ),
              )
            ],
          ),
        ),
        showName
            ? Padding(
                padding: EdgeInsetsDirectional.only(top: 10,start:5),
                child: Text(
                  getActivityName(activity, context),
                  style: const TextStyle(
                      color: const Color(0xff3c84f2),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 16.0),
                ),
              )
            : Container()
      ],
    );
  }
}

/// -----------------------------------------------------------------
/// Widget that accepts an overlay to be displayed on top of itself
/// when a LongPress gesture is detected.
///
/// Required a specific Overlay higher in the hierarchy to be used
/// as a parent
/// -----------------------------------------------------------------
typedef OverlayableContainerOnLongPressBuilder(
    BuildContext context, VoidCallback hideOverlay);

class OverlayableContainerOnLongPress extends StatefulWidget {
  OverlayableContainerOnLongPress({
    Key key,
    @required this.child,
    @required this.overlayContentBuilder,
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final OverlayableContainerOnLongPressBuilder overlayContentBuilder;
  final VoidCallback onTap;

  @override
  _OverlayableContainerOnLongPressState createState() =>
      _OverlayableContainerOnLongPressState();
}

class _OverlayableContainerOnLongPressState
    extends State<OverlayableContainerOnLongPress> {
  OverlayEntry _overlayEntry;

  @override
  void dispose() {
    _removeOverlayEntry();
    super.dispose();
  }

  void _removeOverlayEntry() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  ///
  /// Returns the position (as a Rect) of an item
  /// identified by its BuildContext
  ///
  Rect _getPosition(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    final Offset bottomRight =
        box.size.bottomRight(box.localToGlobal(Offset.zero));
    return Rect.fromLTRB(
        topLeft.dx, topLeft.dy, bottomRight.dx, bottomRight.dy);
  }

  ///
  /// Displays an OverlayEntry on top of the selected item
  /// This overlay disappears if we click outside or, on demand
  ///
  void _showOverlayOnTopOfItem(BuildContext context) {
    OverlayState overlayState = Overlay.of(context);
    final Rect overlayPosition = _getPosition(overlayState.context);

    // Get the coordinates of the item
    final Rect widgetPosition = _getPosition(context).translate(
      -overlayPosition.left,
      -overlayPosition.top,
    );

    // Generate the overlay entry
    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          ///
          /// Remove the overlay when we tap outside
          ///
          _removeOverlayEntry();
        },
        child: Material(
          color: Colors.transparent,
          child: CustomSingleChildLayout(
            delegate: _OverlayableContainerLayout(widgetPosition),
            child: widget.overlayContentBuilder(context, _removeOverlayEntry),
          ),
        ),
      );
    });

    // Insert the overlayEntry on the screen
    overlayState.insert(
      _overlayEntry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          _showOverlayOnTopOfItem(context);
          //widget.onTap();
        }
      },
      onLongPress: () {
        _showOverlayOnTopOfItem(context);
      },
      child: widget.child,
    );
  }
}

class _OverlayableContainerLayout extends SingleChildLayoutDelegate {
  _OverlayableContainerLayout(this.position);

  final Rect position;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(Size(position.width, position.height));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(position.left, position.top);
  }

  @override
  bool shouldRelayout(_OverlayableContainerLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}
