import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/widgets/bottom_radio_picker.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:peloton/widgets/error_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class RegisterNewUserwidget extends StatefulWidget {
  final Function() notifyParent;
  final PelotonUser user;
  @override
  RegisterNewUserwidget({this.notifyParent, this.user});

  @override
  _RegisterNewUserwidgetState createState() => _RegisterNewUserwidgetState();
}

class _RegisterNewUserwidgetState extends State<RegisterNewUserwidget> {
  final _formKey = GlobalKey<FormState>();
  String firstName;
  String lastName;
  String gender;

  bool termsAgree = false;

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var genderController = TextEditingController();

  String getGender(String value) {
    var status = AppLocalizations.of(context).translate("Genders");

    final decodedStatus = json.decode(status.replaceAll("\'", "\""));
    return decodedStatus[value];
  }

  @override
  void initState() {
    if (widget.user != null) {
      firstNameController =
          TextEditingController(text: widget.user.firstName ?? '');
      lastNameController =
          TextEditingController(text: widget.user.lastName ?? '');
      genderController = TextEditingController(text: widget.user.gender ?? '');
    }
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  openTermsOfUse() async {
    var url = 'https://www.sequel.care/terms-of-use';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      var urlnew = 'https://www.google.com/search?q=$url';
      await launch(urlnew);
      //throw 'Could not launch ${widget.task.url}';
    }
  }

