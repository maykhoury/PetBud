import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class StarsNotifier extends ChangeNotifier {
  int _currentStars = 0;
  final FirebaseService _firebaseService;

   Future<void> _initStars() async {
    final stars = await _firebaseService.getStars();
    _currentStars = stars;
    notifyListeners();
  }

  StarsNotifier(this._firebaseService) {
    _initStars();
  }

  int get currentStars => _currentStars;

  void updateStars(int newStars) {
    _currentStars += newStars;
    notifyListeners();
  }

  void incrementStars() {
    _currentStars++;
    notifyListeners();
  }
  

  int getStarsNumber(DateTime? last) {
    final now = DateTime.now();
    if (last == null) {
      return 3;
    }
    final difference = now.difference(last);
    if (difference.inMinutes <= 30) {
      return 1;
    } else if (difference.inMinutes < 60) {
      return 2;
    } else {
      return 3;
    }
  }


}
