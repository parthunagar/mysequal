import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:peloton/widgets/done_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewThirdStep extends StatefulWidget {
  final Function(String, dynamic) update;
  @override
  AddNewThirdStep({this.update});
  @override
  _AddNewThirdStepState createState() => _AddNewThirdStepState();
}

class _AddNewThirdStepState extends State<AddNewThirdStep> {
  TextEditingController bodycontroller = TextEditingController();
  TextEditingController titleController = TextEditingController();

  FocusNode commentFocusNode = new FocusNode();
  FocusNode titleFocusNode = new FocusNode();

  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(onHide: () {
      removeOverlay();
    });
    commentFocusNode.addListener(() {
      bool hasFocus = commentFocusNode.hasFocus;
      if (hasFocus) {
        showOverlay(context);
      } else {
        removeOverlay();
      }
    });
    titleFocusNode.addListener(() {
      bool hasFocus = titleFocusNode.hasFocus;
      if (hasFocus) {
        showOverlay(context);
      } else {
        removeOverlay();
      }
    });

    super.initState();
  }

  OverlayEntry overlayEntry;
  showOverlay(BuildContext context) {
    if (overlayEntry != null) return;
    OverlayState overlayState = Overlay.of(context);
    overlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          right: 0.0,
          left: 0.0,
          child: InputDoneView());
    });

    overlayState.insert(overlayEntry);
  }

  removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  @override
  void dispose() {
    bodycontroller.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  return NSBaseWidget(
    //   builder: (context, sizingInformation) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    print(screenHeight);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(20, 20, 12, 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
              borderRadius: BorderRadiusDirectional.only(
                bottomEnd: Radius.circular(20),
                bottomStart: Radius.circular(20),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)
                  .translate('AddStoryThirdStepSubtitle'),
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottom),
              reverse: true,
              child: Container(
                padding: EdgeInsets.only(bottom: 120),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 20, top: 5),
                        height: screenHeight > 700
                            ? screenHeight / 3.5
                            : screenHeight /
                                6, //sizingInformation.scaleByWidth(150),
                        child: Image.asset(
                          'assets/goodJob.png',
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      FutureBuilder(
                        future: SharedPreferences.getInstance(),
                        builder: (_, AsyncSnapshot<SharedPreferences> snap) {
                          if (snap.data == null) return Container();
                          if (snap.data.getBool('firsStory') == null) {
                            snap.data.setBool('firsStory', true);
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('FirstStory'),
                                  style: TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.5,
                                  ) //sizingInformation.scaleByWidth(16.5)),
                                  ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('NotFirstStory'),
                                  style: TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.5,
                                  ) //sizingInformation.scaleByWidth(16.5)),
                                  ),
                            );
                          }
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0x1a000000),
                                  offset: Offset(0, 0),
                                  blurRadius: 42,
                                  spreadRadius: 0)
                            ],
                            color: const Color(0xffffffff)),
                        padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                        margin: EdgeInsets.fromLTRB(12, 5, 12, 5),
                        child: TextField(
                          focusNode: titleFocusNode,
                          maxLines: 1,
                          maxLength: 70,
                          controller: titleController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: AppLocalizations.of(context)
                                  .translate('AddStoryTitle')
                              // AppLocalizations.of(context).translate('EnterDPText'),
                              ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          onChanged: (vale) {
                            setState(() {
                              widget.update('title', titleController.text);
                            });
                          },
                          onSubmitted: (value) {
                            print(titleController.text);
                            setState(() {
                              widget.update('title', titleController.text);
                            });
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0x1a000000),
                                  offset: Offset(0, 0),
                                  blurRadius: 42,
                                  spreadRadius: 0)
                            ],
                            color: const Color(0xffffffff)),
                        padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                        margin: EdgeInsets.fromLTRB(12, 5, 12, 5),
                        child: TextField(
                          focusNode: commentFocusNode,
                          maxLines: 3,
                          maxLength: 200,
                          controller: bodycontroller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintText: AppLocalizations.of(context)
                                .translate('NewStoryNote'),
                            //AppLocalizations.of(context).translate('EnterDPText'),
                          ),
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          onChanged: (vale) {
                            setState(() {
                              widget.update('description', bodycontroller.text);
                            });
                          },
                          onSubmitted: (value) {
                            print(bodycontroller.text);
                            setState(() {
                              widget.update('description', bodycontroller.text);
                            });
                          },
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).translate('ThatsIt'),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 16.5),
                      ),
                    ]),
              ),
            ),
          )
        ],
      ),
    );
  }
  //   );
  // }
}
