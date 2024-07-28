import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/views/add_new_task/new_task_haeder.dart';
import 'package:intl/intl.dart' as intl;
import 'package:peloton/widgets/done_alert.dart';

class AddNewTaskWidget extends StatefulWidget {
  @override
  _AddNewTaskWidgetState createState() => _AddNewTaskWidgetState();
}

class _AddNewTaskWidgetState extends State<AddNewTaskWidget> {
  Future<void> createNewTask() async {
    var loc = await getLocation();
    Map<String, dynamic> taskMap = {
      'isSelfCreated': true,
      'assignee': "",
      'description': this.taskDescription,
      'created_at': Timestamp.now(),
      'due_date':
          this.dueDate.toDate().add(Duration(minutes: 719)) ?? Timestamp.now(),
      'hand_raised': false,
      'patientid': AuthProvider.of(context).auth.currentUserId,
      'status': 0,
      'task_details': {
        'recurring': false,
      },
      'task_title': this.taskTitle,
      'task_type': {
        'type': 'Regular',
      },
      'url': this.taskLink ?? '',
    };
    if (selectedGoal != null) {
      taskMap['orginization'] = this.selectedGoal.orginization;
      taskMap['goal_data'] = {
        'category': selectedGoal.goal,
        'color': selectedGoal.goalColor.toRadixString(16).substring(2),
        'goal_id': selectedGoal.id,
        'goal_name': selectedGoal.title,
      };
    } else {
      taskMap['orginization'] = null;
    }
    var result = await Connectivity().checkConnectivity();
    if (loc != null) {
      final coordinates = new Coordinates(loc.latitude, loc.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");
      if(first.addressLine != null){
        taskMap['location_name'] = first.addressLine;
      }
      taskMap['location'] = {
        'lat': loc.latitude ?? '',
        'long': loc.longitude ?? ''
      };
    }

    if (result == ConnectivityResult.none) {
      FirebaseFirestore.instance.collection('tasks').add(taskMap);
    } else {
      await FirebaseFirestore.instance.collection('tasks').add(taskMap);
      addNewTaskCreatedAction(AuthProvider.of(context).auth.currentUserId);
    }

    print('did ceate task');
    AnalyticsManager.instance.addEvent(AnalytictsActions.createTaskSave, null);
    await showDialog(
      context: context,
      child: DoneAlert(
        title: AppLocalizations.of(context).translate("AddNewTaskDoneAlert"),
      ),
    );

    Navigator.pop(context);
  }

  Future<void> addNewTaskCreatedAction(user) async {
    var loc = await getLocation();
    FirebaseFirestore.instance.collection('patient_actions').add(
      {
        'patientid': user,
        'location': {'lat': loc.latitude ?? '', 'long': loc.longitude ?? ''},
        'activity': {
          'create_task': true,
        },
        'datetime': Timestamp.now(),
        'action_type': 'task_created'
      },
    );
  }

  Future<LocationData> getLocation() async {
    Location location = new Location();
    

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    
    print(_locationData);
    return _locationData;
  }

  String formatedDate(date) {
    var newFormat = intl.DateFormat('dd/MMM/yyyy');

    return newFormat.format(date);
  }

  showGoalsList() async {
    final PelotonGoal result = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false, // set to false
        pageBuilder: (_, __, ___) => GoalsList(),
      ),
    );
    print(result?.title);
    setState(() {
      selectedGoal = result;
    });
  }

  final _formKey = GlobalKey<FormState>();
  String taskTitle;
  String taskDescription;
  String taskLink;
  Timestamp dueDate;
  PelotonGoal selectedGoal;
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  var urlController = TextEditingController();

  String getInitials(name) {
    List<String> nameInits = name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  bool shouldvalidate = false;
  bool isDateValid() {
    if (shouldvalidate) return dueDate != null;
    return true;
  }

  bool isGoalValid() {
    if (shouldvalidate) return selectedGoal != null;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          autovalidate: true,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CreateTaskHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                      .translate('TaskTitle')),
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
                          controller: titleController,
                          validator: (value) {
                            if (value.length > 0) {
                              return null;
                            } else {
                              return AppLocalizations.of(context)
                                  .translate('EnterTitle');
                            }
                          },
                          onSaved: (value) {
                            this.taskTitle = value;
                          },
                          onChanged: (value) {},
                          autovalidate: false,
                          autocorrect: true,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('EnterTitle'),
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                        child: Text(
                          AppLocalizations.of(context).translate('Description'),
                          style: const TextStyle(
                              color: const Color(0xff00183c),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                        child: TextFormField(
                          controller: descriptionController,
                          key: UniqueKey(),
                          onSaved: (value) {
                            this.taskDescription = value;
                          },
                          autocorrect: true,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('EnterDescription'),
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
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                        child: Text(
                          AppLocalizations.of(context).translate('Link') + ':',
                          style: const TextStyle(
                              color: const Color(0xff00183c),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 18.0),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(15, 8, 15, 0),
                        child: TextFormField(
                          key: UniqueKey(),
                          autocorrect: false,
                          onSaved: (value) {
                            if (value.contains('http')) {
                              this.taskLink = value;
                            } else {
                              this.taskLink = 'https://' + value;
                            }
                          },
                          controller: urlController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)
                                .translate('PastLink'),
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
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
                      //   child: Text(
                      //     "Assignee:",
                      //     style: const TextStyle(
                      //         color: const Color(0xff00183c),
                      //         fontWeight: FontWeight.w700,
                      //         fontFamily: "Inter",
                      //         fontStyle: FontStyle.normal,
                      //         fontSize: 18.0),
                      //     textAlign: TextAlign.left,
                      //   ),
                      // ),
                      // Container(
                      //   padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      //   child: Row(
                      //     children: <Widget>[
                      //       user.profileImage != null
                      //           ? CircleAvatar(
                      //               radius: 30,
                      //               backgroundImage: NetworkImage(
                      //                 user.profileImage ?? '',
                      //               ),
                      //             )
                      //           : Container(
                      //               // height: 40,
                      //               // width: 40,
                      //               // decoration: BoxDecoration(
                      //               //     borderRadius:
                      //               //         BorderRadius.circular(20),
                      //               //     color: Colors.grey.withOpacity(0.9)),
                      //               // child: Center(
                      //               //   child: Text(
                      //               //     getInitials(
                      //               //         user.firstName.toUpperCase() +
                      //               //             ' ' +
                      //               //             user.lastName.toUpperCase()),
                      //               //     style: TextStyle(
                      //               //         fontSize: 22,
                      //               //         fontWeight: FontWeight.w700),
                      //               //   ),
                      //               // ),
                      //             ),
                      //       // Padding(
                      //       //   padding: EdgeInsets.all(8),
                      //       //   child: Text(
                      //       //     user.firstName + ' ' + user.lastName,
                      //       //     style: TextStyle(
                      //       //       fontFamily: 'Inter',
                      //       //       color: Color(0xff00183c),
                      //       //       fontSize: 18,
                      //       //       fontWeight: FontWeight.w500,
                      //       //       fontStyle: FontStyle.normal,
                      //       //     ),
                      //       //   ),
                      //       // )
                      //     ],
                      //   ),
                      // ),
                      Divider(
                        height: 25,
                        thickness: 12,
                        color: Color(0xfff4f5f9),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          onTap: showGoalsList,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  RichText(
                                    textAlign: TextAlign.start,
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
                                              .translate('Goal'),
                                        ),
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
                                  !isGoalValid()
                                      ? Text(
                                          'please select goal',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        )
                                      : Container(),
                                ],
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  selectedGoal?.title ??
                                      AppLocalizations.of(context)
                                          .translate('SelectGoal'),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: selectedGoal != null
                                        ? Color(0xff00183c)
                                        : Color(0xffd1d1d1),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          onTap: () {
                            showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2050),
                            ).then(
                              (value) {
                                setState(() {
                                  this.dueDate = Timestamp.fromDate(value);
                                });
                              },
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  RichText(
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
                                              .translate(
                                            'DueDate',
                                          ),
                                        ),
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
                                  !isDateValid()
                                      ? Text(
                                          'please select date',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 12),
                                        )
                                      : Container(),
                                ],
                              ),
                              Text(
                                dueDate != null
                                    ? formatedDate(dueDate.toDate())
                                    : formatedDate(DateTime.now()),
                                style: TextStyle(
                                  color: dueDate != null
                                      ? Color(0xff00183c)
                                      : Color(0xffd1d1d1),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Divider(),
                      // Padding(
                      //   padding: const EdgeInsets.all(12.0),
                      //   child: Row(
                      //     children: <Widget>[
                      //       Text(
                      //         "Repeated",
                      //         style: const TextStyle(
                      //             color: const Color(0xff00183c),
                      //             fontWeight: FontWeight.w700,
                      //             fontFamily: "Inter",
                      //             fontStyle: FontStyle.normal,
                      //             fontSize: 18.0),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        padding: EdgeInsets.all(15),
                        width: double.infinity,
                        color: Color(0xfff4f5f9),
                        child: FlatButton(
                          onPressed: () {
                            setState(() {
                              shouldvalidate = true;
                            });

                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();

                              this.createNewTask();
                            } else {}
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
                                AppLocalizations.of(context).translate(
                                  'SaveTask',
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoalsList extends StatelessWidget {
  List<Widget> getGoalsWidget(snapshot, context, myid) {
    List<Widget> result = [];
    for (DocumentSnapshot item in snapshot.data.documents) {
      PelotonGoal goal = PelotonGoal.fromJson(item.data());

      goal.id = item.id;
      result.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, goal);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                goal.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );

      result.add(Divider());
    }
    PelotonGoal defGoal = PelotonGoal.fromJson({
      "orginization": "Default",
      "goal_name": "Default Goal",
      "goal_color": "003561",
      "patientid": myid,
    });
    result.insert(
      0,
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context, defGoal);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              defGoal.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String myId = AuthProvider.of(context).auth.currentUserId;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Container(
        width: double.infinity,
        child: StreamBuilder(
          // stream: Firestore.instance
          //     .collection('goals')
          //     .where('patientid', isEqualTo: myId)
          //     .snapshots(),
          stream: FirebaseFirestore.instance
              .collection('goals')
              .where('patientid', isEqualTo: myId)
              .snapshots(),

          builder: (context, snapshot) {
            if (snapshot.data != null &&
                snapshot.connectionState != ConnectionState.waiting) {
              return Container(
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 25),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            )),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.close),
                                  color: Colors.blue,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 25),
                              child:
                                  //  snapshot.data.documents.length == 0
                                  //     ? Padding(
                                  //         padding: const EdgeInsets.all(8.0),
                                  //         child: Text(
                                  //           AppLocalizations.of(context)
                                  //               .translate('NoGoalsAvailable'),
                                  //           style: TextStyle(
                                  //               fontFamily: 'Inter',
                                  //               fontSize: 20,
                                  //               fontWeight: FontWeight.w500),
                                  //         ),
                                  //       )
                                  //     :
                                  Text(
                                AppLocalizations.of(context).translate('Goal'),
                                style: const TextStyle(
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 20.0),
                              ),
                            ),
                            SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children:
                                      getGoalsWidget(snapshot, context, myId)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
