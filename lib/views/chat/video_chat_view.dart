import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
import 'package:quickblox_sdk/webrtc/rtc_video_view.dart';

class VideoChatView extends StatefulWidget {
  final dialogId;
  final userId;
  final opponentId;

  @override
  VideoChatView({this.dialogId, this.userId, this.opponentId});
  @override
  _VideoChatViewState createState() => _VideoChatViewState();
}

class _VideoChatViewState extends State<VideoChatView> {
  RTCVideoViewController _localVideoViewController;
  RTCVideoViewController _remoteVideoViewController;

  var isMicON = true;
  var isSpeakerON = true;
  var isVideoEnabled = true;
  Offset offset = Offset.zero;

  void _onLocalVideoViewCreated(RTCVideoViewController controller) {
    _localVideoViewController = controller;
    _localVideoViewController.setScaleType(1);
  }

  void _onRemoteVideoViewCreated(RTCVideoViewController controller) {
    _remoteVideoViewController = controller;
    _remoteVideoViewController.setScaleType(1);
  }

  Future<void> play() async {
    print(
        '############################ videos ids ##################################');
    print(widget.opponentId);
    print(widget.userId);
    if (_localVideoViewController != null) {
      _localVideoViewController.play(widget.dialogId, widget.userId);
    } else {
      print(
          '############################ local video null ##################################');
    }

    _remoteVideoViewController.play(widget.dialogId, widget.opponentId);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        acceptCall();
      });
    });
  }

  acceptCall() async {
    Map<String, Object> userInfo = new Map();

    try {
      await QB.webrtc.accept(widget.dialogId, userInfo: userInfo);
      Future.delayed(Duration(seconds: 1), () {
        play();
      });
    } on PlatformException catch (e) {
      // Some error occured, look at the exception message for more details
      print('****************** VIDEO CHAT ACCEPT CALL ERROR ****************');
      print(e.code);
      print(e.details);
    }
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.RECEIVED_VIDEO_TRACK,
          (data) {
        print('chat video ********');
        // Map<String, Object> payloadMap =
        //    new Map<String, Object>.from(data["payload"]);
        // int opponentId = payloadMap["userId"];
        setState(() {});
      });
    } on PlatformException catch (e) {
      // Some error occured, look at the exception message for more details
      print(e.code);
      print(e.details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                child: RTCVideoView(
                  onVideoViewCreated: _onRemoteVideoViewCreated,
                ),
                decoration: new BoxDecoration(color: Colors.black54),
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    offset = Offset(offset.dx + details.delta.dx,
                        offset.dy + details.delta.dy);
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: isVideoEnabled ? 120.0 : 0.0,
                  height: isVideoEnabled ? 200.0 : 0.0,
                  child: RTCVideoView(
                    onVideoViewCreated:
                        isVideoEnabled ? _onLocalVideoViewCreated : null,
                  ),
                  decoration: new BoxDecoration(color: Colors.black54),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: isVideoEnabled
                        ? Icon(Icons.videocam)
                        : Icon(Icons.videocam_off),
                    color: isVideoEnabled ? Colors.white : Colors.red,
                    iconSize: 40,
                    onPressed: () {
                      setState(() {
                        isVideoEnabled = !isVideoEnabled;
                        QB.webrtc.enableVideo(widget.dialogId,
                            enable: isVideoEnabled);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.call_end,
                      color: Colors.red,
                    ),
                    iconSize: 40,
                    onPressed: () {
                      QB.webrtc.hangUp(widget.dialogId);
                      Future.delayed(Duration(milliseconds: 300), () {
                        this._localVideoViewController = null;
                        this._remoteVideoViewController = null;
                        Navigator.pop(context);
                      });
                    },
                  ),
                  IconButton(
                    icon: isMicON ?  Icon(Icons.mic) : Icon(Icons.mic_off) ,
                    iconSize: 40,
                    color: isMicON ? Colors.white : Colors.red,
                    onPressed: () {
                      setState(() {
                        isMicON = !isMicON;
                        QB.webrtc.enableAudio(widget.dialogId, enable: isMicON);
                      });
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
