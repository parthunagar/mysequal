import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/notifications_manager.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/views/add_new_story/add_new_story.dart';
import 'package:peloton/views/chat/chat_page.dart';
import 'package:peloton/views/goals_page/my_goals.dart';
import 'package:peloton/views/home_page/home_page.dart';
import 'package:peloton/views/my_profile/my_privacy.dart';
import 'package:peloton/views/my_profile/my_profile.dart';
import 'package:peloton/widgets/add_actions.dart';
import 'package:quickblox_sdk/auth/module.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_filter.dart';
import 'package:quickblox_sdk/models/qb_session.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat/chat_manager.dart';
import 'chat/talk_page.dart';
import 'log_book/log_book_container.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'my_profile/my_progress/my_progress.dart';

class HomePagecontainer extends StatefulWidget {
  @override
  _HomePagecontainerState createState() => _HomePagecontainerState();
}

class _HomePagecontainerState extends State<HomePagecontainer>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _selectePage = 0;
  bool overlayVisible = false;
  AnimatedIconData animatedIcon = AnimatedIcons.add_event;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static const authenticateChannel =
      const MethodChannel('com.neura.flutterApp/authenticate');

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;

      print('link');
      print(deepLink);
      if (deepLink.path.contains('privacy')) {
        showConfirmPage();
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if ((deepLink != null) && deepLink.path.contains('privacy')) {
      showConfirmPage();
    }
  }

  showConfirmPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return MyPrivacyWidget();
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AuthProvider.of(context).auth.updateUserDoc('connection_status',
            {"is_online": true, "last_seen": Timestamp.now()});
        print("app in resumed  ************");
        updateToken();
        if (this.mounted) {
          setState(() {
            FocusManager.instance.primaryFocus.unfocus();
          });
        }
        reconnectChat();
        break;
      case AppLifecycleState.inactive:
        AuthProvider.of(context).auth.updateUserDoc('connection_status',
            {"is_online": false, "last_seen": Timestamp.now()});
        print("app in inactive");
        try {
          QB.webrtc.release();
        } on PlatformException catch (e) {
          print(e.message);
        }
        break;
      case AppLifecycleState.paused:
        print("app in paused");

        dissconnectChat();
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
  }

  dissconnectChat() async {
    var result = await QB.chat.isConnected();
    if (result) {
      try {
        await QB.chat.disconnect();
      } on PlatformException catch (e) {
        print(e.code);
        print(e.message);
        print(e.details);
      }
    }
  }

  reconnectChat() async {
    print('check chat connection -- app resume');
    var connected = await QB.chat.isConnected();
    if (!connected) {
      print(
          '################################ chat reconencted app resume ################################');
      var user =
          PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
      if (user.chatParams.userName != null &&
          user.chatParams.userName.length > 0) {
        try {
          await QB.auth.login(
              user.chatParams.userName.toString(), user.chatParams.password);
        } on PlatformException catch (e) {
          print("quick blox login exeption reconnect app resume");
          print(e.message);
          print(e.code);
        }
        try {
          await QB.webrtc.init();
          print(
              '################################ reconnect webRTC  #########################################');
          print("quick blox connect  webrtc");

          ChatManager.instance.initVideo(context);
        } on PlatformException catch (e) {
          print("quick blox connect exeption webrtc");
          print(e.message);
          print(e.code);

          // Some error occured, look at the exception message for more details
        }
      }
    }
  }

  updateToken() async {
    // final SharedPreferences prefs = await _prefs;
    // var token = prefs.getString('neuraAccessToken');
    // if (token != null) {
    //   print('did update neura token');
    //   AuthProvider.of(context).auth.updateUserDoc('neura_token', token);
    // }
    authenticateToNeura();
  }

  // Future<void> runFireBaseIos() async {
  //   firebase.configure();
  //   var token = await firebase.getToken();

  //   if (token != null) {
  //     print('did update neura token');
  //     AuthProvider.of(context).auth.updateUserDoc('firebase_token', token);
  //   }
  //   return;
  // }

  runFireBase() async {
    await PushNotificationsManager.instance.init();

    var token =
        await PushNotificationsManager.instance.firebaseMessaging.getToken();
    if (token != null) {
      print('did update firebase token');
      AuthProvider.of(context).auth.updateUserDoc('firebase_token', token);
    }
    _firebaseMsgListener();

    // connector.token.addListener(() {
    //   print('firebase token');
    //   print(connector.token.value);
    //   if (connector.token.value != null)
    //     AuthProvider.of(context)
    //         .auth
    //         .updateUserDoc('firebase_token', connector.token.value);
    // });
  }

  void _firebaseMsgListener() {
    Future.delayed(Duration(seconds: 1), () {
      PushNotificationsManager.instance.firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print("=====>on message $message");
        },
        onResume: (Map<String, dynamic> message) async {
          print("=====>onResume ${message['data']}");
          onPush('onResume', message);
        },
        onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
        onLaunch: (Map<String, dynamic> message) async {
          print("=====>onLaunch $message");

          onPush('onLaunch', message);
        },
      );
    });
  }

  Future<dynamic> onPush(String name, Map<String, dynamic> data) async {
    Map<String, dynamic> pushdata;
    if (Platform.isIOS) {
      pushdata = data;
    } else {
      pushdata = Map<String, dynamic>.from(data['data']);
    }

    print('on push');
    print(name);
    print(pushdata);

    if (pushdata['patientid'] != null && pushdata['call_to_action'] != null) {
      if (['onLaunch', 'onResume'].contains(name)) {
        Future.delayed(Duration(milliseconds: 200), () {
          showPage(pushdata['call_to_action']);
        });
      }
    } else {
      //chat noti
      Navigator.of(context).popUntil((route) => route.isFirst);
      openChat(pushdata['dialog_id']);
    }

    return Future.value();
  }

  showPage(String name) async {
    switch (name) {
      case 'journal':
        print('journal');
        setState(() {
          _selectePage = 4;
          _tabController.index = 4;
        });
        break;
      case 'tasks':
        print('tasks');
        setState(() {
          _selectePage = 0;
          _tabController.index = 0;
        });

        break;
      case 'feed':
        print('feed');
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return AddNewStoryWidget();
            },
          ),
        );
        break;
      case 'goals':
        print('goals');
        setState(() {
          _selectePage = 1;
          _tabController.index = 1;
        });
        break;
      default:
        print('General');
        setState(() {
          _selectePage = 0;
          _tabController.index = 0;
        });
    }
  }

  openChat(dialogid) async {
    var connected = await QB.chat.isConnected();
    if (!connected) {
      initChat();
    }

    var user =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    var filter = QBFilter();
    filter.field = QBChatDialogFilterFields.ID;
    filter.value = dialogid;
    filter.operator = QBChatDialogFilterOperators.ALL;
    QBDialog dialog;
    var dialogs = await QB.chat.getDialogs(filter: filter);
    for (var temp in dialogs) {
      if (temp.id == dialogid) {
        dialog = temp;
      }
    }
    if (dialog == null) {
      return;
    }
    setState(() {
      _selectePage = 3;
      _tabController.index = 3;
    });
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return ChatPage(dilaogId: dialog.id, name: dialog.name, id: user.id);
        },
      ),
    );
  }

  @override
  void initState() {
    initDynamicLinks();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthProvider.of(context).auth.updateUserDoc('connection_status',
          {"is_online": true, "last_seen": Timestamp.now()});
      Future.delayed(Duration(milliseconds: 500), () async {
        initChat();
        // if (Platform.isIOS) {
        // await runFireBaseIos();
        //   connector = createPushConnector();
        //   connector.configure(
        //     onLaunch: (data) => onPush('onLaunch', data),
        //     onResume: (data) => onPush('onResume', data),
        //     onMessage: (data) => onPush('onMessage', data),
        //     onBackgroundMessage: _onBackgroundMessage,
        //   );

        //   connector.token.addListener(() {
        //     print('firebase token');
        //     print(connector.token.value);
        //     if (connector.token.value != null)
        //       AuthProvider.of(context)
        //           .auth
        //           .updateUserDoc('firebase_token', connector.token.value);
        //   });
        // } else {
        //   runFireBase();
        // }
        runFireBase();
        authenticateToNeura();
      });
    });
    _tabController = TabController(vsync: this, length: 5, initialIndex: 0);
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    authenticateChannel.setMethodCallHandler((call) => updateToken());
    super.initState();
  }

  Future authenticateToNeura() async {
    print('************     called auth neura        ************');

    try {
      var result = await authenticateChannel.invokeMethod('authenticate');
      print('************     called auth neura    $result    ************');
      AuthProvider.of(context).auth.updateUserDoc('neura_token', result);
    } on PlatformException catch (e) {
      print(e.message);
      print(e.code);
    }
  }

  TabController _tabController;

  void onTabTapped(int index) {
    if (index == 2) {
      return;
    }
    setState(() {
      _selectePage = index;
      _tabController.index = index;
    });
    switch(index){
      case 0:
      AnalyticsManager.instance.addEvent(AnalytictsActions.tabbarHome, null);
      break;
      case 1:
      AnalyticsManager.instance.addEvent(AnalytictsActions.tabbarGoal, null);
      break;
      case 3:
      AnalyticsManager.instance.addEvent(AnalytictsActions.tabbatTalk, null);
      break;
      case 4:
      AnalyticsManager.instance.addEvent(AnalytictsActions.tabbarJournal, null);
      break;
      default :
      break;


    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  initChat({dialog}) async {
    if (!mounted) {
      return;
    }
    var user =
        PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt("userID", user.chatParams.chatUserId);
    //prod chat
    const String APP_ID = "86505";
    const String AUTH_KEY = "fLy3xpPc7k9pjQy";
    const String AUTH_SECRET = "gnOuKEJ-edw6cVt";
    const String ACCOUNT_KEY = "WLCiAAbymSju_bbpQG7y";

    //dev chat

    // const String APP_ID = "85623";
    // const String AUTH_KEY = "8Wca5YTndBHy4Np";
    // const String AUTH_SECRET = "pgcHaEUVygDz58F";
    // const String ACCOUNT_KEY = "gxukz6rS7dUCgyNnxSp_";

    try {
      await QB.settings.init(APP_ID, AUTH_KEY, AUTH_SECRET, ACCOUNT_KEY,
          apiEndpoint: null, chatEndpoint: null);

      print('did init chat');
    } on PlatformException catch (e) {
      print("quick blox exeption");
      print(e.message);
      print(e.code);
      // Some error occured, look at the exception message for more details
    }

    await Future.delayed(Duration(milliseconds: 1500), () {
      print('******* done delay *******');
    });

    try {
      await QB.settings.enableCarbons();
      await QB.settings.initStreamManagement(10, autoReconnect: true);
    } on PlatformException catch (e) {
      // Some error occured, look at the exception message for more details
      print(e.message);
      print(e.code);
    }
    ChatManager.instance.subscribeForNotifications();
    try {
      var connected = await QB.chat.isConnected();
      if (connected) {
        //chat connected just init webrtc
        try {
          await QB.webrtc.init();
          print(
              '################################ webRTC  #########################################');
          print("quick blox connect  webrtc");

          ChatManager.instance.initVideo(context);
        } on PlatformException catch (e) {
          print("quick blox connect exeption webrtc");
          print(e.message);
          print(e.code);

          // Some error occured, look at the exception message for more details
        }

        return;
      }
    } catch (e) {
      print('chatError');
      print('e');
    }
    if (user.chatParams.userName != null &&
        user.chatParams.userName.length > 0) {
      try {
        QBLoginResult result = await QB.auth.login(
            user.chatParams.userName.toString(), user.chatParams.password);

        QBSession qbSession = result.qbSession;
        print('chat did login ');
        print(qbSession.token);
      } on PlatformException catch (e) {
        print("quick blox login exeption");
        print(e.message);
        print(e.code);
        // Some error occured, look at the exception message for more details
      }
    }
    try {
      var result = await QB.chat.isConnected();
      if (!result) {
        await QB.chat
            .connect(user.chatParams.chatUserId, user.chatParams.password);
        print('did connect to chat');
      }
    } on PlatformException catch (e) {
      print("quick blox connect exeption");
      print(e.message);
      print(e.code);
      // Some error occured, look at the exception message for more details
    }
    QB.settings.enableAutoReconnect(true);
    if (dialog != null) {
      openChat(dialog);
    }
    try {
      await QB.webrtc.init();
      print(
          '################################ webRTC  #########################################');
      print("quick blox connect  webrtc");

      ChatManager.instance.initVideo(context);
    } on PlatformException catch (e) {
      print("quick blox connect exeption webrtc");
      print(e.message);
      print(e.code);

      // Some error occured, look at the exception message for more details
    }
  }

  String getGreeting() {
    var timeNow = DateTime.now().hour;
    if (timeNow >= 6 && timeNow < 12) {
      return AppLocalizations.of(context).translate("good morning");
    } else if (timeNow >= 12 && timeNow < 17) {
      return AppLocalizations.of(context).translate("good afternoon");
    } else if (timeNow >= 17 && timeNow < 19) {
      return AppLocalizations.of(context).translate("good evening");
    } else {
      return AppLocalizations.of(context).translate("good night");
    }
  }

  showMyProgress() {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return MyProgressWidget();
        },
      ),
    );
  }

  Widget getTitle() {
    String name =
        AuthProvider.of(context).auth.currentUserDoc['first_name'] ?? '';
    switch (_tabController.index) {
      case 0:
        // return RichText(
        //   textAlign: TextAlign.center,
        //     text: TextSpan(children: [
        //   TextSpan(
        //     text: getGreeting(),
        //     style: Theme.of(context).primaryTextTheme.headline3,
        //   ),
        //   TextSpan(text: ' '),
        //   TextSpan(text: name,style: Theme.of(context).primaryTextTheme.headline2)
        // ]));
        return Text(
          getGreeting() + ' ' + name,
          maxLines: 1,
          style: Theme.of(context).primaryTextTheme.headline3,
          textAlign: TextAlign.center,
        );
      case 1:
        return Container(
          width: double.infinity,
          child: Text(
            AppLocalizations.of(context).translate("myGoals"),
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
        );
      case 3:
        return Container(
          width: double.infinity,
          child: Text(
            'Talk',
            style: Theme.of(context).primaryTextTheme.headline3,
          ),
        );
      case 4:
        return Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate("Logbook"),
                style: Theme.of(context).primaryTextTheme.headline3,
              ),
              GestureDetector(
                onTap: showMyProgress,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      AppLocalizations.of(context).translate("MyPrgress"),
                      style: Theme.of(context).primaryTextTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                          color: Color(0x8000183c),
                          borderRadius: BorderRadius.circular(11)),
                      child: Image.asset(
                        'assets/forwardarrow.png',
                        matchTextDirection: true,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    //  return NSBaseWidget(builder: (context, sizingInformation) {

    // print("The screen size is: ${sizingInformation.localWidgetSize}");

    return Stack(
      alignment: Alignment.bottomCenter,
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: Color(0xfff4f5f9),
            extendBodyBehindAppBar: true,
            drawer: MyProfileWidget(),
            appBar: AppBar(
                actions: <Widget>[
                  SizedBox(
                    width: 20,
                  )
                ],
                centerTitle: true,
                title: getTitle(),
                elevation: 0,
                backgroundColor:
                    Theme.of(context).accentColor //Color(0xff3c84f2),
                ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Transform.scale(
              origin: Offset(0, -90),
              alignment: Alignment.topCenter,
              scale: 1.2,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return AddActionsWidget();
                      },
                    ),
                  );
                },
                child: Icon(
                  Icons.add,
                  size: 28,
                ),
                elevation: 2,
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              elevation: 40,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Color(0xff3c84f2),
              unselectedItemColor: Color(0xff003561),
              selectedFontSize: 17,
              currentIndex: _selectePage,
              key: PageStorageKey(UniqueKey()),
              items: [
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    'assets/home_copy.png',
                    height: 25,
                    width: 27,
                  ),
                  icon: Image.asset(
                    'assets/home.png',
                    height: 25,
                    width: 27,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      AppLocalizations.of(context).translate('Home'),
                      style: _selectePage == 0
                          ? Theme.of(context).primaryTextTheme.headline6
                          : Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    'assets/goals_copy.png',
                    height: 25,
                    width: 27,
                  ),
                  icon: Image.asset(
                    'assets/goals.png',
                    height: 25,
                    width: 27,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      AppLocalizations.of(context).translate('Goals'),
                      style: _selectePage == 1
                          ? Theme.of(context).primaryTextTheme.headline6
                          : Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    'assets/goals_copy.png',
                    height: 0,
                    width: 0,
                  ),
                  icon: Image.asset(
                    'assets/goals.png',
                    height: 0,
                    width: 0,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      ' ',
                      style: Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    'assets/talk_copy.png',
                    height: 25,
                    width: 27,
                  ),
                  icon: Image.asset(
                    'assets/talk.png',
                    height: 25,
                    width: 27,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      AppLocalizations.of(context).translate('Talk'),
                      style: _selectePage == 3
                          ? Theme.of(context).primaryTextTheme.headline6
                          : Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    'assets/logbook_copy.png',
                    height: 25,
                    width: 27,
                  ),
                  icon: Image.asset(
                    'assets/logbook.png',
                    height: 25,
                    width: 27,
                  ),
                  title: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      AppLocalizations.of(context).translate('Logbook'),
                      style: _selectePage == 4
                          ? Theme.of(context).primaryTextTheme.headline6
                          : Theme.of(context).primaryTextTheme.subtitle2,
                    ),
                  ),
                ),
              ],
              onTap: onTabTapped,
            ),
            body: TabBarView(
              physics: new NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                HomePageWidget(
                  controller: () {
                    setState(() {
                      _selectePage = 4;
                      _tabController.index = 4;
                    });
                  },
                  handleTap: showPage,
                ),
                MyGoals(),
                HomePageWidget(),
                TalkPage(),
                LogBookContainer(),
              ],
            ),
          ),
        ),
      ],
    );
    //});
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon'); // <- default icon name is @mipmap/ic_launcher
  var initializationSettingsIOS = IOSInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  print(
      '***************************** background message ***********************************');
  print("myBackgroundMessageHandler message: $message");
  int msgId = int.tryParse(message["data"]["user_id"].toString()) ?? 0;
  print("msgId $msgId");
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
      msgId, 'Talk', message["data"]["message"], platformChannelSpecifics,
      payload: message["data"]["data"]);
  return Future<void>.value();

  // Or do other work.
}
