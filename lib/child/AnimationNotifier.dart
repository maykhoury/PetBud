import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import '../child/HeartsLevelNotifier.dart';
import 'package:provider/provider.dart';
import 'package:petbud/signIn/firebase_services.dart';

class AnimationNotifier extends ChangeNotifier {
  String _currentAnimation = 'lib/images/Rabbit-Alive.gif';
  String _lastAnimation = 'lib/images/Rabbit-Alive.gif';
  late final HeartsLevelNotifier _heartsLevelNotifier;

  AnimationNotifier(BuildContext context) {
    _heartsLevelNotifier = Provider.of<HeartsLevelNotifier>(context, listen: false);
    _heartsLevelNotifier.addListener(updateAnimationAccordingToHeartLevel);
    updateAnimationAccordingToHeartLevel();
  }

  @override
  void dispose() {
    _heartsLevelNotifier.removeListener(updateAnimationAccordingToHeartLevel);
    super.dispose();
  }

  String get currentAnimation => _currentAnimation;

  void updateAnimationAccordingToHeartLevel() {
    debugPrint('updateAnimationAccordingToHeartLevel');
    final heartLevel = _heartsLevelNotifier.getCurrentHeartLevel();
    if (heartLevel <= 1) {
      _currentAnimation = 'lib/images/Rabbit-Sad.gif';
      _lastAnimation='lib/images/Rabbit-Sad.gif';
    } 
    else if(_currentAnimation == 'lib/images/Rabbit-Happy.gif')
    {
      return;
    }
    else {
      _currentAnimation = 'lib/images/Rabbit-Alive.gif';
    }
    notifyListeners();
  }

  void updateAnimation(String newAnimation) {
    _currentAnimation = newAnimation;
    notifyListeners();
  }
  void updateLastAnimation(String newAnimation) {
    _lastAnimation = newAnimation;
    notifyListeners();
  }
  void updateAnimationOnSleepTap(Function showDialogCallback, FirebaseService instance, DateTime time) {
    _currentAnimation = 'lib/images/RabbitSleep.gif';
    notifyListeners();
    Future.delayed(Duration(seconds: 8), () {
      
      _currentAnimation = _lastAnimation;
      
      notifyListeners();
      showDialogCallback();
      // instance.addLastSleepTime(time, instance);
    });
  }
  void updateAnimationOnShowerTap(Function showDialogCallback,FirebaseService instance, DateTime time)
  {
     _currentAnimation = 'lib/images/RabitShower.gif';
    notifyListeners();
    Future.delayed(Duration(seconds: 8), () {
      _currentAnimation = _lastAnimation;
      notifyListeners();

      showDialogCallback();
      instance.addLastShowerTime(time, instance);
    });
  }
  void updateAnimationOnFoodTap(Function showDialogCallback, FirebaseService instance, DateTime time)
  {
     _currentAnimation = 'lib/images/RabbitEat.gif';
    notifyListeners();
    Future.delayed(Duration(seconds: 8), () {
      
      _currentAnimation = _lastAnimation;
      
      notifyListeners();
      showDialogCallback();
      instance.addLastFoodTime(time, instance);
    });
  }
}