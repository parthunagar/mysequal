import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'dart:convert';

class HomePageHeaader extends StatefulWidget {
  @override
  _HomePageHeaaderState createState() => _HomePageHeaaderState();
}

class _HomePageHeaaderState extends State<HomePageHeaader> {
  int weekNumber() {
    var date = FirebaseAuth.instance.currentUser.metadata.creationTime;
    if (date == null) {
      return 1;
    }
    var nowDate = DateTime.now();
    var timeDeff = (nowDate.difference(date).inDays / 7).floor() + 1;

    // int dayOfYear = int.parse(DateFormat.d('en').format(date));
    // DateFormat.d
    // int weekday = date.weekday;

    // var diff =  ((dayOfYear - weekday + 10) / 7).floor();
    print('week diff');
     print(timeDeff);

    return timeDeff;
  }

  Map getMessage() {
    print(weekNumber());

    var status = AppLocalizations.of(context).translate(
      'InspirationWeek${weekNumber()}',
    );

    var decodedStatus = json.decode(status.replaceAll("\'", "\""));
    print(decodedStatus);
    // List<String> statusList = [];
    // decodedStatus.entries.forEach((e) => statusList.add(e.value.toString()));
    return decodedStatus;
  }

  //bool liked = false;
  @override
  Widget build(BuildContext context) {
    return NSBaseWidget(builder: (context, sizingInformation) {
      var messageJson = getMessage();
      return SafeArea(
        child: Container(
          height: 90,
          // padding: EdgeInsets.only(
          //   top:80
          // ),

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(
                    sizingInformation.scaleByHeight(43), 5, 43, 5),
                child: Text(
                  messageJson['body'],
                  style: Theme.of(context).primaryTextTheme.headline4,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 27.0, right: 30.0, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      messageJson['author'],
                      style: Theme.of(context).primaryTextTheme.caption,
                    ),
                    // new FlatButton(
                    //   splashColor: Colors.transparent,
                    //   highlightColor: Colors.transparent,
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       border: Border.all(color: Colors.white),
                    //       borderRadius: BorderRadius.circular(3),
                    //     ),
                    //     height: 20,
                    //     width: 58,
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //       children: <Widget>[
                    //         liked
                    //             ? Icon(
                    //                 Icons.favorite,
                    //                 color: Colors.red,
                    //                 size: 14,
                    //               )
                    //             : Icon(
                    //                 Icons.favorite_border,
                    //                 color: Colors.black,
                    //                 size: 14,
                    //               ),
                    //         Text(
                    //           liked ? AppLocalizations.of(context).translate("Liked") :
                    //           AppLocalizations.of(context).translate("Like"),
                    //           style: Theme.of(context).primaryTextTheme.headline6,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   onPressed: () {
                    //     setState(() {
                    //       liked = !liked;
                    //     });
                    //   },
                    //   // shape: RoundedRectangleBorder(
                    //   //   borderRadius: BorderRadius.circular(8),
                    //   //   side: BorderSide(
                    //   //     color: Colors.white,
                    //   //     width: 1,
                    //   //     style: BorderStyle.solid,
                    //   //   ),
                    //   // ),
                    // )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
