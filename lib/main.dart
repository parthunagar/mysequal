import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_notifier.dart';
import 'package:peloton/managers/auth_controller.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/managers/notifications_manager.dart';
import 'package:peloton/themes/app_theme.dart';
import 'package:peloton/views/home_page_container.dart';
import 'package:peloton/views/my_profile/my_progress/my_progress.dart';
import 'package:peloton/views/on_boarding.dart';
import 'package:peloton/views/splash_screen_widget.dart';
import 'package:peloton/views/welcome_screens/new_user_welcome_screen.dart';
import 'package:peloton/views/welcome_screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'localization/app_localization.dart';
import 'package:intl/intl.dart' as intl;

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/PelotonUser.dart';
import 'views/register_new_user.dart/register_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AppLanguage appLanguage = AppLanguage();
  appLanguage.fetchLocale();
  runApp(MainApp(
    appLanguage: appLanguage,
  ));
}

class MainApp extends StatefulWidget {
  final AppLanguage appLanguage;
  MainApp({this.appLanguage});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _firebaseMessaging = PushNotificationsManager.instance.init();

  @override
  void initState() {
    //getPermession();

    //  connector.requestNotificationPermissions();
    super.initState();
  }

  // getPermession() async {
  //   _firebaseMessaging.requestNotificationPermissions();
  //   _firebaseMessaging.configure();
  // }

  refresh() {
    setState(() {});
  }

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext appcontext) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return ChangeNotifierProvider<AppLanguage>(
      create: (_) => widget.appLanguage,
      child: Consumer<AppLanguage>(
        builder: (context, model, child) {
          print("App language Changed!");
          print(widget.appLanguage.appLocal.languageCode);
          intl.Intl.defaultLocale = widget.appLanguage.appLocal.toString();

          return AuthProvider(
            auth: Auth(),
            child: MaterialApp(
              title: 'MySequel',
              theme: configureThemeData(),
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale("ar"),
                const Locale("en"),
                const Locale("he"),
              ],
              locale: widget.appLanguage.appLocal,
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
              home: Builder(
                builder: (context) {
                  print('widget.appLanguage.appLocal');
                  print(widget.appLanguage.appLocal.languageCode);
                  final BaseAuth auth = AuthProvider.of(context).auth;
                  return StreamBuilder<String>(
                    stream: auth.onAuthStateChanged,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      print('snapshot.data');
                      print(snapshot.data);
                      if (snapshot.data == null) {
                        return SplashScreenwidget();
                      }
                     // return MyProgressWidget();
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data == 'NOTCONFIRMED') {
                          var user = PelotonUser.fromJson(
                              AuthProvider.of(context).auth.currentUserDoc);
                          return RegisterNewUserwidget(
                            notifyParent: refresh,
                            user: user,
                          );
                        }
                        final bool isLoggedIn =
                            ['REGISTERED', 'LOGGEDIN'].contains(snapshot.data);
                        final bool isRegisteredUser =
                            snapshot.data == 'REGISTERED';
                        print(snapshot.data);
                        return isLoggedIn
                            ? ((isRegisteredUser)
                                ? _buildWaitingScreen()
                                : RegisterNewUserwidget(
                                    notifyParent: refresh,
                                  ))
                            : OnBoardingWidget();
                      }
                      return SplashScreenwidget();
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (_, AsyncSnapshot<SharedPreferences> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SplashScreenwidget();
        }

        if (snap.data.getBool('hasToken') == null) {
          FirebaseAuth.instance.signOut();
          snap.data.setBool('hasToken', true);
          return OnBoardingWidget();
        }
        //show welcome screen if the user has new goal
        var hasNewGoal = snap.data.getBool('hasNewGoal');
        if (hasNewGoal != null) {
          snap.data.setBool('hasNewGoal', false);
          if (hasNewGoal) {
            return WelcomeScreenWidget(
              notifyParent: refresh,
              newGoal: true,
            );
          }
        }

        if (snap.data.getBool('fistLogin') == null) {
          snap.data.setBool('fistLogin', false);
          if (snap.data.getBool('newUser') != null) {
            return NewUserWelcomeScreen(
              notifyParent: refresh,
            );
          } else {
            return WelcomeScreenWidget(
              notifyParent: refresh,
              newGoal: null,
            );
          }
        } else {
          return HomePagecontainer();
        }
      },
    );
  }
}
