import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:petbud/parent/MedicinePage.dart';
import 'package:petbud/parent/ProgressBarNotifier.dart';
import 'settings/medical_info.dart';
import 'signIn/login_parent.dart';
import 'signIn/login_child.dart';
import 'signIn/signup.dart';
import 'settings/settings.dart';
import 'signIn/home_screen.dart';
import 'package:provider/provider.dart';
import 'signIn/firebase_services.dart';
import 'parent/HomePage.dart';
import 'parent/SugarLevels.dart';
import 'child/bedroom.dart';
import 'parent/MedicineAlertDialog.dart';
import 'parent/doctorAppointments/appointmentsSchedule.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer';
import 'notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationServices notificationServices = NotificationServices();
  await notificationServices.initNotifications();
  tz.initializeTimeZones();
  await Firebase.initializeApp();

  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;
   final prefs = await SharedPreferences.getInstance();
  bool isParent = false;
  // Check if the user is a parent
  if (user != null && user.email != null) {
    isParent = prefs.getBool('isParent')==null?false:prefs.getBool('isParent')!;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FirebaseService()),
        
        ChangeNotifierProvider.value(value: notificationServices),
      ],
      child: MyApp(user: user, isParent: isParent), // Pass the user and isParent to MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final User? user;
  final bool isParent;
  MyApp({this.user, required this.isParent});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        debugPrint('PopScope: didPop: $didPop');
        return;
      },
      child: MaterialApp(
        navigatorKey: navigatorKey1,
        routes: {
          //'/': (context) => MedicineAlertDialog(),
          '/': (context) => HomeScreen(), // Home screen at the root route
          '/login_parent': (context) => LoginParentScreen(),
          '/login_child': (context) => LoginChildScreen(),
          '/signup': (context) => SignupScreen(),
          '/medical_info': (context) => MedicalInfoPage(),
          '/settings': (context) => SettingsPage(),
          '/bedroom_screen': (context) => BedroomScreen(),
          '/sugar_levels_screen': (context) => SugarLevelsScreen(),
          '/parent_home_page': (context) => ParentHomePage(),
          '/medicine_list_page': (context) => MedicinePageScreen(),
          '/appointments_schedule': (context) => AppointmentsSchedule(),
          '/noInternet': (context) => NoInternetScreen(),
        },
      // Start with the home screen if a user is logged in, otherwise start with the login screen
      initialRoute: user != null ? (isParent ? '/parent_home_page' : '/login_child') : '/',
      ),
    );
  }
}
