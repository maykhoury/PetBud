import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:petbud/child/Bathroom.dart';
import 'package:petbud/child/Kitchen.dart';
import 'package:petbud/child/bedroom.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:gif/gif.dart';
import '../child/HeartsLevelNotifier.dart';
import '../child/AnimationNotifier.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import "package:petbud/child/RoomElements.dart";
import 'package:petbud/child/StarsNotifier.dart';

class Kitchenscreen extends StatefulWidget {
  @override
  _KitchenscreenState createState() => _KitchenscreenState();
}

class GlucDialog extends StatefulWidget {
  // const GlucDialog({super.key});
  final BuildContext parentContext;

  GlucDialog({required this.parentContext});

  @override
  State<GlucDialog> createState() => _GlucDialogState();
}

class _GlucDialogState extends State<GlucDialog> {
  String _currentImage = 'lib/images/TongueGluc.png';
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    HeartsLevelNotifier heartsLevel =
        Provider.of<HeartsLevelNotifier>(widget.parentContext, listen: false);
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: GestureDetector(
          onLongPressStart: (details) {
            _timer = Timer(Duration(seconds: 5), () {});
          },
          onLongPressEnd: (details) {
            int currentHeart = heartsLevel.getCurrentHeartLevel() + 1;
            debugPrint(currentHeart.toString());
            if (currentHeart <= 1) {
              //sad glucometer
              _currentImage = 'lib/images/CryingGluc.png';
            } else if (currentHeart <= 3) {
              //half sad glucometer
              _currentImage = 'lib/images/HalfSadGluc.png';
            } else if (currentHeart <= 5) {
              //happy glucometer
              _currentImage = 'lib/images/HappyGluc.png';
            }
            if (_timer != null) {
              _timer?.cancel();
            }
            setState(() {});
          },
          child: Image.asset(
            _currentImage,
            height: 400,
            width: 500,
          ),
        ),
      ),
    );
  }
}

class MainButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnimationNotifier animationNotifier =
        Provider.of<AnimationNotifier>(context, listen: false);
    FirebaseService instance =
        Provider.of<FirebaseService>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Builder(
          builder: (context) => GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return GlucDialog(parentContext: context);
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                'lib/images/greenCheck.png',
                height: MediaQuery.of(context).size.height *
                    0.20, // Adjust this value to fit your needs
                width: MediaQuery.of(context).size.width * 0.20,
              ),
            ),
          ),
        ),
         StreamBuilder<DateTime?>(
            stream: instance.getLastFoodTime(instance),
            builder: (context, AsyncSnapshot snapshot) {
              return GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.asset(
                    'lib/images/greenFood.png',
                    height: MediaQuery.of(context).size.height *
                        0.20, // Adjust this value to fit your needs
                    width: MediaQuery.of(context).size.width * 0.20,
                  ),
                ),
                onTap: () {
                  debugPrint("last food time " + snapshot.data.toString());
                  animationNotifier.updateAnimationOnFoodTap(() {
                    StarsNotifier starsNotifier =
                        Provider.of<StarsNotifier>(context, listen: false);
                    int stars = starsNotifier.getStarsNumber(snapshot!.data);
                    starsNotifier.updateStars(stars);
                    instance.addStarCounter(instance, stars);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String starImage;
                        switch (stars) {
                          case 1:
                            starImage = 'lib/images/oneStar.png';
                            break;
                          case 2:
                            starImage = 'lib/images/two stars.png';
                            break;
                          case 3:
                            starImage = 'lib/images/threeStars.png';
                            break;
                          default:
                            starImage = 'lib/images/threeStars.png';
                        }
                        return AlertDialog(
                          backgroundColor: Colors.transparent,
                          content: Container(
                            width: MediaQuery.of(context).size.width *
                                0.8, // 80% of screen width
                            height: MediaQuery.of(context).size.height *
                                0.4, // 40% of screen height
                            child: Image.asset(
                              starImage,
                              fit: BoxFit.contain,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }, instance, DateTime.now());
                },
              );
            }),
      ],
    );
  }
}

class _KitchenscreenState extends State<Kitchenscreen> {
  String _currentAnimation = 'lib/images/Rabbit-Alive.gif';
  bool _fireworks = false;

  @override
  Widget build(BuildContext context) {
    FirebaseService instance =
        Provider.of<FirebaseService>(context, listen: false);

    return StreamBuilder<DateTime?>(
      stream: instance.med_info(instance, getWeekday()),
      builder: (context, AsyncSnapshot<DateTime?> last_medicine_snapshot) {
        if (!last_medicine_snapshot.hasData) {
          return Center(
            child: Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 5.0,
                ),
              ),
            ),
          );
        }
        return StreamBuilder<List<String>>(
            stream: instance.getMedSchedByDay(instance, getWeekday()),
            builder: (context, AsyncSnapshot<List<String>> snapshot1) {
              if (!snapshot1.hasData) {
                return Center(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        strokeWidth: 5.0,
                      ),
                    ),
                  ),
                );
              }
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider(
                    create: (context) => HeartsLevelNotifier(instance,
                        snapshot1.data!, last_medicine_snapshot.data!),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => AnimationNotifier(context),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => StarsNotifier(instance),
                  ),
                ],
                child: Builder(builder: (context1) {
                  HeartsLevelNotifier _heartlevel =
                      Provider.of<HeartsLevelNotifier>(context1, listen: false);
                  _heartlevel.initiateHearts(
                      instance, snapshot1.data!, last_medicine_snapshot.data!);
                  return Scaffold(
                    body: Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('lib/images/kitchen.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 35.0,
                                    left: 5), // adjust value as needed
                                child: heartsLevel(),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 20, 10, 10),
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Image.asset(
                                          'lib/images/starsCounter.png',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                        ),
                                        Consumer<StarsNotifier>(
                                          builder:
                                              (context, starsNotifier, child) {
                                            return Text(
                                                starsNotifier.currentStars
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                        255, 94, 65, 2)));
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Consumer<AnimationNotifier>(
                            builder: (context, animationNotifier, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  if (_fireworks)
                                    Lottie.asset('lib/images/fireworks.json'),
                                  Image.asset(
                                      animationNotifier.currentAnimation),
                                ],
                              );
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: SizedBox(
                                width: double.infinity,
                                child: MainButtons(),
                              )),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: CloudBackground(),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: CarrotArrows(
                            nextPage: BedroomScreen(),
                            previousPage: BathroomScreen(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              );
            });
      },
    );
  }
}
