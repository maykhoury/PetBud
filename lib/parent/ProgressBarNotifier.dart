import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProgressBarNotifier with ChangeNotifier {
  int value = 5;
  Timer? _timer;
   bool _active = true;
  StreamController<int> _progressBarValue = StreamController<int>();

  void fillBar() {
    if (!_active) return;
    value = 5;
    notifyListeners();
  }

  bool isNotToday(DateTime? last_medicine_time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastMedicineDate = DateTime(last_medicine_time!.year,
        last_medicine_time!.month, last_medicine_time.day);

    return lastMedicineDate != today;
  }

  void progressRedundant(
      DateTime closestTimeAfter, DateTime now, DateTime last_medicine_time) {
    int duration =
        closestTimeAfter.difference(last_medicine_time).abs().inMinutes;
    int last_now = closestTimeAfter.difference(now).abs().inMinutes;
    if (duration == 0) return;
    int value_remaining = ((last_now / duration) * 5).ceil();
    debugPrint("value remaining " + value_remaining.toString());
    value = value_remaining>5?5:value_remaining;
  }
   void initiateProgressBar(FirebaseService instance, List<String> all_med_times,
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
        value=5;
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
      if (all_med_times.length == 1) {
        if (last_medicine_time ==
            DateTime(now.year, now.month, now.day, 0, 0)) {
          value = 5;
          _startTimer(instance, all_med_times, now);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            notifyListeners();
          });
          return;
        } else {
          progressRedundant(closestTimeAfter, now, last_medicine_temp!);
          _startTimer(instance, all_med_times, last_medicine_temp);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      } else if (last_medicine_time!.isBefore(closestTimeBefore) &&
          !all_med_times.isEmpty) {
        debugPrint(
            "KSEM LKOL - last medicine time is before closestTimeBefore");
        value = 0;
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          notifyListeners();
        });
        return;
      }
      progressRedundant(closestTimeAfter, now, last_medicine_temp!);

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
        closestTimeAfter.difference(last_medicine_time!).abs().inMinutes;
    debugPrint(duration.toString() + 'duration');
    if (duration == 0) {
      _timer?.cancel();
      return;
    }
    int value_duration = duration * 12;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: value_duration), (Timer t) {
      if (!_active) return;
      debugPrint('Heart removed');
     
      if (value != 0) {
        if (lastMedOfTheDay != null &&
            last_medicine_time!.isAfter(lastMedOfTheDay)) {
          debugPrint('m2ayra');
          _timer?.cancel();
        } else {
          value--;
        }
        notifyListeners();
      }
    });


}
 void restartTimer(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    _startTimer(instance, all_med_times, last_medicine_time);
  }

  void init(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    initiateProgressBar(instance, all_med_times, last_medicine_time);
  }

  ProgressBarNotifier(FirebaseService instance, List<String> all_med_times,
      DateTime? last_medicine_time) {
    init(instance, all_med_times, last_medicine_time);
  }
  void dispose() {
    _active = false;
    _timer?.cancel();
    super.dispose();
  }

}

