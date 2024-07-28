import 'package:flutter/material.dart';
import 'package:peloton/views/on_boarding.dart';

class SplashScreenwidget extends StatefulWidget {
  @override
  _SplashScreenwidgetState createState() => _SplashScreenwidgetState();
}

class _SplashScreenwidgetState extends State<SplashScreenwidget> {
  _showOnBoarding() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnBoardingWidget(),
      ),
    );
  }

  starttimer() {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        _showOnBoarding();
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Image.asset(
                    'assets/topright.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    height: 100,
                  ),
                ],
              ),
            ),
            Spacer(),
            //       Container(
            //         child: Image.asset(
            // 'assets/newlogo.png',
            // fit: BoxFit.contain,
            // alignment: Alignment.center,
            // height: 90,
            //         ),
            //       ),
            Container(
              width: 100,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  
                  backgroundColor: Color(0xff3c84f2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xff003561),
                  ),
                ),
              ),
            ),
            Spacer(),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    'assets/bottomleft.png',
                    fit: BoxFit.contain,
                    height: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
