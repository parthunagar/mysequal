import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/widgets/bottom_radio_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:convert';

class PersonalDataWidget extends StatefulWidget {
  @override
  _PersonalDataWidgetState createState() => _PersonalDataWidgetState();
}

class _PersonalDataWidgetState extends State<PersonalDataWidget>
    with SingleTickerProviderStateMixin {
  File _image;
  final picker = ImagePicker();

  bool isEditing = false;

  String selectedGender;
  String selectedStatus;
  String selectedBD;

  PelotonUser mydata;
  AnimationController expandController;
  Animation<double> animation;
  bool shouldExpand = false;
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  List<dynamic> selectedComorbidities;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (shouldExpand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(PersonalDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
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
        selectedGender = genderKey;
      },
    );
    print(genderKey);
  }

  updateUserEmail() {
    AuthProvider.of(context)
        .auth
        .updateUserDoc('email_address', emailController.text);
  }

  updateUserName() {
    AuthProvider.of(context)
        .auth
        .updateUserDoc('first_name', firstNameController.text);
    AuthProvider.of(context)
        .auth
        .updateUserDoc('last_name', lastNameController.text);
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  String getMaritalStatus(value) {
    var status = AppLocalizations.of(context).translate("MaritalStatus");
    
    final decodedStatus = json.decode(status.replaceAll("\'", "\""));
    return decodedStatus[value];
  }

  String getGender(String value) {
    var status = AppLocalizations.of(context).translate("Genders");
    
    final decodedStatus = json.decode(status.replaceAll("\'", "\""));
    return decodedStatus[value];
  }

  List<String> getComor(value) {
    var status = AppLocalizations.of(context).translate("ComorbiditiesList");
    
    List<String> conditions = [];
    final decodedStatus = json.decode(status.replaceAll("\'", "\""));
    for (var com in value) {
      conditions.add(decodedStatus[com]);
    }
    return conditions;
  }

  void showEditStatusOptions(value) async {
    var status = AppLocalizations.of(context).translate("MaritalStatus");
    print(status);
    final decodedStatus = json.decode(status.replaceAll("\'", "\""));
    List<String> statusList = [];
    decodedStatus.entries.forEach((e) => statusList.add(e.value.toString()));
    var result = await Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return BottomRadioListWidget(
            data: statusList,
            title: AppLocalizations.of(context).translate("Status"),
            defaultValue: value,
          );
        },
      ),
    );
    var statusKey = decodedStatus.keys
        .firstWhere((k) => decodedStatus[k] == result, orElse: () => null);
    print(result);
    setState(() {
      selectedStatus = statusKey;
    });

    print(statusKey);
  }

  String getAgeFromDate(date) {
    if (date.length == 0) {
      return "";
    }
    DateTime parseDt = DateTime.parse(date);
    var age = DateTime.now().year - parseDt.year;
    return age.toString();
  }

  void presentDatePicker() {
    DateTime initDate = (mydata.dateOfBirth != null && mydata.dateOfBirth.length > 0)
        ? DateTime.parse(mydata.dateOfBirth)
        : DateTime(2019);
    showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2020),
    ).then((value) => updateDateOfBirth(value));
  }

  String getInitials(name) {
    List<String> nameInits = name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  Widget getProfileImage(PelotonUser user) {
    return user.profileImage != null && user.profileImage.length > 0
        ? CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              user.profileImage ?? '',
            ),
          )
        : Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.withOpacity(0.9)),
            child: Center(
              child: Text(
                getInitials(user.firstName.toUpperCase() +
                    ' ' +
                    user.lastName.toUpperCase()),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          );
  }

  bool isuploading = false;
  Future<void> _uploadFile(File file, String filename) async {
    StorageReference storageReference;
    setState(() {
      isuploading = true;
    });

    storageReference =
        FirebaseStorage.instance.ref().child("${mydata.id}profile.jpg");

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    mydata.updateUserProfileImage(url);
    AuthProvider.of(context).auth.updateUserDoc('profile_image', url);
    print("URL is $url");
    setState(() {
      isuploading = false;
    });
  }

  void updateDateOfBirth(DateTime date) {
    print(date.toString());
    var newFormat = intl.DateFormat('yyyy-MM-dd');

    String updatedDt = newFormat.format(date);

    print(updatedDt);
    setState(() {
      selectedBD = updatedDt;
      // mydata.updateUserBirthdate(date);
    });
  }

  showComorbidities(context) async {
    var comorbidities =
        AppLocalizations.of(context).translate("ComorbiditiesList");
    print(comorbidities);
    Map<String, dynamic> decodedCombo =
        json.decode(comorbidities.replaceAll("\'", "\""));
    // List<String> combolist = [];
    // decodedCombo.entries.forEach((e) => combolist.add(e.value.toString()));

    var result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          height: 450,
          margin: EdgeInsets.only(bottom: 0),
          child: Wrap(
            children: <Widget>[
              SelectComorbidities(
                selectedItems: mydata.comorbidities,
                dataList: decodedCombo,
              ),
            ],
          ),
        );
      },
    );
    print(result);
    print('done');
    if (result.length > 0){
        setState(() {
      selectedComorbidities = result;
      // AuthProvider.of(context).auth.updateUserDoc('comorbidities', result);
    });
    }
  
  }

  String dropdownValue = 'None';

  @override
  Widget build(BuildContext context) {
    mydata = PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    firstNameController.text = mydata.firstName;
    lastNameController.text = mydata.lastName;
    emailController.text = mydata.emailAddress ?? "";
    return Container(
      margin: EdgeInsets.all(12),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          PositionedDirectional(
            end: 10,
            top: 20,
            child: Container(
              padding: EdgeInsets.all(5),
              child: GestureDetector(
                  child: isEditing
                      ? Text(
                          AppLocalizations.of(context).translate("Save"),
                          style: const TextStyle(
                              color: const Color(0xff3c84f2),
                              fontWeight: FontWeight.w500,
                              fontFamily: "Inter",
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0),
                        )
                      : Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).translate("Edit"),
                              style: const TextStyle(
                                  color: const Color(0xff3c84f2),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 20.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue,
                                size: 18,
                              ),
                            )
                          ],
                        ),
                  onTap: () {
                    if (isEditing) {
                      AnalyticsManager.instance.addEvent(AnalytictsActions.myProfileSave, null);
                      updateUserName();
                      updateUserEmail();
                      if (_image != null) _uploadFile(_image, 'profileImage');
                      if (selectedComorbidities != null) {
                        AuthProvider.of(context).auth.updateUserDoc(
                            'comorbidities', selectedComorbidities);
                      }
                      if (selectedGender != null) {
                        AuthProvider.of(context)
                            .auth
                            .updateUserDoc('gender', selectedGender.toLowerCase());
                      }
                      if (selectedStatus != null) {
                        AuthProvider.of(context)
                            .auth
                            .updateUserDoc('marital_status', (selectedStatus).toLowerCase());
                      }
                      if (selectedBD != null) {
                        AuthProvider.of(context)
                            .auth
                            .updateUserDoc('date_of_birth', selectedBD);
                      }
                    } else {
                      AnalyticsManager.instance.addEvent(AnalytictsActions.myProfileEdit, null);
                    }
                    setState(() {
                      isEditing = !isEditing;
                      shouldExpand = isEditing;
                      _runExpandCheck();
                    });
                  }),
            ),
          ),
          Container(
            //height: isEditing ? 620 :  120,

            margin: EdgeInsets.only(top: 54),
            padding: EdgeInsets.only(top: 100),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 0),
                    blurRadius: 21,
                    spreadRadius: 0)
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: animation,
              child: Column(
                children: <Widget>[
                  isEditing ? Divider() : Container(),
                  isEditing
                      ? ListTile(
                          leading: Container(
                            width: 120,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("FirstName"),
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 15.0),
                            ),
                          ),
                          title: Container(
                            child: TextField(
                              maxLines: 1,
                              controller: firstNameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              enabled: isEditing,
                            ),
                          ),
                        )
                      : Container(),
                  isEditing ? Divider() : Container(),
                  isEditing
                      ? ListTile(
                          leading: Container(
                            width: 120,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("LastName"),
                              style: const TextStyle(
                                  color: const Color(0xff00183c),
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Inter",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 15.0),
                            ),
                          ),
                          title: Container(
                            child: TextField(
                              maxLines: 1,
                              controller: lastNameController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              enabled: isEditing,
                            ),
                          ),
                          // trailing: isEditing
                          //     ? Icon(
                          //         Icons.play_arrow,
                          //         color: Color(0xff3c84f2),
                          //       )
                          //     : SizedBox(
                          //         width: 0,
                          //       ),
                        )
                      : Container(),
                  Divider(),
                  ListTile(
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Mobile"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    title: Text(
                      mydata.phone,
                      style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.5),
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Email"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    // title: Text(
                    //   mydata.emailAddress,
                    //   style: const TextStyle(
                    //       color: const Color(0xff4a4a4a),
                    //       fontWeight: FontWeight.w500,
                    //       fontFamily: "Inter",
                    //       fontStyle: FontStyle.normal,
                    //       fontSize: 16.5),
                    // ),

                    title: Container(
                      child: TextField(
                        maxLines: 1,
                        controller: emailController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        enabled: isEditing,
                      ),
                    ),
                    // trailing: isEditing
                    //     ? Icon(
                    //         Icons.play_arrow,
                    //         color: Color(0xff3c84f2),
                    //       )
                    //     : SizedBox(
                    //         width: 0,
                    //       ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Gender"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    title: Text(
                      selectedGender != null
                          ? getGender(selectedGender)
                          : (getGender(mydata.gender) ?? ''),
                      style: const TextStyle(
                          color: const Color(0xff4a4a4a),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.5),
                    ),
                    onTap: isEditing
                        ? () {
                            showEditGenderOptions(
                                selectedGender ?? mydata.gender);
                          }
                        : null,
                    trailing: isEditing
                        ? Icon(
                            Icons.play_arrow,
                            color: Color(0xff3c84f2),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Age"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    onTap: isEditing ? presentDatePicker : null,
                    title: Text(
                      selectedBD != null
                          ? getAgeFromDate(selectedBD)
                          : mydata.dateOfBirth != null
                              ? getAgeFromDate(mydata.dateOfBirth)
                              : "",
                      style: const TextStyle(
                          color: const Color(0xff4a4a4a),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.5),
                    ),
                    trailing: isEditing
                        ? Icon(
                            Icons.play_arrow,
                            color: Color(0xff3c84f2),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Status"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    onTap: isEditing
                        ? () {
                            showEditStatusOptions(mydata.maritalStatus);
                          }
                        : null,
                    title: Text(
                      selectedStatus != null
                          ? getMaritalStatus(selectedStatus)
                          : (getMaritalStatus(mydata.maritalStatus) ?? ""),
                      style: const TextStyle(
                          color: const Color(0xff4a4a4a),
                          fontWeight: FontWeight.w500,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.5),
                    ),
                    trailing: isEditing
                        ? Icon(
                            Icons.play_arrow,
                            color: Color(0xff3c84f2),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      showComorbidities(context);
                    },
                    leading: Container(
                      width: 120,
                      child: Text(
                        AppLocalizations.of(context).translate("Comorbidities"),
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                      ),
                    ),
                    title: mydata.comorbidities != null
                        ? Text(
                            getComor(mydata.comorbidities).reduce(
                                (value, element) => value + ' ,' + element),
                            style: const TextStyle(
                                color: const Color(0xff4a4a4a),
                                fontWeight: FontWeight.w500,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 16.5),
                          )
                        : (selectedComorbidities != null
                            ? Text(
                                getComor(selectedComorbidities).reduce(
                                    (value, element) => value + ', ' + element),
                                overflow: TextOverflow.ellipsis)
                            : Text(
                                ' ',
                                style: const TextStyle(
                                    color: const Color(0xff4a4a4a),
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 16.5),
                              )),
                    trailing: isEditing
                        ? Icon(
                            Icons.play_arrow,
                            color: Color(0xff3c84f2),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              child: Column(
                children: <Widget>[
                  isuploading
                      ? Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          child: Center(child: CircularProgressIndicator()))
                      : Container(),
                  Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(54),
                      ),
                      height: 108,
                      width: 108,
                      child: _image != null
                          ? Image.file(
                              _image,
                              fit: BoxFit.cover,
                            )
                          : getProfileImage(mydata)
                      //  Image.network(
                      //     mydata.profileImage,
                      //     fit: BoxFit.cover,
                      //   ),
                      ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    mydata.firstName + ' ' + mydata.lastName,
                    style: const TextStyle(
                        color: const Color(0xff00183c),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 20.0),
                  )
                ],
              ),
            ),
          ),
          isEditing
              ? Positioned(
                  top: 0,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(54),
                              ),
                              height: 108,
                              width: 108,
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class SelectComorbidities extends StatefulWidget {
  final selectedItems;
  final Map<String, dynamic> dataList;
  @override
  SelectComorbidities({this.selectedItems, this.dataList});
  @override
  _SelectComorbiditiesState createState() => _SelectComorbiditiesState();
}

