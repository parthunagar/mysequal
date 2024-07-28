import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/views/auth_process/code_auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peloton/widgets/shared_widgets.dart';

class LogInWidget extends StatefulWidget {
  @override
  _LogInWidgetState createState() => _LogInWidgetState();
}

class _LogInWidgetState extends State<LogInWidget> {
  String langVal = 'en';
  Color buttonColor = Colors.grey;

  TextEditingController _textController = TextEditingController();
  //final FocusNode focusNode = FocusNode();
  String errorMessgage;
  bool isSending = false;
  String phoneNumber;
  String phoneIsoCode;
  bool validPhonenumber = false;
  String confirmedNumber = '';
  PhoneNumber myNumber;

  _showCodePage(String verifcationId) {
    print('showcode page');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CodeAuthPage(
          verificationId: verifcationId,
          phoneNumber: myNumber.phoneNumber,
        ),
      ),
    );
  }

  // _showHomePage() {
  //   print('auth completed');
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => WelcomeScreenWidget()),
  //     (Route<dynamic> route) => false,
  //   );
  // }

  codeSent(String verificationId, [int forceResendingToken]) async {
    print('code sent');
    //this.actualCode = verificationId;
    _showCodePage(verificationId);
    setState(() {
      isSending = false;
    });
  }

  codeAutoRetrievalTimeout(String verificationId) {
    print('codeAutoRetrievalTimeout');
    if (mounted) {
      setState(() {
        print('^^^^^^^^^^^^^^^^#####################^^^^^^^^^^^^^^^^');
        isSending = false;
      });
    }
  }

  verificationFailed(authException) {
    print('verificationFailed ' + authException.code);
    print(authException.message);
    print('******');
    print(authException.code);
    print(authException);
    
    
    var message = '';
    switch (authException.code) {
      case 'invalidPhoneNumber':
        message = AppLocalizations.of(context).translate('invalidPhoneNumber');
        break;
      case 'invalidCredential':
        message = AppLocalizations.of(context).translate('invalidPhoneNumber');
        break;
    }

    setState(() {
      errorMessgage = message;
      isSending = false;
    });
  }

  verificationCompleted(AuthCredential auth) {
    print('verificationCompleted');
    //_showHomePage();
  }

  //_authCredential = auth;
  initfirebase() {}
  @override
  initState() {
    initfirebase();
    //focusNode.requestFocus();
    super.initState();
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    super.dispose();
  }

  String initialCountry = 'IL';
  PhoneNumber number = PhoneNumber(isoCode: 'IL');
  @override
  Widget build(BuildContext context) {
    //MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              HeaderViewWidget(
                title: AppLocalizations.of(context).translate('WelcomeBack'),
                subtitle:
                    AppLocalizations.of(context).translate('YourPhoneNumber'),
              ),
              Container(
                margin: EdgeInsetsDirectional.only(
                  top: 15,
                  end: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.only(
                      topEnd: Radius.circular(80),
                      bottomEnd: Radius.circular(80)),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x1a000000),
                        offset: Offset(0, 0),
                        blurRadius: 50,
                        spreadRadius: 1)
                  ],
                  color: Colors.white,
                ),
                //padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 2,
                    ),
                    Flexible(
                      child: InternationalPhoneNumberInput(
                        //  autoFocus: true,
                        // focusNode: focusNode,
                        textStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontFamily: 'Inter'),
                        selectorTextStyle:
                            TextStyle(fontSize: 17, fontFamily: 'Inter'),
                        onInputChanged: (PhoneNumber number) {
                          print(number.phoneNumber);
                          myNumber = number;
                        },
                        onInputValidated: (bool value) {
                          print('on validation');
                          if (value != validPhonenumber) {
                            setState(() {
                              validPhonenumber = value;
                            });
                          }
                        },
                        errorMessage: 'incorrect phone number',
                        selectorType: PhoneInputSelectorType.DIALOG,
                        countrySelectorScrollControlled: true,
                        ignoreBlank: false,
                        autoValidate: false,
                        initialValue: number,

                        inputDecoration: new InputDecoration(
                          hintStyle: TextStyle(color: Colors.grey),
                          labelStyle: TextStyle(fontSize: 12),
                          hintText: AppLocalizations.of(context)
                              .translate('EnterPhone'),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        textFieldController: _textController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                      child: FlatButton(
                        padding: EdgeInsets.zero,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () async {
                          if (isSending) return;
                          ////////////////
                          /// show crid page
                          ///
                          ///
                          ///
                          ///
                          //_showCodePage('1');
                          //return;

                          print('login with ' + myNumber.phoneNumber);

                          setState(() {
                            errorMessgage = null;
                            isSending = true;
                          });

                          var firebaseAuth = FirebaseAuth.instance;
                          firebaseAuth.verifyPhoneNumber(
                              phoneNumber: myNumber.phoneNumber,
                              timeout: Duration(seconds: 60),
                              verificationCompleted:
                                  (PhoneAuthCredential credential) async {
                                // ANDROID ONLY!
                                if (Platform.isIOS) {
                                  return;
                                }
                                // Sign the user in (or link) with the auto-generated credential
                                await firebaseAuth
                                    .signInWithCredential(credential);
                                Future.delayed(Duration(milliseconds: 500), () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                });
                              },
                              verificationFailed: verificationFailed,
                              codeSent: codeSent,
                              codeAutoRetrievalTimeout:
                                  codeAutoRetrievalTimeout);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: validPhonenumber
                                ? Theme.of(context).accentColor
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(36),
                          ),
                          padding: EdgeInsets.all(0),
                          margin: EdgeInsets.all(0),
                          child: isSending
                              ? Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 40,
                                ),
                          // child: Image.asset(
                          //   validPhonenumber
                          //       ? 'assets/add_blue.png'
                          //       : 'assets/add_grey.png',
                          //   matchTextDirection: true,
                          //   fit: BoxFit.cover,
                          //   width: 90,
                          //   height: 95,
                          // ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              errorMessgage != null
                  ? Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            errorMessgage,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  : Text(' '),
              Expanded(
                child: BackGroundView(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
