import 'package:cloud_firestore/cloud_firestore.dart';

class PelotonUser {
  String id;
  String dateOfBirth;
  String emailAddress;
  String firstName;
  String gender;
  String lastName;
  String phone;
  String maritalStatus;
  String profileImage;
  List<dynamic> permittedUsers;
  List<dynamic> comorbidities;
  ChatParams chatParams;
  bool hasNewGoal;
  TermsConfirm userTerms;

  PelotonUser({
    this.id,
    this.dateOfBirth,
    this.emailAddress,
    this.firstName,
    this.gender,
    this.lastName,
    this.phone,
    this.maritalStatus,
    this.profileImage,
    this.permittedUsers,
    this.comorbidities,
    this.chatParams,
    this.hasNewGoal,
    this.userTerms,
  });

  factory PelotonUser.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic> arrayOfuser = parsedJson['permitted_users'] ?? [];
    return PelotonUser(
        id: parsedJson['id'],
        dateOfBirth: parsedJson['date_of_birth'],
        emailAddress: parsedJson['email_address'],
        firstName: parsedJson['first_name'],
        gender: parsedJson['gender'],
        lastName: parsedJson['last_name'],
        phone: parsedJson['phone'],
        maritalStatus: parsedJson['marital_status'],
        profileImage: parsedJson['profile_image'],
        permittedUsers: arrayOfuser,
        comorbidities: parsedJson['comorbidities'],
        hasNewGoal: parsedJson['has_new_goal'],
        userTerms: TermsConfirm.fromJson(parsedJson['user_terms']),
        chatParams: ChatParams.fromJson(parsedJson['chat_params']));
  }
  updateUserBirthdate(date) {
    FirebaseFirestore.instance.collection('patients').doc('${this.id}').update(
      {
        'date_of_birth': date.toString(),
      },
    );
  }

  updateUserProfileImage(image) {
    FirebaseFirestore.instance.collection('patients').doc('${this.id}').update(
      {
        'profile_image': image.toString(),
      },
    );
  }
}

class ChatParams {
  final int chatUserId;
  final String password;
  final String userName;

  ChatParams({
    this.chatUserId,
    this.password,
    this.userName,
  });

  factory ChatParams.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return ChatParams(chatUserId: 0, userName: '', password: '');
    }
    return ChatParams(
      chatUserId: parsedJson['chat_user_id'] ?? '',
      password: parsedJson['password'] ?? '',
      userName: parsedJson['username'] ?? '',
    );
  }
}

class TermsConfirm {
  final bool didAgree;
  final Timestamp date;

  TermsConfirm({
    this.didAgree,
    this.date,
  });

  factory TermsConfirm.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) {
      return TermsConfirm(didAgree: false, date: null);
    }
    return TermsConfirm(
      didAgree: parsedJson['did_confirm'] ?? false,
      date: parsedJson['date'] ?? null,
    );
  }
}