class _SelectComorbiditiesState extends State<SelectComorbidities> {
  String getCondition(value) {
    var result = widget.dataList.keys
        .firstWhere((k) => widget.dataList[k] == value, orElse: () => null);
    return result;
  }

  List<String> titles = [];

  List<dynamic> selectedCodetion;
  @override
  void initState() {
    widget.dataList.entries.forEach((e) => titles.add(e.value.toString()));

    selectedCodetion = widget.selectedItems ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(16), topLeft: Radius.circular(16)),
        color: Colors.white,
      ),
      height: 450,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Text(
                    AppLocalizations.of(context).translate("SelectComorbidities"),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xff00183c),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.normal,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close),
                color: Colors.blue,
                onPressed: () {
                  Navigator.pop(context, selectedCodetion);
                },
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: titles.length,
              itemBuilder: (_, index) {
                var item = titles[index];
                return ListTileTheme(
                  iconColor: Colors.green,
                  selectedColor: Colors.green,
                  child: CheckboxListTile(
                    selected: true,
                    onChanged: (selected) {
                      setState(() {
                        if (selected) {
                          selectedCodetion.add(getCondition(item));
                        } else {
                          selectedCodetion.remove(getCondition(item));
                        }
                      });
                      print(selectedCodetion.contains(getCondition(item)));
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    value: selectedCodetion.contains(getCondition(item)),
                    title: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          Divider()
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
