import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:peloton/models/PelotonUser.dart';
import 'package:peloton/models/patient_program.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {
  Stream<String> get onAuthStateChanged;
  Map<String, dynamic> get currentUserDoc;
  String currentUser();
  Future<void> signOut();
  String get currentUserId;
  set currentUserId(String currentUserId);
  Future<int> getUserDocument(String userId);
  void updateUserDoc(String key, dynamic value);
  void updatePrograms();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Map<String, dynamic> _userDoc = {};
  StreamController<String> stateController;
  String _currentUserId;

  Auth() {
    print('*************************');
    print('Auth Was initialized');
    stateController = new StreamController.broadcast();
  }

  String get currentUserId {
    return this._currentUserId;
  }

  Map<String, dynamic> get currentUserDoc {
    return this._userDoc;
  }

  @override
  updatePrograms() {
    getPrograms();
  }

  getPrograms() async {
    List<PatientProgram> tempList = [];
    try {
      var patientPrograms = await FirebaseFirestore.instance
          .collection('patient_program')
          .where('patientid', isEqualTo: _userDoc['id'])
          .get();
      for (var item in patientPrograms.docs) {
        PatientProgram newProgram = PatientProgram.fromJson(item.data());

        tempList.add(newProgram);
      }
    } catch (err) {
      print(err);
      return;
    }
    List<String> ids = [];
    List<Map> caseManagers = [];
    ///////////// get the case managers for the active orgs (used for empty chat history or new note )

    for (var org in tempList) {
      if (org.orginization.status == 'Active') {
        ids.add(org.orginization.id);
        var casemanager =
            FirebaseFirestore.instance.doc('users/${org.caseManager}');
        caseManagers
            .add({'casemaneger': casemanager, 'org': org.orginization.id});
      }
    }
    _userDoc['patient_program'] = tempList;
    _userDoc['organizationsID'] = ids;
    _userDoc['caseManager'] = caseManagers;
  }

  set currentUserId(String currentUserId) {
    this._currentUserId = currentUserId;
  }

  Stream<String> userState() {
    _firebaseAuth.authStateChanges().listen((user) async {
      print("State changed");
      print(stateController.hasListener);
      //print(user.uid);

      if (user != null) {
        int isRegistered = await this.getUserDocument(user.uid);
        this._currentUserId = user.uid;
        if (isRegistered == 2) {
          stateController.add('REGISTERED');
        } else if (isRegistered == 1) {
          stateController.add('LOGGEDIN');
        } else if (isRegistered == 3) {
          stateController.add('NOTCONFIRMED');
        } else {
          stateController.add('NOTLOGGEDIN');
        }
      } else {
        stateController.add('NOTLOGGEDIN');
      }
    });
    return stateController.stream;
  }

  @override
  Stream<String> get onAuthStateChanged {
    return this.userState().map((String state) => state);
  }

  @override
  void updateUserDoc(String key, dynamic newvalue) async {
     print('************     $key :: $newvalue       ************');
    FirebaseFirestore.instance
        .doc('patients/${this.currentUserId}')
        .update({key: newvalue});
    this._userDoc[key] = newvalue;
  }

  @override
  String currentUser() {
    final User user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<int> getUserDocument(String userId) async {
    var ref = await SharedPreferences.getInstance();
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        this._userDoc = userDoc.data();
        this._userDoc['id'] = userDoc.id;
       

        getPrograms();
        var user = PelotonUser.fromJson(_userDoc);
        if (user.userTerms != null) {
          if (!user.userTerms.didAgree) {
            // we have user doc but did not agree to the terms
            return 3;
          }
        } else {
          return 3;
        }

        if (user.hasNewGoal != null) {
          ref.setBool('hasNewGoal', user.hasNewGoal);
        } else {
          ref.setBool('hasNewGoal', false);
        }

        return 2;
      } else {
        return 1;
      }
    } catch (err) {
      print(err);
      return 0;
    }
  }
}
