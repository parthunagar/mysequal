import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart' as intl;

class AddFirstStepWidget extends StatefulWidget {
  final Function(String, dynamic) update;
  final Function(bool) isUploading;
  @override
  AddFirstStepWidget({this.update, this.isUploading});
  @override
  _AddFirstStepWidgetState createState() => _AddFirstStepWidgetState();
}

class _AddFirstStepWidgetState extends State<AddFirstStepWidget>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<AddFirstStepWidget> {
  @override
  bool get wantKeepAlive => true;

  TabController _tabController;
  int _selectePage = 0;
  int selectedFaceIndex;
  PickedFile _selectedImage;
  PickedFile _selectedVideo;
  DateTime selectedDate;
  bool isUploading = false;
  double _progress = 0.0;
  List<String> titles = [
    'MoodGreat',
    'MoodGood',
    'MoodMeh',
    'MoodBad',
    'MoodAwful',
  ].reversed.toList();

  final picker = ImagePicker();
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3, initialIndex: 1);
    selectedDate = DateTime.now();
    widget.update('created_at', Timestamp.fromDate(DateTime.now().add(Duration(minutes: 719))));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _selectedVideo = null;
    _selectedImage = null;
  }

  void onTabTapped(int index) {
    setState(() {
      _selectePage = index;
      _tabController.index = index;
      if (index == 1) {
        selectedDate = DateTime.now().add(Duration(minutes: 719));
      } else if (index == 0) {
        selectedDate = DateTime.now().subtract(Duration(days: 1)).add(Duration(minutes: 719));
      }
    });
    if (index == 2) {
      presentDataPicker();
    }
    widget.update('created_at', Timestamp.fromDate(selectedDate));
  }

  presentDataPicker() {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      onChanged: (date) {
        print('change $date in time zone ' +
            date.timeZoneOffset.inHours.toString());
      },
      locale: LocaleType.en,
      onConfirm: (date) {
        print('confirm $date');
        setState(() {
          selectedDate = date;
          widget.update('created_at', Timestamp.fromDate(selectedDate));
        });
      },
      currentTime: DateTime.now(),
    );
  }

  deleteSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          margin: EdgeInsets.only(bottom: 20),
          child: new Wrap(
            children: <Widget>[
              new ListTile(
                  leading: new Icon(Icons.photo_album),
                  title: new Text(
                    AppLocalizations.of(context).translate('Photos'),
                  ),
                  onTap: () {
                    showImagePicker(ImageSource.gallery);
                    Navigator.pop(bc);
                  }),
              new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    AppLocalizations.of(context).translate('Camera'),
                  ),
                  onTap: () {
                    showImagePicker(ImageSource.camera);
                    Navigator.pop(bc);
                  }),
              new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    AppLocalizations.of(context).translate('Video'),
                  ),
                  onTap: () {
                    showVideoPicker(ImageSource.camera);
                    Navigator.pop(bc);
                  }),
            ],
          ),
        );
      },
    );
  }

  Future showImagePicker(source) async {
    final pickedFile = await picker.getImage(source: source, imageQuality: 10);
    if (pickedFile == null) return;
    setState(() {
      _selectedImage = pickedFile;
    });

    _uploadFile(File(pickedFile.path));
  }

  Future showVideoPicker(source) async {
    final pickedFile = await picker.getVideo(
        source: source, maxDuration: Duration(seconds: 30));
    if (pickedFile == null) return;
    var path = pickedFile.path;
    _selectedVideo = pickedFile;
    print(path);
    _getImage(path);
  }

  _getImage(videoPathUrl) async {
    print(videoPathUrl);

    final thumb = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 250,
      maxWidth: 250,
      quality: 50,
    );

    setState(() {
      _selectedImage = PickedFile(thumb);
    });
    print(thumb);
    print('done');
    _uploadVideoCover(File(_selectedVideo.path), File(_selectedImage.path));
  }

  Future<void> _uploadFile(File file) async {
    StorageReference storageReference;

    storageReference = FirebaseStorage.instance
        .ref()
        .child("journalMediafile${UniqueKey().toString()}.jpg");

    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    widget.update('media', {'type': 'image', 'url': url});
    print("URL is $url");
  }

  Future<void> _uploadVideoCover(File file, File cover) async {
    StorageReference storageReference;
    StorageReference storageReference2;
    setState(() {
      isUploading = true;
      widget.isUploading(true);
    });

    storageReference = FirebaseStorage.instance
        .ref()
        .child("journalMediafileCover${UniqueKey().toString()}.jpg");

    final StorageUploadTask uploadTask = storageReference.putFile(cover);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String coverUrl = (await downloadUrl.ref.getDownloadURL());

    storageReference2 = FirebaseStorage.instance
        .ref()
        .child("journalMediafil${UniqueKey().toString()}.mp4");

    final StorageUploadTask uploadTask2 = storageReference2.putFile(file);
    uploadTask2.events.listen((event) {
      setState(() {
        isUploading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });
    final StorageTaskSnapshot downloadUrl2 = (await uploadTask2.onComplete);
    final String url = (await downloadUrl2.ref.getDownloadURL());
    setState(() {
      isUploading = false;
      widget.isUploading(false);
    });

    widget
        .update('media', {'type': 'video', 'url': url, 'thumbnail': coverUrl});
    //print("URL is $url");
    file.deleteSync(recursive: true);
    cover.deleteSync(recursive: true);
  }

  String getFormattedDate() {
    var date = selectedDate.toString();
    DateTime parseDt = DateTime.parse(date);
    //var newFormat = intl.DateFormat('EEEEE, MMM, d  h:mm a');
    var newFormat = intl.DateFormat('EEEEE, MMM d');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  List<Widget> getfacesList() {
    List<Widget> result = [];
    for (var index = 0; index < 5; index++) {
      var item = Container(
        width: MediaQuery.of(context).size.width / 6,
        child: FlatButton(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          padding: EdgeInsets.zero,
          onPressed: () {
            setState(() {
              selectedFaceIndex = index;
              widget.update('mood', index + 1);
            });
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Image.asset(
                    'assets/bface${index + 1}.png',
                    color: index == selectedFaceIndex
                        ? Colors.blue
                        : Colors.blue.withOpacity(0.2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                    AppLocalizations.of(context).translate(titles[index]),
                    maxLines: 1,
                    style: const TextStyle(
                        color: const Color(0xff00183c),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Inter",
                        fontStyle: FontStyle.normal,
                        fontSize: 14.5),
                    textAlign: TextAlign.center),
              )
            ],
          ),
        ),
      );
      result.add(item);
    }
    return result.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NSBaseWidget(builder: (context, sizingInformation) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container(
            //   decoration: BoxDecoration(
            //     color: Theme.of(context).accentColor,
            //     borderRadius: BorderRadiusDirectional.only(
            //       bottomEnd: Radius.circular(20),
            //       bottomStart: Radius.circular(20),
            //     ),
            //   ),
            //   child: TabBar(
            //     indicatorPadding: EdgeInsets.only(left: 15, right: 15),
            //     indicatorWeight: 7,
            //     indicatorColor: Color(0xff00183c).withOpacity(0.7),
            //     controller: _tabController,
            //     onTap: onTabTapped,
            //     tabs: <Widget>[
            //       Tab(
            //         child: Text(
            //           AppLocalizations.of(context).translate("Yesterday"),
            //           style:  TextStyle(
            //               color: const Color(0xffffffff),
            //               fontWeight: FontWeight.w500,
            //               fontFamily: "Inter",
            //               fontStyle: FontStyle.normal,
            //               fontSize: sizingInformation.scaleByWidth(18)),
            //         ),
            //       ),
            //       Tab(
            //         child: Text(
            //           AppLocalizations.of(context).translate("Now"),
            //           style:  TextStyle(
            //               color: const Color(0xffffffff),
            //               fontWeight: FontWeight.w500,
            //               fontFamily: "Inter",
            //               fontStyle: FontStyle.normal,
            //               fontSize: sizingInformation.scaleByWidth(18)),
            //         ),
            //       ),
            //       Tab(
            //         child: Text(
            //           AppLocalizations.of(context).translate("SetTime"),
            //           style:  TextStyle(
            //               color: const Color(0xffffffff),
            //               fontWeight: FontWeight.w500,
            //               fontFamily: "Inter",
            //               fontStyle: FontStyle.normal,
            //               fontSize: sizingInformation.scaleByWidth(18)),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                    .translate('AddStoryFirstStepSubtitle'),
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
            selectedDate != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          getFormattedDate(),
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      FlatButton(
                        onPressed: presentDataPicker,
                        padding: EdgeInsets.zero,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Text(
                          AppLocalizations.of(context).translate('ChangeDate'),
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Color(0xff3c84f2),
                          ),
                        ),
                      )
                    ],
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(
                  top: sizingInformation.scaleByWidth(20), bottom: 5),
              child: Text(
                AppLocalizations.of(context).translate('HowAreYou'),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  fontSize: sizingInformation.scaleByWidth(25),
                ),
              ),
            ),
            Container(
                height: sizingInformation.scaleByWidth(110),
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: 0,
                  //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: getfacesList(),
                )),
            Padding(
              padding: EdgeInsets.only(bottom: 0, top: 8),
              child: Text(AppLocalizations.of(context).translate('SaveMemory'),
                  style: TextStyle(
                      color: Color(0xff00183c),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Inter",
                      fontStyle: FontStyle.normal,
                      fontSize: sizingInformation.scaleByWidth(20)),
                  textAlign: TextAlign.center),
            ),
            isUploading
                ? Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),

            Stack(
              fit: StackFit.loose,
              children: <Widget>[
                GestureDetector(
                  onTap: showImageOptions,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.all(15),
                    height: sizingInformation.scaleByHeight(275),
                    width: sizingInformation.scaleByHeight(313),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x1a000000),
                            offset: Offset(0, 0),
                            blurRadius: 10,
                            spreadRadius: 0)
                      ],
                      color: const Color(0xffffffff),
                    ),
                    child: _selectedImage != null
                        ? GestureDetector(
                            onTap: null,
                            //  () {
                            //   if (_selectedVideo != null) {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => MediaPreviewWidget(
                            //           file: File(_selectedVideo.path),
                            //           isVideo: true,
                            //         ),
                            //       ),
                            //     );
                            //   } else {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (_) => MediaPreviewWidget(
                            //           file: File(_selectedImage.path),
                            //           isVideo: false,
                            //         ),
                            //       ),
                            //     );
                            //   }
                            // },
                            child: Image.file(
                              File(_selectedImage.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Container(
                              child: Image.asset(
                                'assets/add_story_male.png',
                                fit: BoxFit.contain,
                                width: sizingInformation.scaleByHeight(160),
                                height: sizingInformation.scaleByHeight(160),
                              ),
                            ),
                          ),
                  ),
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: 0,
                  child: _selectedImage != null
                      ? GestureDetector(
                          onTap: deleteSelectedImage,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x1a000000),
                                    offset: Offset(0, 0),
                                    blurRadius: 10,
                                    spreadRadius: 0)
                              ],
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/bin.png',
                                color: Theme.of(context).accentColor,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                )
              ],
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      );
    });
  }
}
