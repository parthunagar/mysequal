import 'package:cloud_firestore/cloud_firestore.dart';

class PatientProgram {
  String id;
  String caseManager;
  String meetingLocation;
  String patientid;
  String programStatus;
  ProgramOrginization orginization;

  PatientProgram(
      {this.id,
      this.caseManager,
      this.meetingLocation,
      this.patientid,
      this.programStatus,
      this.orginization});

  factory PatientProgram.fromJson(Map<String, dynamic> parsedJson) {
    return PatientProgram(
        id: parsedJson['id'],
        caseManager: parsedJson['case_manager'],
        meetingLocation: parsedJson['meeting_location'],
        patientid: parsedJson['patientid'],
        programStatus: parsedJson['program_status'],
        orginization: ProgramOrginization.fromJson(parsedJson['orginization']));
  }
  void changeStatus(status) {
    FirebaseFirestore.instance
        .collection('patient_program')
        .doc('${this.id}')
        .update(
      {'orginization.status': status},
    );
  }
}

class ProgramOrginization {
  String id;
  String status;
  String name;

  ProgramOrginization({
    this.id,
    this.status,
    this.name,
  });

  factory ProgramOrginization.fromJson(Map<String, dynamic> parsedJson) {
    return ProgramOrginization(
      id: parsedJson['id'],
      status: parsedJson['status'],
      name: parsedJson['name'],
    );
  }
}
