import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peloton/views/chat/video_chat_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plain_notification_token/plain_notification_token.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/mappers/qb_message_mapper.dart';
import 'package:quickblox_sdk/models/qb_attachment.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_file.dart';
import 'package:quickblox_sdk/models/qb_message.dart';
import 'package:quickblox_sdk/models/qb_subscription.dart';

import 'package:quickblox_sdk/models/qb_user.dart';
import 'package:quickblox_sdk/push/constants.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:flutter/services.dart';
import 'package:quickblox_sdk/webrtc/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:intl/intl.dart' as intl;

import 'flat_chat_message.dart';

class ChatManager {
  String getMessageTime(time) {
    DateTime parseDt = DateTime.fromMillisecondsSinceEpoch(time);
    var newFormat = intl.DateFormat('H:mm');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  String getMessageDate(time) {
    DateTime parseDt = DateTime.fromMillisecondsSinceEpoch(time);
    var newFormat = intl.DateFormat('EEE, MMM d ');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  bool shouldShowDate(time, prevTime) {
    if (time == null || prevTime == null) {
      return true;
    }

    DateTime currTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateTime prev = DateTime.fromMillisecondsSinceEpoch(prevTime);
    return !(currTime.year == prev.year &&
        currTime.month == prev.month &&
        currTime.day == prev.day);
  }

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ChatManager._privateConstructor();

  static final ChatManager _instance = ChatManager._privateConstructor();

  static ChatManager get instance => _instance;

  var didSubscribeToNewMesage = false;
  var isPresentingAlert = false;

  StreamController<FlatChatMessage> chatStreamController =
      StreamController<FlatChatMessage>.broadcast();
  StreamController<FlatChatMessage> groupStreamController =
      StreamController<FlatChatMessage>.broadcast();
  StreamController globalStream = StreamController<QBMessage>.broadcast();
  var plainNotificationToken = PlainNotificationToken();
  var openedChatId = "0";
  var myId;
  static const tokenUpdateChannel =
      const MethodChannel('net.nadsoft.peloton/tokenUpdateChannel');
  Permission cameraPermission = Permission.camera;
  Permission micPermission = Permission.microphone;

  addMessageToStream(message, dialogId) {
    if (dialogId == openedChatId) {
      chatStreamController.add(message);
    } else if (openedChatId != "0") {
      groupStreamController.add(message);
    }
  }

  globalStreamMessage(message) {
    globalStream.add(message);
  }

  // initChat() async {
  //   try {
  //     await QB.settings.init(
  //       '81605',
  //       'sALZeTpkWHQ2AbE',
  //       'VtVMUdvSxNOPY3n',
  //       'szEFdLkYsBZUKjRJeQ8G',
  //       apiEndpoint: null,
  //       chatEndpoint: null,
  //     );
  //     //disable sending to other devices
  //     await QB.settings.disableCarbons();
  //   } on PlatformException catch (e) {
  //     print(e);
  //     // Some error occured, look at the exception message for more details
  //   }
  // }

  connectChat(userName, password) async {
    try {
      await QB.chat.connect(userName, password);
      return;
    } on PlatformException catch (e) {
      print(e);
      // Some error occured, look at the exception message for more details
    }
  }

  disconnectchat() async {
    try {
      await QB.chat.disconnect();
    } on PlatformException catch (e) {
      print(e);
      // Some error occured, look at the exception message for more details
    }
  }

  updateToken(MethodCall call) async {
    print('********** token method call **************');
    print(call.method);
    print(call.arguments);
    try {
      var sublist = await QB.subscriptions.get();
      if (sublist != null && sublist.length > 10) {
        print('has subs.....return');
        return;
      }
      print('total subs ::');
      print(sublist.length);
    } on PlatformException catch (e) {
      print(e);
      print(e.details);
      print(e.message);
    }
    try {
      await QB.subscriptions
          .create(call.arguments, QBPushChannelNames.APNS);

      print('**** noti');
    } on PlatformException catch (e) {
      print(e);
      print(e.details);
      print(e.message);
      // Some error occured, look at the exception message for more details
    }

  }

  subscribeForNotifications() async {
    if (Platform.isIOS) {
      tokenUpdateChannel.setMethodCallHandler((call) => updateToken(call));
      // plainNotificationToken.onTokenRefresh.listen((event) {
      //   print(event);
      // });
      // plainNotificationToken.onIosSettingsRegistered.listen((event) {
      //   print('**** token event2');
      // });
    } else {
      // (iOS Only) Need requesting permission of Push Notification.
      // if (Platform.isIOS) {
      // //   //plainNotificationToken.requestPermission();

      // //   // If you want to wait until Permission dialog close,
      // //   // you need wait changing setting registered.
      //    await plainNotificationToken.onIosSettingsRegistered.first;

      // }
      // try {
      //   var connected = await QB.chat.isConnected();
      //   if (!connected) {
      //     return;
      //   }
      //   var sublist = await QB.subscriptions.get();
      //   print('total subs ::');
      //   print(sublist.length);
      // } on PlatformException catch (e) {
      //   print(e);
      //   print(e.details);
      //   print(e.message);
      // }
      // print('token null');

      var token = await plainNotificationToken.getToken();
      if (token == null) {
        print('token null');
        return;
      }
      print('token ****');
      print(token);

      try {
        List<QBSubscription> subscriptions = await QB.subscriptions.create(
            token,
            Platform.isIOS ? QBPushChannelNames.APNS : QBPushChannelNames.GCM);
        print(subscriptions.length);
        print('**** noti');
      } on PlatformException catch (e) {
        print(e);
        print(e.details);
        print(e.message);
        // Some error occured, look at the exception message for more details
      }
    }
  }

  Future<QBDialog> createRoom(occupantsIds, type, dialogName) async {
    try {
      QBDialog createdDialog = await QB.chat
          .createDialog(occupantsIds, dialogName, dialogType: type);

      return createdDialog;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<QBDialog>> getRooms() async {
    try {
      List<QBDialog> dialogs = await QB.chat.getDialogs();
      print('dialogs count ${dialogs.length}');
      var newdialogs = dialogs.where((f) => f.type != 3).toList();
      return newdialogs;
    } on PlatformException catch (e) {
      print(e.code);
      return null;
    }
  }

  Future<List<QBDialog>> getMyRooms() async {
    try {
      List<QBDialog> dialogs = await QB.chat.getDialogs();
      for (var dialog in dialogs) {
        print(dialog.name);
        print(dialog.type);
      }
      //public = 1 , group = 2 , chat = 3
      var newdialogs = dialogs.where((f) => f.type == 3).toList();
      print(newdialogs.length);

      return newdialogs;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  Future<String> createUser(String login, String password) async {
    try {
      QBUser user = await QB.users.createUser(
        login,
        password,
      );
      return user.login;
    } on PlatformException catch (e) {
      print('log in error');
      print(e.details);
      print(e.code);
      return e.code.split('\n').first;
      // Some error occured, look at the exception message for more details
    }
  }

  Future<int> loginWithCrid(usermname, pass) async {
    try {
      print('will log in  ***');

      QBLoginResult result = await QB.auth.login(usermname, pass);
      QBUser qbUser = result.qbUser;

      print('save user data');
      final SharedPreferences prefs = await _prefs;
      await prefs.setInt("userID", qbUser.id);
      myId = qbUser.id;
      await connectoChat(qbUser.id, pass);
      // await getMyDialogs();
      print('return user id');
      print(qbUser.id);
      return qbUser.id;
    } on PlatformException catch (e) {
      print(e.code.split('\n'));
      print(e.details + ' details');

      if (e.code.split('\n').first == '401') {
        print('will create');
        var user = await createUser(usermname, pass);
        if (user == '422') {
          print('name taken');
          return 422;
          // aready taken
        }
        var loginresult = await loginWithCrid(usermname, pass);

        print('did create user');
        print(user);
        return loginresult;
      }

      return 0;
    }
  }

  Future<void> connectoChat(userid, pass) async {
    try {
      return await QB.chat.connect(userid, pass);
    } catch (e) {
      return;
    }
  }

  subscribeToNewMessageEvent() {
    try {
      QB.chat.subscribeChatEvent(
        QBChatEvents.RECEIVED_NEW_MESSAGE,
        (data) async {
          Map<String, Object> map = new Map<String, dynamic>.from(data);
          String messageType = map["type"];

          if (messageType == 'RECEIVED_NEW_MESSAGE' ||
              messageType == 'FlutterQBChatChannel/RECEIVED_NEW_MESSAGE') {
            Map<String, Object> payload =
                new Map<String, dynamic>.from(map["payload"]);
            Map<String, Object> messageMap = Map.castFrom(payload);

            QBMessage message = QBMessageMapper.mapToQBDialog(messageMap);

            var senderId = payload["senderId"];
            var newmessage = FlatChatMessage(
              senderName: message.properties != null
                  ? message.properties['full_name']
                  : null,
              messageSentTime:
                  DateTime.fromMillisecondsSinceEpoch(message.dateSent),
              showDate:
                  false, //shouldShowDate(message.dateSent,prevMessage?.dateSent ?? null),
              time: getMessageTime(message.dateSent),
              date: getMessageDate(message.dateSent),
              message: payload["body"],
              messageType: senderId.toString() == this.myId.toString()
                  ? MessageType.sent
                  : MessageType.received,
              showTime: true,
            );

            addMessageToStream(newmessage, message.dialogId);
            globalStream.add(message);
          }
        },
      );
    } on PlatformException catch (e) {
      print(e.code);
    }
  }

  Future<String> getImageUrl(uid) async {
    try {
      String url = await QB.content.getPrivateURL(uid);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        var blob = jsonResponse['blob'];
        String imageid = blob['uid'];

        return 'https://s3.amazonaws.com/qbprod/' + imageid;
      } else {
        print('Request failed with status: ${response.statusCode}.');
        return null;
      }
      // print('rprivate url : ' + url);
      // return url;
    } on PlatformException catch (e) {
      print(e);
      // Some error occured, look at the exception message for more details
      return null;
    }
  }

  Future<List<FlatChatMessage>> getMyMessages() async {
    try {
      var newMessages = List<FlatChatMessage>();
      var messages = await QB.chat
          .getDialogMessages(openedChatId, markAsRead: true, limit: 200);
      //for (var message in messages) {
      for (var i = 0; i < messages.length; i++) {
        var message = messages[i];
        var prevMessage = i > 0 ? messages[i - 1] : null;
        var senderId = message.senderId;
        print(message.properties);
        var newmessage = FlatChatMessage(
          senderName: message.properties['full_name'] != null
              ? message.properties['full_name']
              : '',
          messageSentTime:
              DateTime.fromMillisecondsSinceEpoch(message.dateSent),
          showDate:
              shouldShowDate(message.dateSent, prevMessage?.dateSent ?? null),
          time: getMessageTime(message.dateSent),
          date: getMessageDate(message.dateSent),
          message: message.body,
          messageType: senderId.toString() == this.myId.toString()
              ? MessageType.sent
              : MessageType.received,
          showTime: true,
        );
        newMessages.add(newmessage);
      }
      return newMessages;
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  joinGroupChat(dialogId) async {
    try {
      await QB.chat.joinDialog(dialogId);
    } catch (e) {
      print(e.toString());
      // Some error occured, look at the exception message for more details
    }
  }

  leavDialog(dialogId) async {
    try {
      await QB.chat.leaveDialog(dialogId);
    } catch (e) {
      print(e.toString());
      // Some error occured, look at the exception message for more details
    }
  }

  sendMessage(roomId, body, {List<QBAttachment> attachment}) async {
    try {
      await QB.chat.sendMessage(roomId,
          body: body,
          attachments: attachment,
          markable: false,
          saveToHistory: true);
    } catch (e) {
      print(e.toString());
      // Some error occured, look at the exception message for more details
    }
  }

  Future<QBMessage> sendImage(url) async {
    try {
      QBFile file = await QB.content.upload(url, public: true);
      int id = file.id;
      String contentType = file.contentType;
      print('file id : ' + file.id.toString());

      QBAttachment attachment = new QBAttachment();
      attachment.id = id.toString();
      attachment.contentType = contentType;

      QBMessage message = new QBMessage();
      List<QBAttachment> attachmentsList = new List();
      attachmentsList.add(attachment);

      message.attachments = attachmentsList;
      return message;

      // Send a message logic
    } on PlatformException catch (e) {
      print(e);
      return null;
      // Some error occured, look at the exception message for more details
    }
  }

  Future<void> _showMyDialog(dynamic sessionMap, myID, context) async {
    String sessionId = sessionMap["id"];
    int initiatorId = sessionMap["initiatorId"];
    
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xffc02e2f),
              child: Icon(
                Icons.videocam,
                size: 40,
                color: Colors.white,
              )),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'You have video call',
                  // AppLocalizations.of(context)
                  //     .translate('DeleteDiscussionPoint'),
                  style: const TextStyle(
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
                'Decline',
                // AppLocalizations.of(context).translate('No'),
                style: const TextStyle(
                    color: const Color(0xffc02e2f),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () {
                isPresentingAlert = false;
                rejectVideoCall(sessionId);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'Answer',
                //AppLocalizations.of(context).translate('Yes'),
                style: const TextStyle(
                    color: const Color(0xff3c84f2),
                    fontWeight: FontWeight.w500,
                    fontFamily: "Inter",
                    fontStyle: FontStyle.normal,
                    fontSize: 16.5),
              ),
              onPressed: () async {
                await handlePermissions();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VideoChatView(
                            dialogId: sessionId,
                            opponentId: initiatorId,
                            userId: myID,
                          )),
                );
                isPresentingAlert = false;
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> handlePermissions() async {
    var status = await cameraPermission.status;
    if (status != PermissionStatus.granted) {
      await cameraPermission.request();
    }
    var micper = await micPermission.status;
    if (micper != PermissionStatus.granted) {
      micPermission.request();
    }
    return Future.value();
  }

  rejectVideoCall(String sessionid) async {
    try {
       await QB.webrtc.reject(sessionid, userInfo: {});
    } on PlatformException catch (e) {
      print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }
  }

  initVideo(context) async {
    print('****************** INIT CHAT  ****************');
    var _prefs = await SharedPreferences.getInstance();
    final SharedPreferences prefs =  _prefs;
    var myID = prefs.getInt("userID");
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.CALL, (data) {
        print('******** new Call ******');
        Map<String, Object> payloadMap =
            new Map<String, Object>.from(data["payload"]);
        Map<String, Object> sessionMap =
            new Map<String, Object>.from(payloadMap["session"]);
        print(sessionMap);
        if (!isPresentingAlert) {
          _showMyDialog(sessionMap, myID, context);
          isPresentingAlert = true;
        }
      });
    } on PlatformException catch (e) {
      print('****************** CHAT ERROR ****************');
      print(e.code);
      print(e.details);

      // Some error occured, look at the exception message for more details
    }

//QBRTCEventTypes.CALL_END
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.CALL_END, (data) {
        print('call ended');
        isPresentingAlert = false;
      
        
        
      });
    } on PlatformException catch (e) {
      print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }

//QBRTCEventTypes.REJECT
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.REJECT, (data) {
        print('call reject');
        //int userId = data["payload"]["userId"];
      });
    } on PlatformException catch (e) {
      print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }

//QBRTCEventTypes.ACCEPT
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.ACCEPT, (data) {
        print('chat video accept ********');
        //int userId = data["payload"]["userId"];
      });
    } on PlatformException catch (e) {
       print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }

//QBRTCEventTypes.HANG_UP
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.HANG_UP, (data) {
        isPresentingAlert = false;
        if(Navigator.canPop(context)){
          Navigator.pop(context);
        }
        print('call hangup');
        //int userId = data["payload"]["userId"];
      });
    } on PlatformException catch (e) {
       print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }

//QBRTCEventTypes.RECEIVED_VIDEO_TRACK
    try {
      await QB.webrtc.subscribeRTCEvent(QBRTCEventTypes.RECEIVED_VIDEO_TRACK,
          (data) {
        print('chat video track********');
        // Map<String, Object> payloadMap =
        //     new Map<String, Object>.from(data["payload"]);
        // int opponentId = payloadMap["userId"];
      });
    } on PlatformException catch (e) {
       print(e.code);
      print(e.details);
      // Some error occured, look at the exception message for more details
    }
  }
}
