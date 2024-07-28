import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/views/chat/chat_manager.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';

import 'flat_action_btn.dart';

class FlatMessageInputBox extends StatefulWidget {
  final Widget prefix;
  final Widget suffix;
  final bool roundedCorners;
  final Function onChanged;
  final Function onSubmitted;
  final String dialogId;
  FlatMessageInputBox(
      {this.prefix,
      this.suffix,
      this.roundedCorners,
      this.onChanged,
      this.onSubmitted,
      this.dialogId});

  @override
  _FlatMessageInputBoxState createState() => _FlatMessageInputBoxState();
}

class _FlatMessageInputBoxState extends State<FlatMessageInputBox> {
  final controller = TextEditingController();
  bool isSending = false;

  sendMessage(context) async {
       setState(() {
        isSending = true;
      });

    try {
      var result = await QB.chat.isConnected();
      if (!result) {
        var user =
            PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);

        await QB.chat
            .connect(user.chatParams.chatUserId, user.chatParams.password);
      }

      await QB.chat.sendMessage(
        widget.dialogId,
        body: controller.text,
        saveToHistory: true,
      );
      setState(() {
        isSending = false;
      });
      
    } on PlatformException catch (e) {
      print(e);
      return null;
      // Some error occured, look at the exception message for more details
    }

    print('message sent');
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    double cornerRadius() {
      if (widget.roundedCorners != null && widget.roundedCorners == true) {
        return 60.0;
      } else {
        return 0.0;
      }
    }

    double padding() {
      if (widget.roundedCorners != null && widget.roundedCorners == true) {
        return 12.0;
      } else {
        return 8.0;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cornerRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 20,
            blurRadius: 20,
            offset: Offset(0, -5), // changes position of shadow
          )
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark.withOpacity(0.3),
          borderRadius: BorderRadius.circular(cornerRadius()),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: padding(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            widget.prefix ??
                SizedBox(
                  width: 0,
                  height: 0,
                ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context).translate("EnterMessage"),
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColorDark.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(
                    16.0,
                  ),
                ),
                style: TextStyle(color: Theme.of(context).primaryColorDark),
              ),
            ),
            widget.suffix ??
                SizedBox(
                  width: 0,
                  height: 0,
                ),
           isSending ? Center(child: CircularProgressIndicator()) : FlatActionButton(
              icon: Icon(
                Icons.send,
                size: 24.0,
                color: Theme.of(context).primaryColorDark,
              ),
              onPressed:(){sendMessage(context);} ,
            ),
          ],
        ),
      ),
    );
  }
}
