import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';

import 'bottom_radio_picker.dart';

class AddPeerWidget extends StatefulWidget {
  @override
  _AddPeerWidgetState createState() => _AddPeerWidgetState();
}

class _AddPeerWidgetState extends State<AddPeerWidget> {
  final _formKey = GlobalKey<FormState>();

  String peerName;

  String email;
  String peerType;
  var peerNameController = TextEditingController();

  var emailController = TextEditingController();
  var peerTypeController = TextEditingController();
  String dropdownValue ;
  List<String> peerTypeList = ['Mother', 'Father', 'Sister'];

  showPeerTypeOptions(value) async {
    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return BottomRadioListWidget(
            data: peerTypeList,
            title: AppLocalizations.of(context).translate("Gender"),
            defaultValue: value,
          );
        },
      ),
    );
    setState(() {
      dropdownValue = result;
    });
  }

  @override
  void dispose() {
    peerNameController.dispose();

    emailController.dispose();
    peerTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.35),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(12),
              height: 600,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(16),
                  topStart: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        color: Colors.blue,
                        iconSize: 25,
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).translate('AddPeer'),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xff00183c),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  Divider(
                    endIndent: 50,
                    indent: 50,
                    thickness: 1,
                  ),
                  Form(
                    autovalidate: true,
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                            style: const TextStyle(
                                color: const Color(0xff00183c),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 18.0),
                            text: AppLocalizations.of(context)
                                    .translate('PeerName') +
                                ' ',
                          ),
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xffc02e2f),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: "*")
                        ])),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: TextFormField(
                            key: UniqueKey(),
                            controller: peerNameController,
                            validator: (value) {
                              if (value.length > 0) {
                                return null;
                              } else {
                                return AppLocalizations.of(context)
                                    .translate('EnterPeerNameErrorMessage');
                              }
                            },
                            onSaved: (value) {
                              this.peerName = value;
                            },
                            onChanged: (value) {},
                            autovalidate: false,
                            autocorrect: true,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                  .translate('EnterPeerNameHint'),
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
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    color: Colors.red.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: AppLocalizations.of(context)
                                      .translate('Email') +
                                  ' '),
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xffc02e2f),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: "*")
                        ])),
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 15),
                          child: TextFormField(
                            key: UniqueKey(),
                            controller: emailController,
                            validator: (value) {
                              if (value.length > 0) {
                                return null;
                              } else {
                                return AppLocalizations.of(context)
                                    .translate('EnterEmailErrorMessage');
                              }
                            },
                            onSaved: (value) {
                              this.email = value;
                            },
                            onChanged: (value) {},
                            autovalidate: false,
                            autocorrect: true,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)
                                  .translate('EnterEmailHintMessage'),
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
                                borderSide: BorderSide(
                                    color: Colors.grey.withOpacity(0.5)),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                    color: Colors.red.withOpacity(0.5)),
                              ),
                            ),
                          ),
                        ),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: AppLocalizations.of(context)
                                  .translate('PeerType')),
                          TextSpan(
                              style: const TextStyle(
                                  color: const Color(0xffc02e2f),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0),
                              text: "*")
                        ])),
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.3),
                              )),
                          child: ListTile(
                              title: Text(
                                dropdownValue != null ? dropdownValue : (''),
                                style: const TextStyle(
                                    color: const Color(0xff4a4a4a),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.5),
                              ),
                              onTap: () {
                                showPeerTypeOptions(dropdownValue);
                              },
                              trailing: Icon(
                                Icons.play_arrow,
                                color: Color(0xff3c84f2),
                              )),
                        ),
                        //     DropdownButtonHideUnderline(
                        //   child: DropdownButton<String>(
                        //     icon: null,
                        //     iconEnabledColor: Colors.transparent,
                        //     value: dropdownValue,
                        //     iconSize: 24,
                        //     elevation: 5,
                        //     style: TextStyle(color: Color(0xff4a4a4a)),
                        //     underline: Container(
                        //       height: 0,
                        //       color: Colors.transparent,
                        //     ),
                        //     onChanged: (String newValue) {
                        //       setState(() {
                        //         dropdownValue = newValue;
                        //       });
                        //     },
                        //     items: <String>['Add peer','Mother', 'Father', 'Sister']
                        //         .map<DropdownMenuItem<String>>((String value) {
                        //       return DropdownMenuItem<String>(
                        //         value: value,
                        //         child: Text(value),
                        //       );
                        //     }).toList(),
                        //   ),
                        // ),
                        // Container(
                        //   padding: const EdgeInsets.only(top: 10, bottom: 15),
                        //   child: TextFormField(
                        //     key: UniqueKey(),
                        //     controller: peerTypeController,
                        //     validator: (value) {
                        //       if (value.length > 0) {
                        //         return null;
                        //       } else {
                        //         return AppLocalizations.of(context)
                        //             .translate('EnterPeerType');
                        //       }
                        //     },
                        //     onSaved: (value) {
                        //       this.peerType = value;
                        //     },
                        //     onChanged: (value) {},
                        //     autovalidate: false,
                        //     autocorrect: true,
                        //     decoration: InputDecoration(
                        //       hintText: AppLocalizations.of(context)
                        //             .translate('EnterPeerType') + '...',
                        //       hintStyle: TextStyle(color: Colors.grey),
                        //       filled: true,
                        //       fillColor: Colors.white70,
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(12.0)),
                        //         borderSide: BorderSide(
                        //             color: Colors.grey.withOpacity(0.5),
                        //             width: 0.5),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(10.0)),
                        //         borderSide: BorderSide(
                        //             width: 0.5,
                        //             color: Colors.grey.withOpacity(0.5)),
                        //       ),
                        //       errorBorder: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(10.0)),
                        //         borderSide: BorderSide(
                        //             color: Colors.grey.withOpacity(0.5)),
                        //       ),
                        //       focusedErrorBorder: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(10.0)),
                        //         borderSide: BorderSide(
                        //             color: Colors.red.withOpacity(0.5)),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    child: FlatButton(
                      onPressed: () {
                        //Navigator.pop(context);
                        _formKey.currentState.validate();
                      },
                      child: Text(
                          AppLocalizations.of(context).translate('Done'),
                          style: const TextStyle(
                              color: const Color(0xff3c84f2),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 18.5),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
