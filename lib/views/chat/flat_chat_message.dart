import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';

enum MessageType { sent, received }

class FlatChatMessage extends StatelessWidget {
  final String message;
  final MessageType messageType;
  final Color backgroundColor;
  final Color textColor;
  final String time;
  final bool showTime;
  final double maxWidth;
  final double minWidth;
  final String sender;
  final bool showDate;
  final String date;
  final DateTime messageSentTime;
  final String senderName;

  FlatChatMessage(
      {this.message,
      this.messageType,
      this.backgroundColor,
      this.textColor,
      this.time,
      this.showTime,
      this.minWidth,
      this.maxWidth,
      this.sender,
      this.showDate,
      this.date,
      this.messageSentTime,
      this.senderName});

  CrossAxisAlignment messageAlignment() {
    if (messageType == null || messageType == MessageType.received) {
      return CrossAxisAlignment.start;
    } else {
      return CrossAxisAlignment.end;
    }
  }

  double topLeftRadius() {
    if (messageType == null || messageType == MessageType.received) {
      return 0.0;
    } else {
      return 12.0;
    }
  }

  double topRightRadius() {
    if (messageType == null || messageType == MessageType.received) {
      return 12.0;
    } else {
      return 0.0;
    }
  }

  Color messageBgColor(BuildContext context) {
    if (messageType == null || messageType == MessageType.received) {
      return Theme.of(context).primaryColor;
    } else {
      return Theme.of(context).primaryColorDark.withOpacity(0.1);
    }
  }

  Color messageTextColor(BuildContext context) {
    if (messageType == null || messageType == MessageType.received) {
      return Colors.white;
    } else {
      return Theme.of(context).primaryColorDark;
    }
  }

  Text messageTime() {
    if (showTime != null && showTime == true) {
      return Text(
        time ?? "Time",
        style: TextStyle(
          fontSize: 12.0,
          color: Color(0xFF666666),
        ),
      );
    } else {
      return null;
    }
  }

  Text messageDate(context) {
    final style = TextStyle(
        fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.w700);
    if (showDate != null && showDate == true) {
      final today = Duration(hours: 24);
      final now = Duration(minutes: 2);
      final yesterday = Duration(minutes: 48);
      if (DateTime.now().difference(messageSentTime) < now) {
        return Text(
          AppLocalizations.of(context).translate("Now"),
          style: style,
        );
      }
      if (DateTime.now().difference(messageSentTime) < today) {
        return Text(
          AppLocalizations.of(context).translate("Today"),
          style: style,
        );
      }
      if (DateTime.now().difference(messageSentTime) < yesterday) {
        return Text(
          AppLocalizations.of(context).translate("Yesterday"),
          style: style,
        );
      }
      return Text(
        date ?? "",
        style: style,
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 24.0,
      ),
      child: Column(
        crossAxisAlignment: messageAlignment(),
        children: [
          showDate
              ? Row(
                  children: [messageDate(context)],
                  mainAxisAlignment: MainAxisAlignment.center,
                )
              : Container(),
          senderName != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    senderName,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Container(),
          Container(
            constraints: BoxConstraints(
                minWidth: minWidth ?? 100.0, maxWidth: maxWidth ?? 250.0),
            decoration: BoxDecoration(
              color: backgroundColor ?? messageBgColor(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topLeftRadius()),
                topRight: Radius.circular(topRightRadius()),
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              ),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Text(
              message,
              style: TextStyle(
                color: textColor ?? messageTextColor(context),
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5),
            constraints: BoxConstraints(
                minWidth: minWidth ?? 100.0, maxWidth: maxWidth ?? 250.0),
            child: Text(
              time,
              textAlign: messageType == MessageType.received
                  ? TextAlign.start
                  : TextAlign.end,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
