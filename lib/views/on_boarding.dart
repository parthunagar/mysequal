import 'package:flutter/material.dart';
import 'package:peloton/localization/app_localization.dart';
import 'package:peloton/managers/layout_adapter.dart';
import 'package:peloton/views/auth_process/login_page.dart';
import 'package:peloton/widgets/NSbasicWidget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/services.dart';

class OnBoardingWidget extends StatefulWidget {
  @override
  _OnBoardingWidgetState createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {

  @override
  void initState() {
    print('on boarding');
    super.initState();
  }

  final pageController = PageController(viewportFraction: 1);

  _showLogIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogInWidget(),
      ),
    );
  }
  

  Widget onBoardingTile(index, SizingInformation sizingInformation) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(height: sizingInformation.scaleByHeight(45)),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight:sizingInformation.scaleByHeight(161)),
          child: Image.asset(
            'assets/${index + 1}.png',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        //SizedBox(height: screenHeight * 0.067),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
              child: Text(
                AppLocalizations.of(context)
                    .translate("onBoardTitle${index + 1}"),
                style: Theme.of(context).primaryTextTheme.bodyText1,
              ),
            ),
            SizedBox(height: sizingInformation.scaleByHeight(45)),
            Container(
                padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                child: Text(
                  AppLocalizations.of(context)
                      .translate("onBoardSubTitle${index + 1}"),
                  style: Theme.of(context).primaryTextTheme.bodyText2,
                )),
            SizedBox(height: sizingInformation.scaleByHeight(31)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
              onPressed: () {
                if (pageController.page == 3) _showLogIn();
                pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              },
              child: Container(
                height: 54,
                constraints: BoxConstraints(minWidth: 210),
                padding: EdgeInsets.fromLTRB(21, 15, 21, 15),
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(27)),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)
                        .translate("onBoardButton${index + 1}"),
                    style: Theme.of(context).primaryTextTheme.button,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    return NSBaseWidget(builder: (context, sizingInformation) {
      return Scaffold(
        extendBodyBehindAppBar: false,
        body: Container(
          height: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: PageView.builder(
                  itemBuilder: (contaxt, index) {
                    return onBoardingTile(index, sizingInformation);
                  },
                  itemCount: 4,
                  controller: pageController,
                ),
              ),
              SizedBox(height: sizingInformation.scaleByHeight(58)),
              SizedBox(
                height: sizingInformation.scaleByHeight(233),
                child: Stack(
                  fit: StackFit.loose,
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
                          height: sizingInformation.scaleByHeight(60),
                          width: sizingInformation.scaleByHeight(120),
                        ),
                      ),
                      bottom: sizingInformation.scaleByHeight(63),
                    ),
                    Positioned.fill(
                      bottom: sizingInformation.scaleByHeight(23),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          child: SmoothPageIndicator(
                            controller: pageController,
                            count: 4,
                            effect: WormEffect(
                                activeDotColor: Theme.of(context).primaryColor,
                                dotColor: Colors.grey.withOpacity(0.3),
                                paintStyle: PaintingStyle.fill,
                                radius: 11,
                                strokeWidth: 1),
                          ),
                        ),
                      ),
                    ),
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
