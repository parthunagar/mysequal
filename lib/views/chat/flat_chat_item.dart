import 'package:flutter/material.dart';

import 'flat_profile_image.dart';

class FlatChatItem extends StatelessWidget {
  final Widget profileImage;
  final String name;
  final String message;
  final Widget counter;
  final Color nameColor;
  final Color messageColor;
  final Color backgroundColor;
  final bool multiLineMessage;
  final Function onPressed;
  final String time;
  final String goal;

  FlatChatItem({
    Key key,
    this.profileImage,
    this.name,
    this.goal,
    this.message,
    this.counter,
    this.nameColor,
    this.messageColor,
    this.backgroundColor,
    this.multiLineMessage,
    this.onPressed,
    this.time,
  }) : super(key: key);
  // Future<String> getGoalName(goal) async {
  //   var doc =
  //       await FirebaseFirestore.instance.collection('goals').doc(goal).get();
  //   if (doc.exists) {
  //     print('goal data ******');
  //     print(doc.data()['goal_name']);
  //     return doc.data()['goal_name'];
  //   } else {
  //     return goal;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        color: backgroundColor ?? Theme.of(context).primaryColorLight,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: multiLineMessage == true
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              profileImage ?? FlatProfileImage(),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: 5.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 180),
                            margin: EdgeInsets.only(
                              bottom: 4.0,
                              top: multiLineMessage == true ? 8.0 : 0.0,
                            ),
                            child: Text(
                              (goal ?? name),
                              style: TextStyle(
                                fontSize: 16.0,
                                color: nameColor ??
                                    Theme.of(context).primaryColorDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: Text(
                                message ?? "",
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: multiLineMessage == true ? 100 : 1,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: counter != null ? FontWeight.w600 : FontWeight.w400,
                                  color: messageColor ??
                                      Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.5),
                                ),
                              ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                             SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: 100.0,
                            child: Text(
                              time ?? "",
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: multiLineMessage == true ? 100 : 1,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: counter != null ? FontWeight.w600 : FontWeight.w400 ,
                                color: Color(0xff3c84f2),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          counter ?? Container(),
                        ],
                      )
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
