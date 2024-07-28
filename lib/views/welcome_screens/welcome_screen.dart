import 'package:flutter/material.dart';
import 'package:peloton/managers/auth_provider.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/views/welcome_screens/second_welcome_screen.dart';
import 'package:peloton/views/welcome_screens/third_welcome_screen.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';

import 'first_welcome_screen.dart';

class WelcomeScreenWidget extends StatefulWidget {
  final Function() notifyParent;
  final bool newGoal;
  @override
  WelcomeScreenWidget({this.notifyParent, this.newGoal});
  @override
  _WelcomeScreenWidgetState createState() => _WelcomeScreenWidgetState();
}

class _WelcomeScreenWidgetState extends State<WelcomeScreenWidget> {
  final pageController = PageController(viewportFraction: 1);

  Widget welcomeScreens(int index, PelotonUser user) {
    switch (index) {
      case 0:
        return FirstWelcomeScreen(
            showNext: widget.newGoal != null
                ? _showWhomePage
                : () {
                    pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  },
            name: user.firstName);

      case 1:
        return SecondwelcomeScreen(
          showNext: () {
            pageController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
          },
        );

      case 2:
        return ThirdWelcomeScreen(
          showNext: () {
            _showWhomePage();
          },
        );
      default:
        return Container();
    }
  }

  _showWhomePage() {
    
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => HomePagecontainer(),
    //   ),
    // );
    widget.notifyParent();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String getInitials(name) {
    List<String> nameInits = name.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider.of(context).auth.updateUserDoc('has_new_goal', false);
    return NSBaseWidget(
      builder: (context, sizingInformation) {
        PelotonUser user =
            PelotonUser.fromJson(AuthProvider.of(context).auth.currentUserDoc);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            brightness: Brightness.light,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            width: double.infinity,
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: sizingInformation.scaleByHeight(60),
                  ),
                  Container(
                      height: sizingInformation.scaleByHeight(108),
                      width: sizingInformation.scaleByHeight(108),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(54),
                      ),
                      child: user.profileImage != null &&
                              user.profileImage.length > 1
                          ? Image.network(
                              user.profileImage ?? '',
                              fit: BoxFit.cover,
                              width: sizingInformation.scaleByHeight(108),
                              height: sizingInformation.scaleByHeight(108),
                            )
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.grey.withOpacity(0.9)),
                              child: Center(
                                child: Text(
                                  getInitials(
                                      (user.firstName?.toUpperCase() ?? '') +
                                          ' ' +
                                          (user.lastName?.toUpperCase() ?? '')),
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            )),
                  SizedBox(
                    height: sizingInformation.scaleByHeight(15),
                  ),
                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: Expanded(
                      child: PageView.builder(
                        itemBuilder: (contaxt, index) {
                          return welcomeScreens(index, user);
                        },
                        itemCount: 3,
                        controller: pageController,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: sizingInformation.scaleByHeight(15),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
