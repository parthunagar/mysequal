import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/analytics_actions.dart';
import 'package:peloton/managers/analytics_manager.dart';
import 'package:peloton/models/patient_program.dart';

import 'my_privacy_header.dart';

class OrginizationTerms extends StatefulWidget {
  final PatientProgram orginization;
  @override
  OrginizationTerms({this.orginization});

  @override
  _OrginizationTermsState createState() => _OrginizationTermsState();
}

class _OrginizationTermsState extends State<OrginizationTerms>
    with WidgetsBindingObserver {

  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String pathPDF = "";
  String remotePDFpath = "";
  String corruptedPathPDF = "";

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      final url =
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  void initState() {
    super.initState();

    createFileOfPdfUrl().then((f) {
      setState(() {
        remotePDFpath = f.path;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xfff4f5f9),
      appBar: AppBar(
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          MyPrivacyHeader(),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  'assets/shield.png',
                  width: 55,
                  height: 62,
                ),
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).translate("MyPrivacyIntro"),
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: Container(
              child: PDF.assets(
                'assets/GeneralConsent.pdf',
                width: size.width,
                height: double.infinity,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    AnalyticsManager.instance.addEvent(AnalytictsActions.privacyLater, null);
                    Navigator.pop(context, false);
                  },
                  child: Container(
                    width: 120,
                    height: 50,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            width: 3.5,
                            color: Colors.blue,
                            style: BorderStyle.solid)),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate("Later"),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    AnalyticsManager.instance.addEvent(AnalytictsActions.privacyApprove, null);
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    width: 120,
                    height: 50,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            width: 2,
                            color: Colors.blue,
                            style: BorderStyle.solid)),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).translate("Approve"),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
