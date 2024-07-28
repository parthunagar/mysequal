import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/shared_widgets.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class CodeAuthPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  @override
  CodeAuthPage({this.verificationId, this.phoneNumber});

  @override
  _CodeAuthPageState createState() => _CodeAuthPageState();
}

class _CodeAuthPageState extends State<CodeAuthPage> {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  double screenWidth = 40;
  Timer _timer;
  int _start = 60;
  bool isResending = false;
  StreamController _controller = StreamController<int>();
  String errorMessage;

  onAuthenticationSuccessful(AuthCredential auth) {
    print(auth);
    Future.delayed(Duration(milliseconds: 500), () {
      FocusScope.of(context).unfocus();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  signInWithCrid(AuthCredential authCredential) async {
    var firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.signInWithCredential(authCredential).catchError((error) {
      print(error);
      setState(() {
        errorMessage = 'Invalid verification code';
      });
    }).then((UserCredential value) {
      if (value != null) {
        // setState(() {});
        onAuthenticationSuccessful(authCredential);
      } else {
        print('error');
      }
    }).catchError((error) {
      print('error' + error.toString());
      setState(() {
        errorMessage = 'Invalid verification code';
      });
      // setState(() {});
    });
  }

  _verificationCode(code) {
    ////////////////////
    /// show home page
    ///
    // _showHomePage();
    // return;
    AuthCredential drids = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: code);
    signInWithCrid(drids);
  }

  Widget darkRoundedPinPut() {
    BoxDecoration pinPutDecoration = BoxDecoration(
      color: Color(0xfff4f5f9),
      borderRadius: BorderRadius.circular(screenWidth),
    );
    return PinPut(
      eachFieldWidth: screenWidth,
      eachFieldHeight: screenWidth,
      fieldsCount: 6,
      focusNode: _pinPutFocusNode,
      controller: _pinPutController,
      onSubmit: (String pin) => _verificationCode(pin),
      submittedFieldDecoration: pinPutDecoration,
      selectedFieldDecoration: pinPutDecoration,
      followingFieldDecoration: pinPutDecoration,
      pinAnimationType: PinAnimationType.scale,
      textStyle: Theme.of(context).textTheme.headline5,
      fieldsAlignment: MainAxisAlignment.spaceBetween,
      //obscureText: '*',
    );
  }

  getScreenWidth() {
    final Size _mediaQueryData = window.physicalSize;
    final _screenWidth = _mediaQueryData.height > 1000
        ? _mediaQueryData.width / 3
        : _mediaQueryData.width / 2;
    setState(() {
      screenWidth = (_screenWidth - 30) / 6;
    });
  }

  @override
  void initState() {
    getScreenWidth();
    _pinPutFocusNode.requestFocus();
    updateFlag();
    super.initState();
  }

  updateFlag() async {
    var pref = await SharedPreferences.getInstance();
    pref.setBool('hasToken', true);
  }

  @override
  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  void startTimer() {
    print('start timer');
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      print('*********');
      if (_start < 1) {
        setState(() {
          isResending = false;
          _controller.add(1);
          _timer.cancel();
          _controller.close();
        });

        return;
      }
      print('timer ++');
      _start--;
      _controller.add(1);
    });
  }

  codeSent(String verificationId, [int forceResendingToken]) async {
    var pref = await SharedPreferences.getInstance();
    pref.setBool('hasToken', true);
    print('code sent');
    //this.actualCode = verificationId;
  }

  codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
    if (mounted) {
      setState(() {
        print('^^^^^^^^^^^^^^^^#####################^^^^^^^^^^^^^^^^');
      });
    }
  }

  verificationCompleted(AuthCredential credential) async {
    print('verificationCompleted');
    // _showHomePage();
  }

  verificationFailed(authException) {
    print('codeAutoRetrievalTimeout ' + authException.code);
    print(authException.message);
    setState(() {});
  }

  _resendCode() {
    startTimer();
    // return;
    var firebaseAuth = FirebaseAuth.instance;
    firebaseAuth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = 896; //MediaQuery.of(context).size.height;
    //screenWidth = 45;//(MediaQuery.of(context).size.width - 40) / 6;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          HeaderViewWidget(
            title: AppLocalizations.of(context).translate('WelcomeBack'),
            subtitle: AppLocalizations.of(context).translate('CopyCode'),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 90,
            padding: EdgeInsets.all(8),
            child: darkRoundedPinPut(),
          ),
          errorMessage != null
              ? Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontFamily: 'Inter'),
                  ),
                )
              : Container(),
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: () {
              if (isResending) {
                setState(() {
                  isResending = true;
                  _resendCode();
                });
              }
            },
            child: Row(
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('DidNotGetCode'),
                  style: TextStyle(
                    color: Color(0xff00183c),
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                isResending
                    ? StreamBuilder(
                        stream: _controller.stream.asBroadcastStream(),
                        builder: (cnx, snap) {
                          print('snap shot');
                          print(snap.data);
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Text(
                              '60',
                              style: TextStyle(
                                color: Color(0xff00183c),
                                fontSize: 17,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          if (snap.data != null) {
                            return Text(
                              '$_start',
                              style: TextStyle(
                                color: Color(0xff00183c),
                                fontSize: 17,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          return Text('');
                        },
                      )
                    : Text(
                        AppLocalizations.of(context).translate('TryAgain'),
                        style: TextStyle(
                          color: Color(0xff00183c),
                          fontSize: 17,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      )
              ],
            ),
          ),
          Spacer(),
          SizedBox(
            height: screenHeight * 0.44,
            child: BackGroundView(),
          )
        ],
      ),
    );
  }
}
