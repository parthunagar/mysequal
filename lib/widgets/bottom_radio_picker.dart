import 'package:flutter/material.dart';


class BottomRadioListWidget extends StatefulWidget {
  final List<String> data;
  final String title;
  final String defaultValue;
  @override
  BottomRadioListWidget({this.data, this.title, this.defaultValue});
  @override
  _BottomRadioListWidgetState createState() => _BottomRadioListWidgetState();
}

class _BottomRadioListWidgetState extends State<BottomRadioListWidget>
    with SingleTickerProviderStateMixin {
  String _character;
  AnimationController expandController;
  Animation<double> animation;
  bool shouldExpand = false;
  @override
  void initState() {
    _character = widget.defaultValue ?? widget.data.first;
    prepareAnimations();
    Future.delayed(Duration(milliseconds: 100), () {
      shouldExpand = true;
      _runExpandCheck();
    });
    super.initState();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  returnValue() {
    Navigator.pop(context, _character);
  }

  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (shouldExpand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dataList = [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            color: Colors.blue,
            onPressed: () {
              print(_character);
              Navigator.pop(context, _character);
            },
          )
        ],
      ),
      Container(
        alignment: Alignment.bottomCenter,
        height: 40,
        child: Text(
          widget.title,
          style: TextStyle(
              color: const Color(0xff00183c),
              fontWeight: FontWeight.w700,
              fontFamily: "Inter",
              fontStyle: FontStyle.normal,
              fontSize: 20.0),
        ),
      ),
      Divider(
        indent: 30,
        endIndent: 30,
      )
    ];
    widget.data.forEach((element) {
      dataList.add(
        RadioListTile<String>(
          title: Text(element),
          value: element,
          groupValue: _character,
          onChanged: (String value) {
            setState(() {
              Future.delayed(Duration(milliseconds: 300), () {
                // AuthProvider.of(context)
                //     .auth
                //     .updateUserDoc(widget.title.toLowerCase(), _character);
                Navigator.pop(context, _character);
              });
              _character = value;
            });
          },
        ),
      );
    });
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Container(
        
        height: double.infinity,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(bottom:25),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: dataList,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
