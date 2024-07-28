import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonGoal.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/peloton_profissional.dart';
import 'package:quickblox_sdk/chat/constants.dart';
import 'package:quickblox_sdk/models/qb_dialog.dart';
import 'package:quickblox_sdk/models/qb_sort.dart';
import 'package:quickblox_sdk/quickblox_sdk.dart';
import 'chat_header.dart';
import 'chat_manager.dart';
import 'chat_page.dart';
import 'flat_chat_item.dart';
import 'flat_counter.dart';
import 'flat_profile_image.dart';
import 'flat_section_header.dart';
import 'package:intl/intl.dart' as intl;

class TalkPage extends StatefulWidget {
  @override
  _TalkPageState createState() => _TalkPageState();
}

class _TalkPageState extends State<TalkPage> {
  final groupStream = ChatManager.instance.globalStream.stream;
  StreamSubscription<ConnectivityResult> subscription;

  List<PelotonGoal> goalsNames = [];
  bool hasConnection = true;
  @override
  initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          hasConnection = false;
        });
      } else {
        setState(() {
          hasConnection = true;
        });
      }
    });

      ChatManager.instance.subscribeToNewMessageEvent();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  String getGoalName(name) {
    for (var goal in goalsNames) {
      if (goal.id == name) {
        return goal.title;
      }
    }
    return name;
  }

  Future<List<QBDialog>> getMyDialogs(
      List<PelotonProfissional> professionalsList) async {
    var idsList =
        professionalsList.map((e) => e.chatParams.chatUserId).toList();
    final myid = AuthProvider.of(context).auth.currentUserDoc['chat_params']
        ['chat_user_id'];
    idsList.add(myid);
    QBSort sort = QBSort();
    sort.field = QBChatDialogFilterFields.LAST_MESSAGE_DATE_SENT;
    sort.ascending = false;

    try {
      var dialogsList = await QB.chat.getDialogs(sort: sort);

      List<QBDialog> newDialogList =
          dialogsList.where((f) => f.type == 3).toList();
      var newList = newDialogList.where((element) {
        var result = true;

        for (var user in element.occupantsIds) {
          if (!result) return false;
          if (!idsList.contains(user)) {
            result = false;
          }
        }
        return result;
      }).toList();

      return newList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<QBDialog>> getMyGroupDialogs(
      List<PelotonProfissional> professionalsList) async {
    var idsList =
        professionalsList.map((e) => e.chatParams.chatUserId).toList();
    final myid = AuthProvider.of(context).auth.currentUserDoc['chat_params']
        ['chat_user_id'];
    idsList.add(myid);
    QBSort sort = QBSort();
    sort.field = QBChatDialogFilterFields.LAST_MESSAGE_DATE_SENT;
    sort.ascending = false;

    try {
      var dialogsList = await QB.chat.getDialogs(sort: sort);

      var newList = dialogsList.where((f) => f.type == 2).toList();

      var filteredList = newList.where((element) {
        var result = true;

        for (var user in element.occupantsIds) {
          if (!result) return false;
          if (!idsList.contains(user)) {
            result = false;
          }
        }
        return result;
      }).toList();

      
      return filteredList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  String getMessageTime(time) {
    if (time == null) return '';
    DateTime parseDt = DateTime.fromMillisecondsSinceEpoch(time);
    var newFormat = intl.DateFormat('EEE, MMM d ');
    String updatedDt = newFormat.format(parseDt);
    return updatedDt;
  }

  openChatWithUser(myId, PelotonProfissional user) async {
    print('open chat with $user');
    var result = await QB.chat.createDialog(
        [myId, user.chatParams.chatUserId], user.personalInformation.name,
        dialogType: QBChatDialogTypes.CHAT);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
            id: myId.toString(),
            dilaogId: result.id,
            name: result.name,
            imageURL: user.personalInformation.profileImage),
      ),
    );
  }

  List<PelotonProfissional> professionalsList = [];
  @override
  Widget build(BuildContext context) {
    var userDoc = AuthProvider.of(context).auth.currentUserDoc;
    var orgIDs =
        AuthProvider.of(context).auth.currentUserDoc['organizationsID'] ?? [];
    var pelotonUser = PelotonUser.fromJson(userDoc);
    var myId = pelotonUser.chatParams.chatUserId;
    var userId = pelotonUser.id;
    List<Map> orgsList =
        AuthProvider.of(context).auth.currentUserDoc['caseManager'] ?? [];

    return FutureBuilder(
      future: Connectivity().checkConnectivity(),
      builder: (_, connSnap) {
        if (connSnap.data == null || connSnap.data == ConnectivityResult.none) {
          return Container(
            padding: EdgeInsets.all(12),
            child: Center(
              child: Text(
                AppLocalizations.of(context).translate("NoInternet"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('goals')
              .where('patientid', isEqualTo: userId)
              .where('orginization', whereIn: orgIDs)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              return Container();
            }
            if (snapshot.data == null ||
                !hasConnection ||
                (snapshot.data.docs.length == 0 && orgsList.length == 0)) {
              return Container(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    !hasConnection
                        ? AppLocalizations.of(context).translate("NoInternet")
                        : AppLocalizations.of(context)
                            .translate("NoChatsMessage"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }
            List<DocumentReference> usersList = [];
            for (var temp in orgsList) {
              usersList.add(temp['casemaneger']);
            }

            return Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ChatHeader(),
                  Container(
                    color: Color(0xfff4f5f9).withOpacity(0.5),
                    //padding: EdgeInsets.all(5),
                    child: Builder(
                      builder: (cnx) {
                        if (snapshot.data == null) {
                          return Container();
                        }
                        for (var doc in snapshot.data.docs) {
                          PelotonGoal goal = PelotonGoal.fromJson(doc.data());
                          goal.id = doc.documentID;
                          goalsNames.add(goal);
                          for (var item in goal.supportive ?? []) {
                            var shouldAdd = true;
                            for (var listitem in usersList) {
                              if (listitem.id == item.id) {
                                shouldAdd = false;
                                continue;
                              }
                            }
                            if (shouldAdd) {
                              usersList.add(item);
                            }
                          }
                          var ownerRef = doc.data()['owner'];
                          var shouldAdd = true;
                          for (var listitem in usersList) {
                            if (listitem.id == ownerRef.id) {
                              shouldAdd = false;
                              continue;
                            }
                          }
                          if (shouldAdd) {
                            usersList.add(ownerRef);
                          }
                        }

                        var newList = usersList.toSet().toList();

                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              newList.length > 0
                                  ? FlatSectionHeader(
                                      backgroundColor: Colors.transparent,
                                      title: AppLocalizations.of(context)
                                          .translate("MyCareTeam"),
                                    )
                                  : Container(),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                height: newList.length > 0 ? 120 : 0,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: newList.length,
                                  itemBuilder: (_, index) {
                                    return FutureBuilder(
                                      future: newList[index].get(),
                                      builder: (_, userSnap) {
                                        if (userSnap.data == null) {
                                          return Container();
                                        } else {
                                          PelotonProfissional user =
                                              PelotonProfissional.fromJson(
                                                  userSnap.data.data());
                                          professionalsList.add(user);
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              user.personalInformation
                                                          .profileImage.length >
                                                      0
                                                  ? FlatProfileImage(
                                                      onPressed: () {
                                                        openChatWithUser(
                                                            myId, user);
                                                      },
                                                      imageUrl: user
                                                              .personalInformation
                                                              .profileImage ??
                                                          '',
                                                      onlineIndicator: false,
                                                      outlineIndicator: true,
                                                    )
                                                  : FlatProfileImage(
                                                      onPressed: () {
                                                        openChatWithUser(
                                                            myId, user);
                                                      },
                                                      imageUrl: null,
                                                      name: user
                                                          .personalInformation
                                                          .name,
                                                      onlineIndicator: false,
                                                      outlineIndicator: true,
                                                    ),
                                              Container(
                                                width: 100,
                                                child: Text(
                                                  user.personalInformation.name,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              // Text(
                                              //   user.employmentDetails
                                              //           .professionTitle ??
                                              //       'Supportive',
                                              //   style: TextStyle(
                                              //     fontSize: 12,
                                              //     fontFamily: 'Inter',
                                              //     fontWeight: FontWeight.normal,
                                              //   ),
                                              // ),
                                            ],
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              Divider(
                                thickness: 0.5,
                                height: 2,
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: Container(
                        child: StreamBuilder(
                          stream: groupStream,
                          builder: (context, snapshot) {
                            return ListView(
                              children: <Widget>[
                                // FlatSectionHeader(
                                //   title: AppLocalizations.of(context)
                                //       .translate("Latest"),
                                // ),
                                FutureBuilder(
                                  future: getMyDialogs(professionalsList),
                                  builder:
                                      (_, AsyncSnapshot<List<QBDialog>> snap) {
                                    if (snap.hasError != false) {
                                      return Container();
                                    }
                                    if (snap.data == null) {
                                      return Container();
                                    }
                                    if (snap.data.length == 0) {
                                      return Container();
                                    }
                                    List<Widget> chats = [];
                                    for (var item in snap.data) {
                                      chats.add(FlatChatItem(
                                        nameColor: Color(0xff003561),
                                        messageColor: Color(0xff003561),
                                        key: UniqueKey(),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  imageURL: item.photo,
                                                  id: myId.toString(),
                                                  dilaogId: item.id,
                                                  name: item.name,
                                                ),
                                              ));
                                        },
                                        name: item.name,
                                        profileImage: FlatProfileImage(
                                          imageUrl: item.photo,
                                          name: item.name,
                                          onlineIndicator: false,
                                        ),
                                        backgroundColor: Colors.white,
                                        message: item.lastMessage,
                                        multiLineMessage: true,
                                        counter:
                                            (item.unreadMessagesCount ?? 0) > 0
                                                ? FlatCounter(
                                                    text: item
                                                        .unreadMessagesCount
                                                        .toString(),
                                                  )
                                                : null,
                                        time: getMessageTime(
                                            item.lastMessageDateSent),
                                      ));
                                    }
                                    return Column(
                                      children: chats,
                                    );
                                  },
                                ),
                                FutureBuilder(
                                  future: getMyGroupDialogs(professionalsList),
                                  builder:
                                      (_, AsyncSnapshot<List<QBDialog>> snap) {
                                    if (snap.hasError != false) {
                                      return Container();
                                    }
                                    if (snap.data == null) {
                                      return Container();
                                    }
                                    List<Widget> chats = [];
                                    for (var item in snap.data) {
                                      ChatManager.instance
                                          .joinGroupChat(item.id);
                                      chats.add(FlatChatItem(
                                        nameColor: Color(0xff003561),
                                        messageColor: Color(0xff003561),
                                        key: UniqueKey(),
                                        onPressed: () async {
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  imageURL: item.photo,
                                                  id: myId.toString(),
                                                  dilaogId: item.id,
                                                  name: getGoalName(item.name),
                                                ),
                                              ));
                                          //ChatManager.instance.leavDialog(item.id);
                                        },
                                        backgroundColor: Colors.white,
                                        goal: getGoalName(item.name),
                                        profileImage: FlatProfileImage(
                                          isGroup: true,
                                          imageUrl: item.photo,
                                          name: item.name,
                                          onlineIndicator: false,
                                        ),
                                        message: item.lastMessage,
                                        multiLineMessage: true,
                                        counter:
                                            (item.unreadMessagesCount ?? 0) > 0
                                                ? FlatCounter(
                                                    text: item
                                                        .unreadMessagesCount
                                                        .toString(),
                                                  )
                                                : null,
                                        time: getMessageTime(
                                            item.lastMessageDateSent),
                                      ));
                                    }

                                    if (chats.length > 0) {
                                      chats.insert(
                                        0,
                                        FlatSectionHeader(
                                          title: AppLocalizations.of(context)
                                              .translate("MyGroups"),
                                        ),
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: chats,
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
