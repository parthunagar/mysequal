import 'package:flutter/material.dart';
import 'package:peloton/widgets/done_alert.dart';

class HelpOnTheWay extends StatelessWidget {
  final String note;
  final String name;
  @override
  HelpOnTheWay({this.note, this.name});

  showDonealert(context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => DoneAlert(
          title:
              'This Hand Raise Created successfull',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //  var myData =
    //    PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Positioned(
              bottom: 0,
              right: 1,
              left: 1,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    color: Colors.white),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                          color: Colors.blue,
                          icon: Icon(Icons.close),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/hand_raised.png',
                        height: 50,
                        width: 32,
                      ),
                    ),
                    Text(
                      "Help is on it’s way",
                      style: const TextStyle(
                          color: const Color(0xff00183c),
                          fontWeight: FontWeight.w700,
                          fontFamily: "Inter",
                          fontStyle: FontStyle.normal,
                          fontSize: 20.0),
                    ),
                    Divider(
                      indent: 40,
                      endIndent: 40,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                    //   child: Text(
                    //     "Expect a response from $name soon",
                    //     style: const TextStyle(
                    //         color: const Color(0xff4a4a4a),
                    //         fontWeight: FontWeight.w400,
                    //         fontFamily: "Inter",
                    //         fontStyle: FontStyle.normal,
                    //         fontSize: 18.0),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/cryptocurrency.png',
                        height: 60,
                        width: 60,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "$name got your call for help with the task:",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: const Color(0xff4a4a4a),
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.normal,
                            fontSize: 20.0),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(8),
                      // decoration: BoxDecoration(
                      //   color: Color(0xfff4f4f4),
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
                      padding: EdgeInsets.all(12),
                      child: Text(
                        note != null ? note : "",
                        style: const TextStyle(
                            color: const Color(0xff00183c),
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontStyle: FontStyle.italic,
                            
                            fontSize: 20),
                      ),
                    ),
                    //Spacer(),
                    Padding(
                      padding: const EdgeInsets.only( bottom: 30),
                      child: FlatButton(
                        onPressed: () {
                          showDonealert(context);
                        },
                        child: Text("Done",
                            style: TextStyle(
                                color: Color(0xff3c84f2),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Inter",
                                fontStyle: FontStyle.normal,
                                fontSize: 22),
                            textAlign: TextAlign.left),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
