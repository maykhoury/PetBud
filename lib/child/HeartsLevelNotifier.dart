import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:intl/intl.dart';

class HeartsLevelNotifier with ChangeNotifier {
  List<String> hearts = List.filled(5, 'lib/images/fullHeart.png');
  bool _active = true;
  Timer? _timer;
  StreamController<List<String>> _heartsStreamController =
      StreamController<List<String>>();

  int getCurrentHeartLevel() {
    return hearts.lastIndexOf('lib/images/fullHeart.png');
  }

  void fillHearts() {
    if (!_active) return;
    hearts = List.filled(5, 'lib/images/fullHeart.png');
    notifyListeners();
  }

  bool isNotToday(DateTime? last_medicine_time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMedicineDate = DateTime(last_medicine_time!.year,
        last_medicine_time!.month, last_medicine_time.day);

    return lastMedicineDate != today;
  }

  void redundantFunction(
      DateTime closestTimeAfter, DateTime now, DateTime last_medicine_time) {
    int duration =
        closestTimeAfter.difference(last_medicine_time).abs().inSeconds;
    int last_now = closestTimeAfter.difference(now).abs().inSeconds;
    if (duration == 0) return;
    int hearts_remaining = ((last_now / duration) * 5).ceil();
    debugPrint("hearts remaining " + hearts_remaining.toString());

    for (int i = 0; i < hearts.length; i++) {
      hearts[i] = i < hearts_remaining
          ? 'lib/images/fullHeart.png'
          : 'lib/images/emptyHeart.png';
    }
  }

  void initiateHearts(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    DateTime? last_medicine_temp = last_medicine_time;
    DateTime now = DateTime.now();
    debugPrint("last_medicine_time:" + last_medicine_time.toString());
    String week_day = DateFormat('EEEE').format(now);
    try {
      Map<String, dynamic> scheduleDiff =
          (instance.medicineScheduleDiff(instance, all_med_times));

      DateTime closestTimeBefore = scheduleDiff['closestTimeBefore'];
      DateTime closestTimeAfter = scheduleDiff['closestTimeAfter'];
      debugPrint("ClosestTimeBefore:" + closestTimeBefore.toString());
      debugPrint("last medicine:" + last_medicine_time.toString());

      if (isNotToday(last_medicine_time)) {
        last_medicine_temp = now;
      }
      if (all_med_times.isEmpty) {
        hearts = List.filled(5, 'lib/images/fullHeart.png');
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
      if (all_med_times.length == 1) {
        //if its the first time today
        if (last_medicine_time == DateTime(now.year, now.month, now.day, 0, 0)) 
        {
          // if its the first medicine today but the time for his medicine has passed
          if (now.isAfter(closestTimeBefore)) 
          {
            hearts = List.filled(5, 'lib/images/emptyHeart.png');
             WidgetsBinding.instance!.addPostFrameCallback((_) {
          notifyListeners();
        });
            return;
          }
          hearts = List.filled(5, 'lib/images/fullHeart.png');
          _startTimer(instance, all_med_times, now);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            notifyListeners();
          });
          return;
        } else {
          redundantFunction(closestTimeAfter, now, last_medicine_time!);
          _startTimer(instance, all_med_times, last_medicine_time);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      } else if (last_medicine_time!.isBefore(closestTimeBefore) &&
          !all_med_times.isEmpty) {
        debugPrint(
            "KSEM LKOL - last medicine time is before closestTimeBefore");
        hearts = List.filled(5, 'lib/images/emptyHeart.png');
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
      redundantFunction(closestTimeAfter, now, last_medicine_temp!);

      _startTimer(instance, all_med_times, last_medicine_temp);
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Error getting closestTimeBefore: $e');
    }
  }

  void _startTimer(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    String week_day = DateFormat('EEEE').format(DateTime.now());
    Map<String, dynamic> scheduleDiff =
        (instance.medicineScheduleDiff(instance, all_med_times));
    DateTime closestTimeAfter = scheduleDiff['closestTimeAfter'];
    DateTime? lastMedOfTheDay = scheduleDiff['lastMedOfTheDay'];
    debugPrint(lastMedOfTheDay.toString() + "lastMedOfTheDay");
    debugPrint(last_medicine_time.toString() + "last_medicine_time");
    int duration =
        closestTimeAfter.difference(last_medicine_time!).abs().inSeconds;
    debugPrint(duration.toString() + 'duration');
    if (duration == 0) {
      _timer?.cancel();
      return;
    }
    int heart_duration = (duration /5).toInt();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: heart_duration), (Timer t) {
      if (!_active) return;
      debugPrint('Heart removed');
      int index = hearts.lastIndexOf('lib/images/fullHeart.png');
      if (index != -1) {
        if (lastMedOfTheDay != null &&
            last_medicine_time!.isAfter(lastMedOfTheDay)) {
          debugPrint('m2ayra');
          _timer?.cancel();
        } else {
          hearts[index] = 'lib/images/emptyHeart.png';
        }
        notifyListeners();
      }
    });

    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   notifyListeners();
    // });
    // notifyListeners();
  }

  void restartTimer(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    _startTimer(instance, all_med_times, last_medicine_time);
  }

  void init(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    initiateHearts(instance, all_med_times, last_medicine_time);
  }

  HeartsLevelNotifier(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    init(instance, all_med_times, last_medicine_time);
  }

  void dispose() {
    _active = false;
    _timer?.cancel();
    super.dispose();
  }
}
