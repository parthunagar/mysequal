import 'package:flutter/material.dart';
import 'chat_manager.dart';
import 'flat_action_btn.dart';
import 'flat_chat_message.dart';
import 'flat_message_input_box.dart';
import 'flat_page_header.dart';
import 'flat_page_wrapper.dart';
import 'flat_profile_image.dart';
import 'package:intl/intl.dart' as intl;

class ChatPage extends StatefulWidget {
  final String id;
  final String dilaogId;
  final String name;
  final String imageURL;

  @override
  ChatPage({this.dilaogId, this.name, this.id, this.imageURL});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final chatStream = ChatManager.instance.chatStreamController.stream;
  @override
  initState() {
    ChatManager.instance.openedChatId = widget.dilaogId;

    ChatManager.instance.myId = widget.id;
    super.initState();
  }

  List<Widget> messages = [];

  String getMessageTime(time) {
    DateTime parseDt = DateTime.fromMillisecondsSinceEpoch(time);
    var newFormat = intl.DateFormat('EEE, MMM d ');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: ChatManager.instance.getMyMessages(),
          builder: (_, AsyncSnapshot<List<FlatChatMessage>> snap) {
            messages = snap.data;
            if (snap.data == null) {
              return Container();
            }

            return FlatPageWrapper(
              backgroundColor: Colors.white,
              scrollType: ScrollType.fixedHeader,
              reverseBodyList: false,
              header: FlatPageHeader(
                textColor: Colors.white,
                prefixWidget: FlatActionButton(
                  iconColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: widget.name,
                suffixWidget: FlatProfileImage(
                  size: 35.0,
                  onlineIndicator: false,
                  name: widget.name,
                  imageUrl: widget.imageURL,
                  onPressed: () {
                    print("Clicked Profile Image");
                  },
                ),
              ),
              children: messages,
              stream: chatStream,
              footer: SafeArea(
                top: false,
                child: FlatMessageInputBox(
                  onSubmitted: (string) {
                    print('onsubmit');
                  },
                  onChanged: (string) {
                    print('onchange');
                  },
                  dialogId: widget.dilaogId,
                  // prefix: FlatActionButton(
                  //   iconData: Icons.add,
                  //   iconSize: 24.0,
                  // ),
                  roundedCorners: true,
                ),
              ),
            );
          }),
    );
  }
}
