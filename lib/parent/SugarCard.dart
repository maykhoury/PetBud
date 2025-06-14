import 'dart:ffi';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
class SugarCard {
   String id;
   DateTime date_time;
   double sugarLevel;

  SugarCard(
      {required this.id, required this.date_time, required this.sugarLevel});
  
    // Constructor with default values
  }// named constructor

