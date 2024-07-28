import 'PelotonUser.dart';

class PelotonProfissional {
  final EmploymentDetails employmentDetails;
  final PersonalInformation personalInformation;
  String id;
  ChatParams chatParams;

  PelotonProfissional({
    this.employmentDetails,
    this.personalInformation,
    this.id,
    this.chatParams,
  });

  factory PelotonProfissional.fromJson(Map<String, dynamic> parsedJson) {
    return PelotonProfissional(
        employmentDetails: EmploymentDetails.fromJson(
            parsedJson['employment_details'] ?? Map<String, dynamic>()),
        personalInformation:
            PersonalInformation.fromJson(parsedJson['personal_information']),
        chatParams: ChatParams.fromJson(parsedJson['chat_params']));
  }
}

class EmploymentDetails {
   
  final String professionTitle;
  final List<dynamic> roles;
  EmploymentDetails({this.professionTitle, this.roles});
  factory EmploymentDetails.fromJson(Map<String, dynamic> parsedJson) {
    List<String> defaultList = ['Other_Profesional'];
    return EmploymentDetails(
      professionTitle: parsedJson['profession_title'],
      roles: parsedJson['role_id'] ?? defaultList,
    );
  }
}

class PersonalInformation {
  final String email;
  final String gender;
  final String name;
  final String phone;
  final String profileImage;
  PersonalInformation({
    this.email,
    this.gender,
    this.name,
    this.phone,
    this.profileImage,
  });
  factory PersonalInformation.fromJson(Map<String, dynamic> parsedJson) {
    return PersonalInformation(
      email: parsedJson['email'],
      gender: parsedJson['gender'],
      name: parsedJson['name'],
      phone: parsedJson['phone'],
      profileImage: parsedJson['profile_image'],
    );
  }
}