  openPrivacyPolicy() async {
     var url = 'https://www.sequel.care/privacy-policy';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      var urlnew = 'https://www.google.com/search?q=$url';
      await launch(urlnew);
      //throw 'Could not launch ${widget.task.url}';
    }
  }

  openMoreInfo() async {
    var url = 'https://www.sequel.care/terms-info';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      var urlnew = 'https://www.google.com/search?q=$url';
      await launch(urlnew);
      //throw 'Could not launch ${widget.task.url}';
    }
  }

  Future updateUser(context) async {
    var userterms = {'date': Timestamp.now(), 'did_confirm': true};
    AuthProvider.of(context).auth.updateUserDoc('user_terms', userterms);
    if (gender != null) {
      AuthProvider.of(context).auth.updateUserDoc('gender', gender);
    }
    widget.notifyParent();
  }

  Future createUser(context) async {
    User user = FirebaseAuth.instance.currentUser;
    String patientId = user.uid;
    PhoneNumber phone =
        await PhoneNumber.getRegionInfoFromPhoneNumber(user.phoneNumber);

    String userGender = this.gender;
    String userEmail = user.email ?? "";
    CollectionReference patientsRef =
        FirebaseFirestore.instance.collection('patients');
    print(phone.dialCode);
    print(phone.parseNumber());
    Map<String, dynamic> userMap = {
      'comorbidities': null,
      'date_of_birth': null,
      'gender': userGender,
      'email_address': userEmail,
      'first_name': this.firstName,
      'last_name': this.lastName,
      'marital_status': 'single',
      'orginizations': [],
      'permitted_users': null,
      'phone': '0' + phone.parseNumber(),
      'phone_prefix': '+' + phone.dialCode,
      'user_terms': {'date': Timestamp.now(), 'did_confirm': true}
    };
    await patientsRef.doc(patientId).set(userMap);
    await AuthProvider.of(context).auth.getUserDocument(patientId);
    var pref = await SharedPreferences.getInstance();

    pref.setBool('hasToken', true);

    pref.setBool('newUser', true);

    //_showHomePage();
    widget.notifyParent();
  }

  void showEditGenderOptions(value) async {
    var genders = AppLocalizations.of(context).translate("Genders");

    final decodedGenders = json.decode(genders.replaceAll("\'", "\""));
    List<String> genderlist = [];
    decodedGenders.entries.forEach((e) => genderlist.add(e.value.toString()));

    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return BottomRadioListWidget(
            data: genderlist,
            title: AppLocalizations.of(context).translate("Gender"),
            defaultValue: value,
          );
        },
      ),
    );
    var genderKey = decodedGenders.keys
        .firstWhere((k) => decodedGenders[k] == result, orElse: () => null);

    setState(
      () {
        gender = genderKey;

        genderController.text = result;
      },
    );
  }

  showTermsError() async {
    await showDialog(
        context: context,
        child: ErrorAlert(
          title: AppLocalizations.of(context).translate("AgreeToTermsError"),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          autovalidate: true,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              RegisterUserHeader(
                hasUser: widget.user != null,
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                                text: AppLocalizations.of(context)
                                    .translate('FirstName')),
                            TextSpan(
                                style: const TextStyle(
                                    color: const Color(0xffc02e2f),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                                text: " *")
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: TextFormField(
                        key: UniqueKey(),
                        controller: firstNameController,
                        validator: (value) {
                          if (value.length > 0) {
                            return null;
                          } else {
                            return AppLocalizations.of(context)
                                .translate('EnterFirstName');
                          }
                        },
                        onSaved: (value) {
                          this.firstName = value;
                        },
                        onChanged: (value) {},
                        autovalidate: false,
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('EnterFirstName'),
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                width: 0.5,
                                color: Colors.grey.withOpacity(0.5)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.red.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                                text: AppLocalizations.of(context)
                                    .translate('LastName')),
                            TextSpan(
                                style: const TextStyle(
                                    color: const Color(0xffc02e2f),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0),
                                text: " *")
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: TextFormField(
                        key: UniqueKey(),
                        controller: lastNameController,
                        validator: (value) {
                          if (value.length > 0) {
                            return null;
                          } else {
                            return AppLocalizations.of(context)
                                .translate('EnterLasttName');
                          }
                        },
                        onSaved: (value) {
                          this.lastName = value;
                        },
                        onChanged: (value) {},
                        autovalidate: false,
                        autocorrect: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('EnterLasttName'),
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                width: 0.5,
                                color: Colors.grey.withOpacity(0.5)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.red.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: Row(
                        children: <Widget>[
                          Text(
                            AppLocalizations.of(context).translate('Gender') +
                                ':',
                            style: const TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                      child: TextFormField(
                        enableInteractiveSelection: false,
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          showEditGenderOptions(null);
                        },
                        keyboardType: null,
                        key: UniqueKey(),
                        autofocus: false,
                        autocorrect: false,
                        onSaved: (value) {},
                        controller: genderController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .translate('SelectGender'),
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white70,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5),
                                width: 0.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                width: 0.5,
                                color: Colors.grey.withOpacity(0.5)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
                          Checkbox(
                            value: termsAgree,
                            onChanged: (value) {
                              print(value);
                              setState(() {
                                termsAgree = value;
                              });
                            },
                          ),
                          Flexible(
                            child: RichText(
                              maxLines: 2,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      style: const TextStyle(
                                          color: const Color(0xff00183c),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Inter",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 13.0),
                                      text: AppLocalizations.of(context)
                                          .translate('termInfo')),
                                  TextSpan(
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          openTermsOfUse();
                                        },
                                      style: const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Inter",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 13.0),
                                      text: AppLocalizations.of(context)
                                          .translate('TermsOfUse'))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(15),
                          width: double.infinity,
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                _formKey.currentState.save();
                                print('is valid');
                                print('***');
                                if (termsAgree) {
                                  if (widget.user != null) {
                                    updateUser(context);
                                  } else {
                                    createUser(context);
                                  }
                                } else {
                                  showTermsError();
                                }
                              }
                            },
                            child: Container(
                              width: 250,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: const Color(0xff3c84f2),
                              ),
                              child: Center(
                                child: Text(
                                  widget.user != null
                                      ? AppLocalizations.of(context).translate(
                                          'SaveInfo',
                                        )
                                      : AppLocalizations.of(context).translate(
                                          'CreateAccountButton',
                                        ),
                                  style: const TextStyle(
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w700,
                                      fontFamily: "Inter",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 17.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom:12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13.0),
                              text: AppLocalizations.of(context)
                                  .translate('seeMoreInfoTerms'),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  openMoreInfo();
                                },
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13.0),
                              text:
                                  AppLocalizations.of(context).translate('Here'),
                            ),
                            TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13.0),
                              text: ',',
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  openPrivacyPolicy();
                                },
                              style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 13.0),
                              text: AppLocalizations.of(context)
                                  .translate('PrivacyPolicy'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterUserHeader extends StatelessWidget {
  final bool hasUser;
  @override
  RegisterUserHeader({this.hasUser});
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        //height: 90,
        padding: EdgeInsets.only(left: 25, right: 25, bottom: 20, top: 0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.zero,
            topRight: Radius.zero,
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
          color: Color(0xff3c84f2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                hasUser
                    ? AppLocalizations.of(context).translate('ConfirmInfo')
                    : AppLocalizations.of(context).translate('RegisterUser'),
                style: Theme.of(context).primaryTextTheme.headline3,
                textAlign: TextAlign.start)
          ],
        ),
      );
    });
  }
}
