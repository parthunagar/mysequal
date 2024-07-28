import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/widgets/done_alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'add_new_first_step.dart';
import 'add_new_second_step.dart';
import 'add_new_third_step.dart';

class AddNewStoryWidget extends StatefulWidget {
  @override
  _AddNewStoryWidgetState createState() => _AddNewStoryWidgetState();
}

class _AddNewStoryWidgetState extends State<AddNewStoryWidget>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<AddNewStoryWidget> {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> mediaItem = {};

  updateMediaItem(String key, dynamic value) {
    if (key == 'recover_program_journal') {
      if (mediaItem[key] == null) {
        mediaItem[key] = [value];
      } else {
        List<dynamic> data = [];
        var index = 0;
        for (var item in mediaItem[key]) {
          if (item.name == value.name) {
            mediaItem[key][index].value = value.value;
            continue;
          }
          index++;

          data.add(item);
        }
        data.add(value);
        mediaItem[key] = data;
      }

      return;
    }

    mediaItem[key] = value;
    if (key == 'mood') {
      didSelectMood = true;
    }
    if (key == 'title') {
      didSelectTile = true;
    }
    print(mediaItem);
  }

  TabController _tabController;
  int _selectePage = 0;
  bool didSelectMood = false;
  bool didSelectTile = false;
  bool isUploading = false;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3, initialIndex: 0);

    super.initState();
  }

  void onTabTapped(int index) {
    setState(() {
      _selectePage = index;
      _tabController.index = index;
    });
  }

  showErrorAlert(context, alertMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(alertMessage),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(
                AppLocalizations.of(context).translate('Close'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> uploadStory() async {
    var loc = await getLocation();
    var userid = AuthProvider.of(context).auth.currentUserId;
    mediaItem['patient_id'] = userid;
    setState(() {
      isUploading = true;
    });
    if (mediaItem['recover_program_journal'] != null) {
      List<dynamic> data = [];

      for (var item in mediaItem['recover_program_journal']) {
        data.add(item.toJson());
      }

      mediaItem['recover_program_journal'] = data;
    }
    if (loc != null) {
      mediaItem['location'] = {'lat': loc.latitude, 'long': loc.longitude};
    }

    await FirebaseFirestore.instance.collection('journal').add(mediaItem);
    // addNewJournalAction(userid);
    // await Future.delayed(Duration(seconds: 2));
    setState(() {
      isUploading = false;
    });
    showDoneAlert();
  }

  Future<void> addNewJournalAction(user) async {
    var loc = await getLocation();
    FirebaseFirestore.instance.collection('patient_actions').add(
      {
        'patientid': user,
        'location': {'lat': loc.latitude ?? '', 'long': loc.longitude ?? ''},
        'activity': {
          'new_story': true,
        },
        'datetime': Timestamp.now(),
        'action_type': 'new_story'
      },
    );
  }

  Future<LocationData> getLocation() async {
    Location location = new Location();
    var locationPermission = Permission.location;

    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    // LocationData _locationData;

    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return null;
    //   }
    // }

    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return null;
    //   }
    // }
    var locationPer = await locationPermission.status;
    if (locationPer.isGranted) {
      var _locationData = await location.getLocation();
      print(_locationData);
      return _locationData;
    } else {
      return null;
    }

    // if (locationPer.isGranted) {
    //   await location.requestPermission();
    //   var locationPer2 = await locationPermission.status;
    //   if (locationPer2.isDenied) {
    //     return null;
    //   } else if (locationPer2.isGranted) {
    //     var _locationData = await location.getLocation();
    //     print(_locationData);
    //     return _locationData;
    //   }
    // }
  }

  closePage() {
    Navigator.pop(context);
  }

  // showDoneAlert() {
  //   showDialog(
  //       context: context,
  //       child: AlertDialog(
  //         title: new Text(
  //             AppLocalizations.of(context).translate('AddNewStoryDoneMessage')),
  //         actions: <Widget>[
  //           new FlatButton(
  //             child: new Text(AppLocalizations.of(context).translate('Done')),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               closePage();
  //             },
  //           ),
  //         ],
  //       ));
  // }
  showDoneAlert() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DoneAlert(
            title: AppLocalizations.of(context)
                .translate('AddNewStoryDoneMessage')),
      ),
    );
  }

  final pageController = PageController(viewportFraction: 1);

  Widget getAddStep(index) {
    switch (index) {
      case 0:
        return AddFirstStepWidget(
          update: updateMediaItem,
          isUploading: (value) {
            this.isUploading = value;
          },
        );

      case 1:
        return AddSecondStep(update: updateMediaItem);

      case 2:
        return AddNewThirdStep(update: updateMediaItem);
      default:
        return Container();
    }
  }

  Future<void> showReturnalert() async {
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
                  AppLocalizations.of(context).translate('DeleteNewStory'),
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
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  showNext() {
    if (pageController.page == 0 && !didSelectMood) {
      showErrorAlert(context,
          AppLocalizations.of(context).translate('SelectMoodErrorMessage'));
      return;
    }
    if (pageController.page == 0 && isUploading) {
      showErrorAlert(
          context, AppLocalizations.of(context).translate('IsUploadingError'));
      return;
    }
    if (pageController.page == 2 && didSelectTile) {
      print('done');
      print(this.mediaItem);
      uploadStory();
      return;
    } else if (pageController.page == 2 && !didSelectTile) {
      showErrorAlert(context,
          AppLocalizations.of(context).translate('SelectTitleErrorMessage'));
      return;
    }
    pageController.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //  return NSBaseWidget(builder: (context, sizingInformation) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectePage != 0) {
          pageController.previousPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          return false;
        }
        if (this.didSelectMood || didSelectTile) {
          showReturnalert();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Color(0xfff4f5f9),
        appBar: AppBar(
          backgroundColor: Theme.of(context).accentColor,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context).translate('ReflectYourDay'),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 25, //sizingInformation.scaleByWidth(25),
            ),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: Container(
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).accentColor,
                      height: 30, //sizingInformation.scaleByWidth(30),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: pageController,
                          count: 3,
                          effect: SlideEffect(
                              dotWidth: 112,

                              /// sizingInformation.scaleByWidth(112),
                              dotHeight:
                                  11, //sizingInformation.scaleByWidth(11),
                              activeDotColor: Theme.of(context).primaryColor,
                              dotColor: Colors.grey.withOpacity(0.3),
                              paintStyle: PaintingStyle.fill,
                              radius: 1,
                              strokeWidth: 1),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        dragStartBehavior: DragStartBehavior.start,
                        physics: NeverScrollableScrollPhysics(),
                        key: UniqueKey(),
                        itemBuilder: (contaxt, index) {
                          return getAddStep(index);
                        },
                        itemCount: 3,
                        controller: pageController,
                        onPageChanged: (index) {
                          _selectePage = index;
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60, // sizingInformation.scaleByWidth(60),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0x1a000000),
                              offset: Offset(0, 0),
                              blurRadius: 10,
                              spreadRadius: 0)
                        ],
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(17),
                            topLeft: Radius.circular(17)),
                        color: Colors.white),
                  ),
                ),
                DoneOrNext(
                  update: showNext,
                )
              ],
            ),
          ),
        ),
      ),
    );
    // });
  }
}

class DoneOrNext extends StatefulWidget {
  final Function update;
  @override
  DoneOrNext({this.update});
  @override
  _DoneOrNextState createState() => _DoneOrNextState();
}

class _DoneOrNextState extends State<DoneOrNext> {
  var index = 0;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, //sizingInformation.scaleByWidth(20),
      child: FlatButton(
        padding: EdgeInsets.zero,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: () {
          widget.update();
          setState(() {
            index++;
          });
        },
        child: Container(
          child: Image.asset(
            index != 2 ? 'assets/next_step.png' : 'assets/check.png',
            matchTextDirection: index != 2,
            width: 80,
            height: 80,
          ),
        ),
      ),
    );
  }
}
