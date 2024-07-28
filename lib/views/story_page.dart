import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/models/story.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/views/add_new_story/media_preview.dart';
import 'package:peloton/views/log_book/log_book.dart';
import 'package:video_player/video_player.dart';

class StoryPageWidget extends StatefulWidget {
  final Story story;
  @override
  StoryPageWidget({this.story});
  @override
  _StoryPageWidgetState createState() => _StoryPageWidgetState();
}

class _StoryPageWidgetState extends State<StoryPageWidget> {
  VideoPlayerController _controller;
  ChewieController _chewieController;

  String getTimeComponents(Timestamp createdAt) {
    DateTime parseDt = createdAt.toDate();
    var newFormat = intl.DateFormat('EEE, MMM d ' + 'h:mm a');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  Future<void> _showDeleteDialog(Story story, context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xffc02e2f),
              child: Image.asset(
                'assets/bin.png',
                color: Colors.white,
                height: 50,
                width: 50,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)
                      .translate('DeleteDiscussionPoint'),
                  style: const TextStyle(
                      color: const Color(0xff4a4a4a),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('No'),
                style: const TextStyle(
                    color: const Color(0xffc02e2f),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                AppLocalizations.of(context).translate('Yes'),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () async {
                if (story.media != null) {
                  StorageReference ref = await FirebaseStorage.instance
                      .getReferenceFromUrl(story.media['url']);
                  ref?.delete();
                }
                story.deleteThisStory();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  initPlayer() async {
    await _controller.initialize();

    _chewieController = ChewieController(
      fullScreenByDefault: false,
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: false,
      looping: false,
    );
    setState(() {
      // _chewieController.play();
    });
  }

  @override
  void initState() {
    if (widget.story.media != null && widget.story.media['type'] == 'video') {
      _controller = VideoPlayerController.network(widget.story.media['url']);
      initPlayer();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.story.media != null && widget.story.media['type'] == 'video') {
      _controller.dispose();
      _chewieController.dispose();
    }
    super.dispose();
  }

  void showMedia() {
    if (widget.story.media != null && widget.story.media['type'] == 'image') {
      /*
      showModalBottomSheet(
        context: context,
        shape: const ContinuousRectangleBorder(),
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: PhotoViewGestureDetectorScope(
              axis: Axis.vertical,
              child: PhotoView(
                tightMode: true,
                imageProvider: NetworkImage(widget.story.media['url']),
                heroAttributes: PhotoViewHeroAttributes(tag: widget.story.id),
              ),
            ),
          );
        },
      );
      */

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MediaPreviewWidget(
            file: null,
            isVideo: false,
            remote: widget.story.media['url'],
            id: widget.story.id,
          ),
        ),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton(
                onPressed: () {
                  _showDeleteDialog(widget.story, context);
                },
                icon: Icon(
                  Icons.more_vert,
                  size: 28,
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 250),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.story.title,
                            maxLines: 3,
                            style: TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                          ),
                          Text(
                            getTimeComponents(widget.story.createAt),
                            style: const TextStyle(
                                color: const Color(0xff4a4a4a),
                                fontWeight: FontWeight.w400,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 15.0),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Image.asset(
                        'assets/bface${widget.story.mood}.png',
                        width: 40,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: showMedia,
                child: Stack(
                  fit: StackFit.loose,
                  children: <Widget>[
                    Container(
                      color: Colors.black,
                      height: (widget.story.media != null) ? 220 : 0,
                      width: double.infinity,
                      child: (widget.story.media != null
                          ? Hero(
                              tag: widget.story.id,
                              child: widget.story.media['type'] == 'image'
                                  ? Image.network(
                                      widget.story.media['type'] == 'image'
                                          ? widget.story.media['url']
                                          : widget.story.media['thumbnail'],
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center,
                                    )
                                  : _chewieController != null
                                      ? Container(
                                          child: Chewie(
                                            controller: _chewieController,
                                          ),
                                        )
                                      : Container(),
                            )
                          : Container()),
                    ),
                    (widget.story.media != null &&
                            widget.story.media['type'] == 'image')
                        ? PositionedDirectional(
                            top: 8,
                            end: 8,
                            child: IconShadowWidget(
                              Icon(
                                Icons.zoom_in,
                                size: 40,
                                color: Colors.white,
                              ),
                              shadowColor: Colors.black.withOpacity(0.3),
                              showShadow: true,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsetsDirectional.only(end: 18, start: 18),
                child: Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: widget.story.healthProfile
                        .map((act) => new StoryActivity(
                              activity: act,
                              showName: true,
                            ))
                        .toList()),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.story.description ?? '',
                      style: const TextStyle(
                          color: const Color(0xff4a4a4a),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
