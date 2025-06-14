import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
import 'HeartsLevelNotifier.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../child/AnimationNotifier.dart';

class CloudBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/images/CloudBase.png',
      height: MediaQuery.of(context).size.height *
          0.5, // Adjust this value to fit your needs
      fit: BoxFit.fill,
    );
  }
}

class CarrotArrows extends StatelessWidget {
  final Widget? nextPage;
  final Widget? previousPage;
  CarrotArrows({required this.nextPage, required this.previousPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Image.asset(
            'lib/images/lightLeftCarrot.png',
            width:
                MediaQuery.of(context).size.width * 0.2, // 20% of screen width
            
          ),
          onPressed: () {
            if (previousPage != null) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => previousPage!));
            }
          },
        ),
        SizedBox(width: 70),
        IconButton(
          icon: Image.asset('lib/images/lightRightCarrot.png',
              width:
                MediaQuery.of(context).size.width * 0.2,),
          onPressed: () {
            if (nextPage != null) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => nextPage!));
            }
          },
        )
      ],
    );
  }
}
// ----------------------- Medicine Button -----------------------

class MedicineButton extends StatefulWidget {
  List<String> all_med_times = [];
  DateTime? last_medicine_time;
  MedicineButton(
      {required this.all_med_times, required this.last_medicine_time});

  @override
  _MedicineButtonState createState() => _MedicineButtonState();
}

class _MedicineButtonState extends State<MedicineButton> {
  Timer? _timer;
  Timer? _timer2;

  @override
  void dispose() {
    _timer?.cancel();
    _timer2?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HeartsLevelNotifier heartsLevel = Provider.of<HeartsLevelNotifier>(context);
    FirebaseService instance = Provider.of<FirebaseService>(context);
    AnimationNotifier animationNotifier =
        Provider.of<AnimationNotifier>(context, listen: false);
    List<String> all_med_times = widget.all_med_times;
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: GestureDetector(
        onTap: () async {
          bool canTakeMedicine = await instance.checkIfMedicineCanBeTaken(
              instance, getWeekday(), all_med_times);
          if (canTakeMedicine) {
            heartsLevel.fillHearts();
            instance.addLastMedicineTime(DateTime.now(), instance);

            // Update the animation to happy rabbit
            animationNotifier.updateAnimation('lib/images/Rabbit-Happy.gif');

            // After 8 seconds, change the animation back to alive rabbit
            Future.delayed(Duration(seconds: 8), () {
              animationNotifier.updateAnimation('lib/images/Rabbit-Alive.gif');
              animationNotifier
                  .updateLastAnimation('lib/images/Rabbit-Alive.gif');
            });

            heartsLevel.restartTimer(
                instance, widget.all_med_times, DateTime.now());
            debugPrint("hearts refilled");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Can't give medicine now! Try again later!"),
                duration: Duration(seconds: 3),
              ),
            );
            debugPrint("Can't press the button");
          }
        },
        child: Container(
          child: Image.asset(
            'lib/images/orangeMedicine.png',
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.15,
          ),
        ),
      ),
    );
  }
}

//-----------------------Hearts-----------------------
class heartsLevel extends StatefulWidget {
  const heartsLevel({super.key});

  @override
  State<heartsLevel> createState() => _heartsLevelState();
}

class _heartsLevelState extends State<heartsLevel> {
  @override
  Widget build(BuildContext context) {
    HeartsLevelNotifier heartsLevel = Provider.of<HeartsLevelNotifier>(context);
    FirebaseService instance = Provider.of<FirebaseService>(context);
    return Column(
      children: [
        Row(
          children: heartsLevel.hearts
              .expand((heart) => [
                    SizedBox(width: 2),
                    Container(
                      width: 35,
                      height: 35,
                      child: Image.asset(
                        heart,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 2),
                  ])
              .toList(),
        ),
      ],
    );
  }
}
