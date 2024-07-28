
import 'package:flutter/material.dart';
import 'package:peloton/models/PelotonMember.dart';

class PelotonProfileImage extends StatelessWidget {
  final PelotonMember member;
  final double height;
  String getInitials(){
    if (member.name == null || member.name == ''){
      return 'NA';
    }
    List<String> nameInits = member.name.split(' ');
    if (nameInits.length > 1){
    return  nameInits[0][0] + nameInits[1][0];
    }else{
      return  nameInits[0][0];
    }
  }
  @override
  PelotonProfileImage({this.member,this.height});
  @override
  Widget build(BuildContext context) {
    return  Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19.5),
              ),
              child: (member.imageUrl != null && member.imageUrl.length > 0)  ?  Image.network(
                member.imageUrl,
                height: height,
                width: height,
                fit: BoxFit.cover,
              ) : Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5)
                ),
                child: Center(child: Text(getInitials(),style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700
                ),)),
              ),
      );
  }
}