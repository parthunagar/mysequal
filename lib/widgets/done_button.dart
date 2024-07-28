import 'package:flutter/material.dart';

class InputDoneView extends StatelessWidget {
  final Function onDone;
  @override
  InputDoneView({this.onDone});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
          child: FlatButton(
            padding: EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
            onPressed: () {
              if (onDone != null)
                onDone();
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Text("Done",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
