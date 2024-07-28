import 'package:flutter/material.dart';

class FlatProfileImage extends StatelessWidget {
  final bool outlineIndicator;
  final Color outlineColor;
  final bool onlineIndicator;
  final Color onlineColor;
  final String imageUrl;
  final double size;
  final Function onPressed;
  final Color backgroundColor;
  final String name;
  final bool isGroup;

  FlatProfileImage(
      {this.outlineIndicator,
      this.onlineColor,
      this.outlineColor,
      this.imageUrl,
      this.size,
      this.onlineIndicator,
      this.onPressed,
      this.backgroundColor,
      this.name,
      this.isGroup});

  Border flatIndicatorBorder(Color color) {
    if (outlineIndicator == null) {
      return null;
    } else {
      return Border.all(
        color: color,
        width: 2.0,
      );
    }
  }

  double imageSize() {
    if (size != null) {
      return size - 4.0;
    } else {
      return 8.0;
    }
  }

  bool showOnlineIndicator() {
    if (onlineIndicator != null && onlineIndicator == true) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (outlineIndicator != null && outlineIndicator == true) {
      return InkResponse(
        onTap: onPressed,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(8.0),
              width: size ?? 50.0,
              height: size ?? 50.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: flatIndicatorBorder(
                      outlineColor ?? Theme.of(context).primaryColor)),
              child: FlatIndicatorImage(
                isGroup: isGroup,
                width: imageSize(),
                height: imageSize(),
                indicator: outlineIndicator ?? false,
                image: imageUrl,
                name: name,
              ),
            ),
            OnlineIndicator(
              isEnabled: showOnlineIndicator(),
              color: onlineColor,
              size: size ?? 50.0,
              borderColor: backgroundColor,
            ),
          ],
        ),
      );
    } else {
      return InkResponse(
        onTap: onPressed,
        child: Stack(
          children: [
            FlatIndicatorImage(
              isGroup: isGroup,
              width: size ?? 50.0,
              height: size ?? 50.0,
              indicator: outlineIndicator ?? false,
              image: imageUrl,
              name: name,
            ),
            OnlineIndicator(
              isEnabled: showOnlineIndicator(),
              color: onlineColor,
              size: size ?? 50.0,
              borderColor: backgroundColor,
            )
          ],
        ),
      );
    }
  }
}

class OnlineIndicator extends StatelessWidget {
  final bool isEnabled;
  final Color color;
  final double size;
  final Color borderColor;
  OnlineIndicator({this.isEnabled, this.color, this.size, this.borderColor});

  @override
  Widget build(BuildContext context) {
    double position = (size / 100) * 15.0;

    return Positioned(
      bottom: position ?? 0.0,
      right: position ?? 0.0,
      child: Container(
        width: isEnabled ? 15.0 : 0.0,
        height: isEnabled ? 15.0 : 0.0,
        decoration: BoxDecoration(
            color: color ?? Theme.of(context).primaryColor,
            border: Border.all(
              color: borderColor ?? Theme.of(context).primaryColorLight,
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}

class FlatIndicatorImage extends StatelessWidget {
  final String image;
  final double width;
  final double height;
  final bool indicator;
  final String name;
  final isGroup;
  FlatIndicatorImage({
    this.image,
    this.width,
    this.height,
    this.indicator,
    this.name,
    this.isGroup
  });

  double imageMargin() {
    return indicator ? 4.0 : 8.0;
  }

  String getInitials(user) {
    List<String> nameInits = user.split(' ');
    if (nameInits.length > 1) {
      return nameInits[0][0] + nameInits[1][0];
    } else {
      return nameInits[0][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
      margin: EdgeInsets.all(imageMargin()),
      width: width,
      height: height,
      child: ClipOval(
        child: profileImage(),
      ),
    );
  }

  Widget profileImage() {
    if(isGroup != null){
          return Image.asset(
        'assets/groupchat.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      );
    }
    if (image == null || image.isEmpty) {
      // return Image.asset(
      //   'assets/default_profile_image.png',
      //   fit: BoxFit.cover,
      // );
      return Center(
          child: Text(
        getInitials(name),
        style: TextStyle(
            fontFamily: 'Inter', fontSize: 17, fontWeight: FontWeight.w500),
      ));
    } else {
      return Image.network(
        image,
        fit: BoxFit.cover,
      );
    }
  }
}
