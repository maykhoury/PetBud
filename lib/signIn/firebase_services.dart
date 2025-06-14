import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/parent/MedicineCard.dart';
import 'package:petbud/parent/SugarCard.dart';
import 'package:petbud/parent/MedicineCard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:petbud/parent/doctorAppointments/appointmentCard.dart';
import 'package:petbud/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:petbud/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class FirebaseService extends ChangeNotifier {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  User? _user;
  String? _parentId; // BE CAREFUL YOU CAN ONLY USE IT IN CHILD LOGIN FUNCTION
  String? _childUsername;
  Status _status = Status.Uninitialized;
  String errorMessage = "";
  String petId = "";

  FirebaseService() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      _user = firebaseUser;
      if (firebaseUser == null) {
        _status = Status.Unauthenticated;
      } else {
        _status = Status.Authenticated;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  Status get status => _status;
  FirebaseFirestore get firestore => _firestore;

  // Future<DocumentSnapshot> getUserStartingMedicalData() async {
  //   final user = FirebaseAuth.instance.currentUser;

  //   if (await isConnected()) {
  //     if (user == null) {
  //       print("User not found!");
  //       throw Exception('User is null');
  //     }
  //     return await _firestore.collection('users').doc(user?.uid).get();
  //   } else {
  //     throw Exception('No internet connection');
  //   }
  // }

  Future<void> updateUserMedicalData({
    String? childName,
    DateTime? birthdate,
    String? gender,
    String? weight,
    String? height,
    String? weightMetric,
    String? heightMetric,
    String? diabetesType,
    String? physicianName,
    String? hospitalName,
    Set<String>? symptoms,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not found!");
      throw Exception('User is null');
    }
    return await _firestore.collection('users').doc(user?.uid).set({
      'childName': childName,
      'birthdate': birthdate,
      'gender': gender,
      'weight': {
        'value': weight,
        'metric': weightMetric,
      },
      'height': {
        'value': height,
        'metric': heightMetric,
      },
      'medicalDetails': {
        'diabetesType': diabetesType,
        'physicianName': physicianName,
        'hospitalName': hospitalName,
        'symptoms': symptoms,
      },
    }, SetOptions(merge: true));
  }

  Future<void> UpdateAccountDetails(
      {String? email,
      String? password,
      String? childEmail,
      String? childUsername,
      String? childPassword,
      String? oldChildEmail}) async {
    //update parent's email and password
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && email != null) {
      user.verifyBeforeUpdateEmail(email).then((_) {
        print("Email updated successfully");
      }).catchError((error) {
        print("Failed to update email: $error");
      });
    }

    if (user != null && password != null) {
      user.updatePassword(password).then((_) {
        print("Password updated successfully");
      }).catchError((error) {
        print("Failed to update password: $error");
      });
    }
  }

  Future<void> signUpParent(
      String parentEmail,
      String parentPassword,
      String childEmail,
      String childUsername,
      String childPassword,
      BuildContext context) async {
    errorMessage = "";
    UserCredential? parentCredential;
    UserCredential? childCredential;

    try {
      _status = Status.Authenticating;
      notifyListeners();

      // Sign up the parent
      parentCredential = await _auth.createUserWithEmailAndPassword(
        email: parentEmail,
        password: parentPassword,
      );

      _status = Status.Authenticated;
      _parentId = parentCredential.user!.uid;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isParent', true);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      if (e.code == 'weak-password') {
        errorMessage = 'The parent password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            'The account already exists for the parent email: $parentEmail.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred.';
      }
      notifyListeners();
      return; // Return early from the function
    } catch (e) {
      _status = Status.Unauthenticated;
      errorMessage = 'An unknown error occurred.';
      notifyListeners();
      return; // Return early from the function
    }

    try {
      // Check if the child's username is unique
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('childUsername', isEqualTo: childUsername)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        errorMessage = "This username is already taken.";

        // Delete the parent account if child username is taken
        if (parentCredential != null) {
          await parentCredential.user!.delete();
        }

        throw Exception('This username is already taken');
      }

      // Sign up the child
      childCredential = await _auth.createUserWithEmailAndPassword(
        email: childEmail,
        password: childPassword,
      );

      // Store the child's username and email in Firestore
      await _firestore
          .collection('users')
          .doc(parentCredential!.user!.uid)
          .set({
        'childEmail': childEmail,
        'childUsername': childUsername,
        'deletedAccount': false,
      });
      _childUsername = childUsername;

      _status = Status.Authenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _status = Status.Unauthenticated;
      if (e.code == 'weak-password') {
        errorMessage = 'The child password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage =
            'The account already exists for the child email: $childEmail.';
      } else {
        errorMessage = e.message ?? 'An unknown error occurred.';
      }

      // Delete the parent account if child sign up fails
      if (parentCredential != null) {
        await parentCredential.user!.delete();
      }

      notifyListeners();
      return; // Return early from the function
    } catch (e) {
      _status = Status.Unauthenticated;
      errorMessage = 'An unknown error occurred.';

      // Delete the parent account if child sign up fails
      if (parentCredential != null) {
        await parentCredential.user!.delete();
      }

      notifyListeners();
      return; // Return early from the function
    }

    try {
      // Sign out the child and sign back in the parent
      await _auth.signOut();
      await loginParent(parentEmail, parentPassword);
    } catch (e) {
      _status = Status.Unauthenticated;
      errorMessage =
          'Failed to sign in parent. Please check your email and password and try again.';

      // Navigate to login_parent screen and show a Snackbar
      Navigator.of(context).pushReplacementNamed('/login_parent');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Sign up was successful, but could not sign in to account. Please try to sign in manually.'),
        ),
      );

      notifyListeners();
    }
  }

  Future<void> loginParent(String email, String password) async {
    errorMessage = "";
    //check if the email is a parent email
    if (await isParent(email)) {
      try {
        _status = Status.Authenticating;
        notifyListeners();
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        _status = Status.Authenticated;
        _parentId = user!.uid;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isParent', true);
        notifyListeners();
      } catch (e) {
        _status = Status.Unauthenticated;
        errorMessage = "There was an error logging into the app.";
        notifyListeners();
        throw e; //rethrow the exception33333
      } finally {
        if (_status == Status.Authenticating) {
          _status = Status.Unauthenticated;
          errorMessage = "An unexpected error occurred.";
          notifyListeners();
        }
      }
    } else {
      errorMessage = "This email is not a parent email.";
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<void> loginChild(String username, String password) async {
    errorMessage = "";

    //check if the email is a child email
    if (await isChild(username)) {
      try {
        _status = Status.Authenticating;
        notifyListeners();

        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('childUsername', isEqualTo: username)
            .get();

        if (querySnapshot.docs.isEmpty) {
          _status = Status.Unauthenticated;
          errorMessage = "No such username.";
          notifyListeners();
        }

        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;

                  await _auth.signInWithEmailAndPassword(
            email: documentSnapshot['childEmail'],
            password: password,
          );

        bool? isDeleted = documentSnapshot.get('deletedAccount');
        if (isDeleted != null && isDeleted == true) {
          // Delete the child account from Firebase Authentication
          User? currentUser = _auth.currentUser;
          if (currentUser != null) {
            await currentUser.delete();
          }

          // Delete the child account from Firestore
          await documentSnapshot.reference.delete();

          // Throw an exception that the account has been successfully deleted
          throw('The account has been successfully deleted.');
        }
          _parentId = await findParentByChildEmail();
           final prefs = await SharedPreferences.getInstance();
                 await prefs.setBool('isParent', false);
        
      } catch (e) {
        if(e == 'The account has been successfully deleted.')
        {
          throw e;
        }
        _status = Status.Unauthenticated;
        errorMessage = "There was an error logging into the app.";
        notifyListeners();
        throw e; // Re-throw the exception
      } finally {
        if (_status == Status.Authenticating) {
          _status = Status.Unauthenticated;
          errorMessage = "An unexpected error occurred.";
          notifyListeners();
        }
      }
    } else {
      errorMessage = "This email is not a child email.";
      notifyListeners();
      throw Exception(errorMessage);
    }
  }

  Future<void> signOut() async {
    print("fuckkkkkkkkk");
    print("user: " + user!.uid);
    await _auth.signOut();
    _status = Status.Unauthenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isParent');
    notifyListeners();
  }

  Future<String?> findParentByChildEmail() async {
    try {
      if (_user == null) {
        return null;
      }
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('childEmail', isEqualTo: _user!.email)
          .get();
      return querySnapshot.docs.first.id;
    } catch (e) {
      print('Error finding parent by child email: $e');
    }
  }
  // Future<List<String>> getMedSchedByDay(FirebaseService instance, String weekday) async{
  //    List<String> all_med_times = [];
  //    String? parent_uid = await findParentByChildEmail(instance);
  //     QuerySnapshot medicationSnapshot = await instance.firestore
  //         .collection('users')
  //         .doc(parent_uid)
  //         .collection('medication_schedule')
  //         .get();

  //     for (var medicine in medicationSnapshot.docs) {
  //       Map<String, dynamic> schedule = medicine.get('schedule');
  //       List<String> times = List<String>.from(schedule[weekday]!);
  //       debugPrint(times.toString());
  //       if (times.isEmpty) continue;
  //       all_med_times.addAll(times);
  //     }
  //     return all_med_times;
  // }
  Stream<Map<String, dynamic>> progress_bar_info(
      FirebaseService instance, String weekday) {
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pet_details')
        .doc('Last_medicine')
        .snapshots()
        .asyncMap((snapshot) async {
      Map<String, dynamic> result = {};
      if (snapshot.exists) {
        Timestamp? timestamp =
            snapshot.data()?['last_medicine_time'] as Timestamp?;
        DateTime? lastMedicineTime = timestamp?.toDate();
        result['last_medicine_time'] = lastMedicineTime;
      } else {
        print('Document does not exist');
        result['last_medicine_time'] = null;
      }

      // Get medication schedule by day and add it to the result map
      List<String> medSchedByDay =
          await getMedSchedByDay(instance, weekday).first;
      result['med_sched_by_day'] = medSchedByDay;

      // Get medicine schedule difference and add it to the result map
      Map<String, dynamic> schedule_diff =
          await instance.medicineScheduleDiff(instance, medSchedByDay);
      result['schedule_diff'] = schedule_diff;
      //result.addAll(schedule_diff);

      debugPrint("result: " + result.toString());
      return result;
    });
  }

  Stream<DateTime?> med_info(FirebaseService instance, String weekday) {
 
    debugPrint("parent id" + _parentId.toString());
   // debugPrint("child id" + _user!.uid.toString());

    return _firestore
        .collection('users')
        .doc(_parentId)
        .collection('pet_details')
        .doc('Last_medicine')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Timestamp? timestamp =
            snapshot.data()?['last_medicine_time'] as Timestamp?;
        debugPrint("last medicine time:" + timestamp!.toDate().toString());
        return timestamp?.toDate();
      } else {
        print('Document does not exist');
        DateTime now = DateTime.now();
        DateTime yesterday = DateTime(now.year, now.month, now.day);
        return yesterday;
      }
    });
  }

  Stream<DateTime?> med_info_parent(FirebaseService instance, String weekday) {
 
    debugPrint("parent id" + _parentId.toString());
   // debugPrint("child id" + _user!.uid.toString());
  if(user == null)
  {
    return Stream<DateTime>.empty();
  }
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('pet_details')
        .doc('Last_medicine')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Timestamp? timestamp =
            snapshot.data()?['last_medicine_time'] as Timestamp?;
        debugPrint("last medicine time:" + timestamp!.toDate().toString());
        return timestamp?.toDate();
      } else {
        print('Document does not exist');
        DateTime now = DateTime.now();
        DateTime yesterday = DateTime(now.year, now.month, now.day);
        return yesterday;
      }
    });
  }

  Stream<List<String>> getMedSchedByDay(
      FirebaseService instance, String weekday) {
    return instance.firestore
        .collection('users')
        .doc(_parentId)
        .collection('medication_schedule')
        .snapshots()
        .map((snapshot) {
      List<String> all_med_times = [];
      for (var medicine in snapshot.docs) {
        Map<String, dynamic> schedule = medicine.get('schedule');
        List<String> times = List<String>.from(schedule[weekday]!);
        debugPrint(times.toString());
        if (times.isEmpty) continue;
        all_med_times.addAll(times);
      }
      return all_med_times;
    });
  }
  Stream<List<String>> getMedSchedByDayParent(
      FirebaseService instance, String weekday) {
            if(user == null)
    {
      return Stream<List<String>>.empty();
    }
       
    return instance.firestore
 .collection('users')
        .doc(user!.uid)
        .collection('medication_schedule')
        .snapshots()
        .map((snapshot) {
      List<String> all_med_times = [];
      for (var medicine in snapshot.docs) {
        Map<String, dynamic> schedule = medicine.get('schedule');
        List<String> times = List<String>.from(schedule[weekday]!);
        debugPrint(times.toString());
        if (times.isEmpty) continue;
        all_med_times.addAll(times);
      }
      return all_med_times;
    });
  }

  Map<String, dynamic> medicineScheduleDiff(
      FirebaseService instance, List<String> all_med_times) {
    DateTime now = DateTime.now();
    Duration? closestInterval = Duration(minutes: 0);
    DateTime closestTimeBefore = DateTime(now.year, now.month, now.day, 0, 0);
    DateTime closestTimeAfter =
        DateTime(now.year, now.month, now.day + 1, 0, 0);
    List<DateTime> timeObjects = [];
    DateTime lastMedOfTheDay = DateTime(now.year, now.month, now.day, 0, 0);

    try {
      if (all_med_times.isEmpty) {
        debugPrint("no times of day");
        return {
          'interval': 0,
          'closestTimeBefore': now,
          'closestTimeAfter': now,
          'timeObjects': null,
          'lastMedOfTheDay': null,
        };
      }
      if (all_med_times.length == 1) {
        DateTime ParsedTime = DateFormat('HH:mm a').parse(all_med_times[0]);
        DateTime time = DateTime(
            now.year, now.month, now.day, ParsedTime.hour, ParsedTime.minute);
        int interval = now.difference(time).abs().inMinutes;
        List<DateTime> timeObj = all_med_times.map((timeString) {
          return time;
        }).toList();
        return {
          'interval': interval,
          'closestTimeBefore': time,
          'closestTimeAfter': time,
          'timeObjects': timeObj,
          'lastMedOfTheDay': time,
        };
      }

      debugPrint("all times of day");
      debugPrint(all_med_times.toString());
      timeObjects = all_med_times.map((time) {
        DateTime parsedTime = DateFormat('hh:mm a').parse(time);
        return DateTime(
            now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
      }).toList();

      timeObjects.sort((a, b) => a.compareTo(b));
      debugPrint(timeObjects.toString());
      debugPrint("now");
      debugPrint(now.toString());
      closestTimeBefore = timeObjects.lastWhere((time) => time.isBefore(now),
          orElse: () => timeObjects.first);
      debugPrint("closest time before");
      debugPrint(closestTimeBefore.toString());
      closestTimeAfter = timeObjects.firstWhere((time) => time.isAfter(now),
          orElse: () => timeObjects.last);
      debugPrint("closest time after");
      debugPrint(closestTimeAfter.toString());
      closestInterval = closestTimeAfter.difference(closestTimeBefore);
      lastMedOfTheDay = timeObjects.last;
    } catch (e) {
      print('Error getting medication schedule: $e');
    }
    debugPrint("shu tl3 bla5r?");
    debugPrint(closestInterval!.inMinutes.toString());
    return {
      'interval': closestInterval.inMinutes,
      'closestTimeBefore': closestTimeBefore,
      'closestTimeAfter': closestTimeAfter,
      'timeObjects': timeObjects,
      'lastMedOfTheDay': lastMedOfTheDay,
    };
  }

  Future<bool> checkIfMedicineCanBeTaken(FirebaseService instance,
      String weekday, List<String> all_med_times) async {
    DateTime now = DateTime.now();

    // Get the last medicine time
    DateTime? lastMedicineTime = await med_info(instance, weekday).first;

    // Get the closest time after now
    Map<String, dynamic> scheduleDiff =
        medicineScheduleDiff(instance, all_med_times);
    DateTime closestTimeAfter = scheduleDiff['closestTimeAfter'];
    DateTime closestTimeBefore = scheduleDiff['closestTimeBefore'];
    DateTime? lastMedOfTheDay = scheduleDiff['lastMedOfTheDay'];

    // If lastMedicineTime is null, assume it's far in the past
    //ASK MAY !!!!!!!!!!!
    if (lastMedicineTime == null) {
      lastMedicineTime = DateTime(now.year, now.month, now.day);
    }

    if (lastMedOfTheDay == null) {
      return false;
    }
    if (scheduleDiff['timeObjects'].length == 1 &&
        now.isBefore(closestTimeBefore)) {
      return false;
    }

    if (now.isAfter(lastMedOfTheDay) &&
        lastMedicineTime.isAfter(lastMedOfTheDay)) {
      return false;
    }

    //missed the last scheduled medication
    if (lastMedicineTime.isBefore(closestTimeBefore)) {
      return true;
    }

    // Check if now is in between lastMedicineTime and closestTimeAfter
    if (now.isAfter(lastMedicineTime) && now.isBefore(closestTimeAfter)) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> addLastMedicineTime(
      DateTime time, FirebaseService instance) async {
    try {
      String? parent_uid = await findParentByChildEmail();
      await instance.firestore
          .collection('users')
          .doc(parent_uid)
          .collection('pet_details')
          .doc('Last_medicine')
          .set({
        'last_medicine_time': time,
      }, SetOptions(merge: true));
      // }
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
    }
  }

  Future<void> addStarCounter(FirebaseService instance, int value) async {
    try {
      await instance.firestore
          .collection('users')
          .doc(_parentId)
          .collection('pet_details')
          .doc('Stars')
          .set({
        'stars': FieldValue.increment(value),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error adding stars: $e'); // TODO: snackbar
    }
  }

  Future<int> getStars() async {
    try {
      DocumentSnapshot doc = await firestore
          .collection('users')
          .doc(_parentId)
          .collection('pet_details')
          .doc('Stars')
          .get();
      if (doc.exists) {
        return doc['stars'];
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting stars: $e');
      return 0;
    }
  }

  Future<void> addLastFoodTime(DateTime time, FirebaseService instance) async {
    try {
      String? parent_uid = await findParentByChildEmail();
      await instance.firestore
          .collection('users')
          .doc(parent_uid)
          .collection('pet_details')
          .doc('Last_food')
          .set({
        'last_food_time': time,
      }, SetOptions(merge: true));
      // }
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
    }
  }

Stream<DateTime?> getLastFoodTime(FirebaseService instance) {
  return instance.firestore
      .collection('users')
      .doc(_parentId)
      .collection('pet_details')
      .doc('Last_food')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          Timestamp timestamp = snapshot['last_food_time'];
          return timestamp.toDate();
        } else {
          return null;
        }
      })
      .handleError((e) {
        print('Error getting document: $e');
        return null;
      });
}

  Future<void> addLastShowerTime(
      DateTime time, FirebaseService instance) async {
    try {
      String? parent_uid = await findParentByChildEmail();
      await instance.firestore
          .collection('users')
          .doc(parent_uid)
          .collection('pet_details')
          .doc('Last_shower')
          .set({
        'last_shower_time': time,
      }, SetOptions(merge: true));
      // }
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
    }
  }

  Stream<DateTime?> getLastShowerTime(FirebaseService instance) {
  return instance.firestore
      .collection('users')
      .doc(_parentId)
      .collection('pet_details')
      .doc('Last_shower')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          Timestamp timestamp = snapshot['last_shower_time'];
          return timestamp.toDate();
        } else {
          return null;
        }
      })
      .handleError((e) {
        print('Error getting document: $e');
        return null;
      });
}

  Future<void> addLastSleepTime(DateTime time, FirebaseService instance) async {
    try {
      String? parent_uid = await findParentByChildEmail();
      await instance.firestore
          .collection('users')
          .doc(parent_uid)
          .collection('pet_details')
          .doc('Last_sleep')
          .set({
        'last_sleep_time': time,
      }, SetOptions(merge: true));
      // }
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
    }
  }

  Stream<DateTime?> getLastSleepTime(FirebaseService instance) {
  return instance.firestore
      .collection('users')
      .doc(_parentId)
      .collection('pet_details')
      .doc('Last_sleep')
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          Timestamp timestamp = snapshot['last_sleep_time'];
          return timestamp.toDate();
        } else {
          return null;
        }
      })
      .handleError((e) {
        print('Error getting document: $e');
        return null;
      });
}

  Future<void> addAppointmentToFirebase(
      String description,
      String doctor_name,
      String hospital_name,
      DateTime time,
      DateTime alert_time,
      FirebaseService instance,
      BuildContext context) async {
    // Create a new document and get a reference to it
    DocumentReference docRef = instance.firestore
        .collection('users')
        .doc(instance.user!.uid)
        .collection('doctor_appointments')
        .doc();

    try {
      await docRef.set({
        'description': description,
        'doctor_name': doctor_name,
        'hospital_name': hospital_name,
        'time': time.toIso8601String(), // Convert the DateTime to a string
        'alert_time':
            alert_time.toIso8601String(), // Convert the DateTime to a string
      });
      String formattedDate = DateFormat('yyyy-MM-dd').format(time);
      String formattedTime = DateFormat('HH:mm').format(time);

      // Schedule a notification
      await NotificationServices().scheduleNotification(
          docRef.id,
          'Doctor Appointment on: $formattedDate!',
          'Description: $description\nTime: $formattedTime',
          alert_time);

      print('after scheduling at ADD....');

      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding document: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> updateAppointmentInFirebase(
      String id,
      String description,
      String doctor_name,
      String hospital_name,
      DateTime time,
      DateTime alert_time,
      FirebaseService instance,
      BuildContext context) async {
    // Get a reference to the document
    DocumentReference docRef = instance.firestore
        .collection('users')
        .doc(instance.user!.uid)
        .collection('doctor_appointments')
        .doc(id);

    // Fetch the document
    DocumentSnapshot docSnapshot = await docRef.get();

    // Extract the alert_time
    DateTime alertTime = DateTime.parse(docSnapshot['alert_time']);

    // Generate the notification ID
    String notificationId = docRef.id + alertTime.toIso8601String();

    // Cancel the previously scheduled notification
    NotificationServices().cancelNotification(notificationId);

    try {
      // Update the document
      await docRef.update({
        'description': description,
        'doctor_name': doctor_name,
        'hospital_name': hospital_name,
        'time': time.toIso8601String(),
        'alert_time': alert_time.toIso8601String(),
      });

      String formattedDate = DateFormat('yyyy-MM-dd').format(time);
      String formattedTime = DateFormat('HH:mm').format(time);

      // Schedule a new notification
      await NotificationServices().scheduleNotification(
          docRef.id,
          'Doctor Appointment on: $formattedDate!',
          'Description: $description\nTime: $formattedTime',
          alert_time);

      print('after scheduling at UPDATE....');
      notifyListeners();
    } catch (e) {
      print('Error updating document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating document: $e'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> deleteAppointmentFromFirebase(
      String id, FirebaseService instance) async {
    // Get a reference to the document
    DocumentReference docRef = instance.firestore
        .collection('users')
        .doc(instance.user!.uid)
        .collection('doctor_appointments')
        .doc(id);

    try {
      // Delete the document
      await docRef.delete();

      // Cancel the scheduled notification
      NotificationServices().cancelNotification(id);

      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<List<AppointmentCard>> getAppointmentsFromFirebase(
      FirebaseService instance) async {
    // Get a reference to the doctor_appointments collection
    CollectionReference appointmentsRef = instance.firestore
        .collection('users')
        .doc(instance.user!.uid)
        .collection('doctor_appointments');

    // Get the documents in the collection
    print("before");
    QuerySnapshot querySnapshot = await appointmentsRef.get();
    print("in the middle");
    // Convert the documents to AppointmentCards and return them
    return querySnapshot.docs.map((doc) {
      return AppointmentCard(
        id: doc.id,
        description: doc['description'],
        doctor_name: doc['doctor_name'],
        hospital_name: doc['hospital_name'],
        time: DateTime.parse(doc['time']),
        alert_time: DateTime.parse(doc['alert_time']),
      );
    }).toList();
  }

  Future<void> addMedicineToFirebase(
      String medicineName,
      String dosage,
      List<Map<String, dynamic>> timeFields,
      FirebaseService instance,
      File image,BuildContext context) async {
    final storageRef = FirebaseStorage.instance.ref();

    // Create a new document and get a reference to it
    DocumentReference docRef = instance.firestore
        .collection('users')
        .doc(instance.user!.uid)
        .collection('medication_schedule')
        .doc();

    // Use the generated ID as part of the image path
    Reference imagesRef =
        storageRef.child(instance.user!.uid).child('images').child(docRef.id);

    String image_url = "";
    if (image.path.isNotEmpty) {
      print("try" + image.path);
    } else {
      print("image is null");
    }
    try{
 if (image.path.isNotEmpty) {
        final ref = _storage.ref(imagesRef.fullPath);
        await ref.putFile(image);
        image_url = await ref.getDownloadURL();
      }
      Map<String, List<String>> schedule = getMedicineTimes(timeFields);
      await docRef.set({
        'medicine_name': medicineName,
        'dosage': dosage,
        'schedule': schedule,
        'image_url': image_url, // Add the image URL to the document
      });
      notifyListeners();
    }
    catch(e)
    {
      print("error adding document");
    }
    try {
     
      Map<String, List<String>> medschedule = getMedicineTimes(timeFields);
      for (var entry in medschedule.entries) {
        String day = entry.key;
        Day dayEnum = Day.sunday; // Initialize to a default value
        if (day == 'Sunday') {
          dayEnum = Day.sunday;
        } else if (day == 'Monday') {
          dayEnum = Day.monday;
        } else if (day == 'Tuesday') {
          dayEnum = Day.tuesday;
        } else if (day == 'Wednesday') {
          dayEnum = Day.wednesday;
        } else if (day == 'Thursday') {
          dayEnum = Day.thursday;
        } else if (day == 'Friday') {
          dayEnum = Day.friday;
        } else if (day == 'Saturday') {
          dayEnum = Day.saturday;
        }

        for (String time in entry.value) {
          // String formattedTime = time.replaceAll(' ', '');
          // List<String> timeParts = formattedTime.split(':');
          // int hour = int.parse(timeParts[0]);
          // int minute = int.parse(timeParts[1].substring(0, 2));

          // trying another way for time:
          DateTime parsedTime = DateFormat("h:mm a").parse(time);

          // Get the hour and minute from the parsed time
          int hour = parsedTime.hour;
          int minute = parsedTime.minute;
          // thats all

          DateTime now = DateTime.now();
          DateTime alertTime =
              DateTime(now.year, now.month, now.day, hour, minute);

          // // If the alert time is in the past, add one week to it
          // if (alertTime.isBefore(now)) {
          //   alertTime = alertTime.add(Duration(days: 7));
          // }

          String notificationId = docRef.id + alertTime.toString(); //TO CHECK
          int notificationIdInt = notificationId.hashCode;

          // Schedule the recurring notification
          await NotificationServices().scheduleRecurringNotification(
              notificationIdInt, // Use the notificationId directly
              'Time to take $medicineName!', // Notification title
              'Dosage: $dosage\nTime: $time', // Notification content
              dayEnum, // Day of the week
              tz.TZDateTime.from(alertTime, tz.local) // Convert to TZDateTime
              );

          bool flag = await NotificationServices()
              .isNotificationScheduled(notificationIdInt);
          print("FLAG if notification was scheduled: " + flag.toString());
        }
      }
      print('after scheduling at ADD MEDICINE....');
      notifyListeners();
    } catch (e) {
      print('Error scheduling notification: $e');
       ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Permissions needed to schedule notifications!'),
    ),
  ); // TODO: snackbar
    }
  }

  Map<String, List<String>> getMedicineTimes(
      List<Map<String, dynamic>> timeFields) {
    Map<String, List<String>> schedule = {
      'Sunday': [],
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
    };
    for (var field in timeFields) {
      String day = field['day'];
      String time = field['time'];
      schedule[day]!.add(time);
    }
    return schedule;
  }

  Future<void> deleteMedicineFromFirebase(String medicineId) async {
    try {
      // Cancel all existing notifications for this medicine ---------------------
      // Fetch the existing document from Firebase
      DocumentSnapshot doc = await FirebaseService._firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('medication_schedule')
          .doc(medicineId)
          .get();

      // Extract the schedule from the document
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, List<String>> oldSchedule =
          (data['schedule'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value)),
      );
      for (var entry in oldSchedule.entries) {
        for (String time in entry.value) {
          DateTime parsedTime = DateFormat("h:mm a").parse(time);
          int hour = parsedTime.hour;
          int minute = parsedTime.minute;
          DateTime now = DateTime.now();
          DateTime alertTime =
              DateTime(now.year, now.month, now.day, hour, minute);

          String notificationId = medicineId + alertTime.toString();

          await NotificationServices().cancelNotification(notificationId);
        }
      }
      // ------------------------------------------------------------------------

      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('medication_schedule')
          .doc(medicineId)
          .delete();

      notifyListeners();
    } catch (e) {
      print('Error deleting medicine: $e');
    }
  }

  Future<void> AddSugarLevelToFirebase(
      DateTime date_time, double sugarLevel, FirebaseService instance) async {
    try {
      await instance.firestore
          .collection('users')
          .doc(instance.user!.uid.toString())
          .collection('sugar_levels')
          .doc()
          .set({
        'date_time': date_time,
        'sugar_level': sugarLevel,
      }, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      print('Error adding document: $e'); // TODO: snackbar
    }
  }

  Future<void> deleteSugarCardFromFirebase(
      String id, FirebaseService instance) async {
    try {
      await instance.firestore
          .collection('users')
          .doc(instance.user!.uid.toString())
          .collection('sugar_levels')
          .doc(id)
          .delete();
      notifyListeners();
    } catch (e) {
      print('Error deleting document: $e'); // TODO: snackbar
    }
  }

  Future<List<SugarCard>> getSugarLevels() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("no user");
      return [];
    }
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sugar_levels')
        .orderBy('date_time', descending: true)
        .get();

    List<SugarCard> sugarLevels = querySnapshot.docs.map((doc) {
      return SugarCard(
        id: doc.id,
        date_time: doc['date_time'].toDate(),
        sugarLevel: doc['sugar_level'],
      );
    }).toList();

    return sugarLevels;
  }

  Future<List<MedicineCard>> getMedicineSchedule() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medication_schedule')
        .get();

    try {
      List<MedicineCard> medicineSchedule = querySnapshot.docs.map((doc) {
        return MedicineCard(
          id: doc.id,
          medicine_name: doc['medicine_name'],
          dosage: doc['dosage'],
          times: Map.from(doc['schedule'])
              .map((key, value) => MapEntry(key, List<String>.from(value))),
          image: doc['image_url'],
        );
      }).toList();
      return medicineSchedule;
    } catch (e) {
      print('An error occurred: $e');
    }
    return Future.value([]);
  }

  Future<void> removeTimeFromMedicine(
      String medicineId, String day, String time) async {
    // Cancel the notification - TO CHECK
    String notificationId = medicineId + time;
    await NotificationServices().cancelNotification(notificationId);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medication_schedule')
        .doc(medicineId)
        .update({
      'schedule.$day': FieldValue.arrayRemove([time]),
    });
  }

  Future<void> deleteEmptyMedicine(String medicineId) async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('medication_schedule')
        .doc(medicineId);

    DocumentSnapshot docSnapshot = await docRef.get();
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    Map<String, List<String>> schedule = Map.from(data['schedule'])
        .map((key, value) => MapEntry(key, List<String>.from(value)));

    if (schedule.values.every((times) => times.isEmpty)) {
      return docRef.delete();
    }
  }

  List<FlSpot> convertSugarCardsToGraph(List<SugarCard> sugarCards) {
    // final oneMonthAgo = DateTime.now().subtract(Duration(days: 30));
    final now = DateTime.now();
    final recentSugarCards = sugarCards.where((sugarCard) {
      return sugarCard.date_time.month == now.month &&
          sugarCard.date_time.year == now.year;
    }).toList();

    final dateFormat = DateFormat('yyyy-MM-dd');

    final Map<String, SugarCard> grouped = {};

    for (var card in recentSugarCards) {
      final key = dateFormat.format(card.date_time);
      if (grouped[key] == null || card.sugarLevel > grouped[key]!.sugarLevel) {
        grouped[key] = card;
      }
    }

    final biggestValuePerDate = grouped.values.toList();

    if (biggestValuePerDate.isEmpty) {
      return [];
    }
    return biggestValuePerDate.map((sugarCard) {
      return FlSpot(
        sugarCard.date_time.day.toDouble(),
        sugarCard.sugarLevel,
      );
    }).toList();
  }

  void updateMedicineInFirebase(
      BuildContext context,
      String id,
      String medicineName,
      String dosage,
      List<Map<String, dynamic>> timeFields,
      String image_url) async {
    Map<String, List<String>> schedule = getMedicineTimes(timeFields);

    // Cancel all existing notifications for this medicine ---------------------
    // Fetch the existing document from Firebase
    DocumentSnapshot doc = await FirebaseService._firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('medication_schedule')
        .doc(id)
        .get();

    // Extract the schedule from the document
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, List<String>> oldSchedule =
        (data['schedule'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
    for (var entry in oldSchedule.entries) {
      for (String time in entry.value) {
        DateTime parsedTime = DateFormat("h:mm a").parse(time);
        int hour = parsedTime.hour;
        int minute = parsedTime.minute;
        DateTime now = DateTime.now();
        DateTime alertTime =
            DateTime(now.year, now.month, now.day, hour, minute);

        String notificationId = id + alertTime.toString();

        await NotificationServices().cancelNotification(notificationId);
      }
    }
    // ------------------------------------------------------------------------

    try {
      await FirebaseService._firestore
        ..collection('users')
            .doc(_user!.uid)
            .collection('medication_schedule')
            .doc(id)
            .update({
          'medicine_name': medicineName,
          'dosage': dosage,
          'schedule': schedule,
          'image_url': image_url
          // Add other fields you want to update here
        });
      notifyListeners();
    } catch (e) {
      print('Error Updating document: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error Updating document: $e')));
    }

    //re-schedule notifications -------------------------------------------------
    for (var entry in schedule.entries) {
      String day = entry.key;
      Day dayEnum = Day.sunday; // Initialize to a default value
      if (day == 'Sunday') {
        dayEnum = Day.sunday;
      } else if (day == 'Monday') {
        dayEnum = Day.monday;
      } else if (day == 'Tuesday') {
        dayEnum = Day.tuesday;
      } else if (day == 'Wednesday') {
        dayEnum = Day.wednesday;
      } else if (day == 'Thursday') {
        dayEnum = Day.thursday;
      } else if (day == 'Friday') {
        dayEnum = Day.friday;
      } else if (day == 'Saturday') {
        dayEnum = Day.saturday;
      }

      for (String time in entry.value) {
        DateTime parsedTime = DateFormat("h:mm a").parse(time);
        int hour = parsedTime.hour;
        int minute = parsedTime.minute;
        DateTime now = DateTime.now();
        DateTime alertTime =
            DateTime(now.year, now.month, now.day, hour, minute);

        String notificationId = id + alertTime.toString();
        int notificationIdInt = notificationId.hashCode;

        await NotificationServices().scheduleRecurringNotification(
            notificationIdInt,
            'Time to take $medicineName!',
            'Dosage: $dosage\nTime: $time',
            dayEnum,
            tz.TZDateTime.from(alertTime, tz.local));
      }
    }
  }

  Future<bool> isParent(String email) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('childEmail', isEqualTo: email)
        .get();

    return result.docs.isEmpty;
  }

  Future<bool> isChild(String username) async {
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('childUsername', isEqualTo: username)
        .get();

    return !(result.docs.isEmpty);
  }

//Delete account - account settings
  Future<void> deleteUserAndMarkChildAsDeleted(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 1. Find the current user
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      // 2. Find the user's child email and child username from the user's database
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(currentUser.uid).get();
      String? childEmail = userDoc.get('childEmail');
      String? childUsername = userDoc.get('childUsername');

      if (childEmail != null && childUsername != null) {
        // 3. Create a new document for the childEmail account and add the deleted and username fields
        await firestore.collection('users').add({
          'childEmail': childEmail,
          'deletedAccount': true,
          'childUsername': childUsername,
        });
      }

      // Delete the user's document from the database
      await firestore.collection('users').doc(currentUser.uid).delete();

      // Show a message after marking the child account as deleted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'You have to log in from your child\'s account to delete it')),
      );

      // Delete the current user
      NotificationServices().cancelAllNotifications();
      await currentUser.delete();
    } else {
      print('No user is currently logged in.');
    }
  }
}
