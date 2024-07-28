import 'package:flutter/material.dart';
import 'package:peloton/managers/auth_provider.dart';

class NoStoryWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        AuthProvider.of(context)
                    .auth
                    .currentUserDoc['gender']
                    .toString()
                    .toLowerCase() ==
                'male'
            ? 'assets/no_story_male.png'
            : 'assets/no_story_female.png',
        fit: BoxFit.contain,
        height: 250,
        width: 200,
      ),
    );
  }
}
