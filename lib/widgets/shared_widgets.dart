import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class BackGroundView extends StatelessWidget {
  _sendEmail() async {
    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: ['contact@sequel.care'],
      isHTML: false,
    );
    try {
      await FlutterEmailSender.send(email);
    } on Exception catch (exception) {
      print(exception);
    } catch (error) {
      print(error);
    }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: Container(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/logo_bg.png',
                fit: BoxFit.cover,
                //height: 120,
              ),
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                        'assets/footer_bg.png',
                      )),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/MySequel.png',
                        height: 51,
                        width: 113,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () {
                          _sendEmail();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                  .translate('NeedHelp'),
                              style: TextStyle(
                                color: Color(0xff00183c),
                                fontSize: 17,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                //Theme.of(context).primaryTextTheme.headline5,
                              ),
                            ),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('ContactUs'),
                              style: TextStyle(
                                  color: Color(0xff00183c),
                                  fontSize: 17,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  //Theme.of(context).primaryTextTheme.headline5,
                                  decoration: TextDecoration.underline),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Flexible(
                        child: RichText(
                          maxLines: 2,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    openTermsOfUse();
                                  },
                                style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: const Color(0xff00183c),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Inter",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 13.0),
                                text: AppLocalizations.of(context)
                                        .translate('TermsOfUse') +
                                    ' ',
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
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                bottom: 25,
              ),
            ],
          ),
        )
      ],
    );
  }
}

class HeaderViewWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  @override
  HeaderViewWidget({this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //double height = Scaffold.of(context).appBarMaxHeight;

    return Container(
      padding: EdgeInsets.fromLTRB(33, 0, 33, 37),
      height: screenHeight * 0.165,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.zero,
          topRight: Radius.zero,
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        color: Color(0xff3c84f2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).primaryTextTheme.headline1,
          ),
          SizedBox(
            height: 9,
          ),
          Text(
            subtitle,
            style: Theme.of(context).primaryTextTheme.headline2,
          ),
        ],
      ),
    );
  }
}

Widget smallBackgroundView() {
  return Expanded(
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 25,
        ),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(
                        'assets/footer_bg.png',
                      )),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    'assets/MySequel.png',
                    height: 51,
                    width: 113,
                  ),
                ),
                bottom: 20,
              ),
            ],
          ),
        )
      ],
    ),
  );
}
