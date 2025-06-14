import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../parent/ProgressBarNotifier.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:petbud/notifications.dart';
import 'package:petbud/parent/MedicineCard.dart';
import 'package:petbud/parent/MedicinePage.dart';
import 'package:petbud/parent/doctorAppointments/appointmentCard.dart';
import 'package:petbud/settings/customStepper.dart';
import 'package:petbud/settings/settings.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petbud/parent/SugarCard.dart';
import 'package:provider/provider.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'dart:math';
import 'package:gradient_progress_bar/gradient_progress_bar.dart';
import 'SugarLevels.dart';
import 'package:petbud/Designs.dart';
import 'package:intl/intl.dart';
import 'doctorAppointments/appointmentsSchedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentHomePage extends StatefulWidget {
  final bool shouldScrollToEnd;

  ParentHomePage({this.shouldScrollToEnd = false});

  @override
  _ParentHomePageState createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  List<ActiveNotification> notifications = [];
  final ScrollController _scrollController = ScrollController();
  List<SugarCard> sugarCards = <SugarCard>[];
  SugarCard defaultSugarCard =
      new SugarCard(id: "", date_time: DateTime.now(), sugarLevel: -1.0);

  @override
  void initState() {
    super.initState();
    updateNotifications();
    if (widget.shouldScrollToEnd) {
      // Scroll to the end of the screen after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 1500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
            );
          }
        });
      });
    }
  }

  Future<void> updateNotifications() async {
    NotificationServices notificationServices =
        Provider.of<NotificationServices>(context, listen: false);
    await notificationServices.fetchNotifications();
    //notifications = notificationServices.notifications;
  }

  @override
  Widget build(BuildContext context) {
    print('Building ParentHomePage');

    FirebaseService instance = Provider.of<FirebaseService>(context);
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    NotificationServices notificationServicesInstance =
        Provider.of<NotificationServices>(context);

    //updateNotifications();
    //List<ActiveNotification> notifications = notificationServices.notifications;

    print('Notifications: $notifications');
    // return ChangeNotifierProvider(
    //   create: (context) => ProgressNotifier(),
    //   child:
    return Consumer<FirebaseService>(
            builder: (context, FirebaseService, child) {
      return FutureBuilder(
          future: instance.getSugarLevels(),
          builder:
              (BuildContext context, AsyncSnapshot<List<SugarCard>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
              ); // Show a loading spinner while waiting
            } else if (snapshot.hasError) {
              debugPrint(sugarCards.toString());
              return Text(
                  'Error: ${snapshot.error}'); // Show error if something went wrong
            } else {
              sugarCards = snapshot.data!;
              return Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      icon: Icon(Icons.logout),
                      color: Color(0xff0040a9),
                      onPressed: () async {
                        await instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (Route<dynamic> route) => false);
                      },
                    ),
                    title: Text('Home Page',
                        style: TextStyle(
                          color: Color(0xff0040a9),
                          fontWeight: FontWeight.bold,
                        )),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.settings),
                        color: Color(0xff0040a9),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          notifications.isEmpty
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                        ),
                        color: notifications.isEmpty
                            ? Color(0xff0040a9)
                            : Colors.amber[700],
                        onPressed: () {
                          _scrollToEnd();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.info),
                        color: Color(0xff0040a9),
                        onPressed: () {
                          // Handle the info button press
                          showAboutDialog(context: context);
                          showAboutDialog(
                              context: context,
                              applicationName: 'petBud',
                              children: [
                                Text(
                                  'Developed by:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'May Khoury',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Yasmin Irshied',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Katia Haj',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Samir Graieb',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Graphics by:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Riad Zoabi',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                              ]);
                        },
                      ),
                    ]),
                backgroundColor:
                    Color.fromARGB(255, 250, 250, 250).withOpacity(0.99),
                body: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        // First row with two columns
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            // Left column with two rows
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  FutureBuilder(
                                    future: instance
                                        .getAppointmentsFromFirebase(instance),
                                    builder: (context, snapshot1) {
                                      if (snapshot1.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(); // Return an empty container
                                      } else if (snapshot1.hasError) {
                                        return Text(
                                            'Error: ${snapshot1.error}');
                                      } else {
                                        AppointmentCard?
                                            upcomingAppointmentCard =
                                            getUpcomingAppointmentCard(
                                                instance, snapshot1.data);

                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.20, // Adjust as needed
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  '/appointments_schedule');
                                            },
                                            child: StreamBuilder(
                                                stream: Stream.periodic(
                                                    Duration(minutes: 1),
                                                    (i) => DateTime.now()),
                                                builder: (context, snapshot) {
                                                  return _buildNextAppointment(
                                                    context,
                                                    getUpcomingAppointmentCard(
                                                        instance,
                                                        snapshot1.data),
                                                  );
                                                }),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  FutureBuilder(
                                      future: instance.getMedicineSchedule(),
                                      builder: (context, snapshot2) {
                                        MedicineCard? upcomingMedicineCard =
                                            getUpcomingMedicineCard(
                                                instance, snapshot2.data);

                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.20, // Adjust as needed
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(context,
                                                  '/medicine_list_page');
                                            },
                                            child: StreamBuilder(
                                                stream: Stream.periodic(
                                                    Duration(minutes: 1),
                                                    (i) => DateTime.now()),
                                                builder: (context, snapshot) {
                                                  upcomingMedicineCard =
                                                      getUpcomingMedicineCard(
                                                          instance,
                                                          snapshot2.data);
                                                  if (upcomingMedicineCard ==
                                                      null) {
                                                    return _buildNextMedicine(
                                                        context,
                                                        MedicineCard(
                                                          id: "1",
                                                          medicine_name:
                                                              "No Medicine",
                                                          dosage: "",
                                                          times: {
                                                            "morning": ["--"],
                                                          },
                                                          image: '',
                                                        ));
                                                  } else {
                                                    return _buildNextMedicine(
                                                        context,
                                                        upcomingMedicineCard);
                                                  }
                                                }),
                                          ), // For demonstration purposes
                                        );
                                      }),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.20, // Adjust as needed
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/sugar_levels_screen');
                                        },
                                        child: sugarCards != null &&
                                                sugarCards.isNotEmpty
                                            ? _buildLastSugarLevel(context,
                                                instance, sugarCards.first)
                                            : _buildLastSugarLevel(
                                                context,
                                                instance,
                                                defaultSugarCard)), // For demonstration purposes
                                  ),
                                ],
                              ),
                            ),
                            //Right column with one row
                            StreamBuilder<DateTime?>(
                                stream:
                                    instance.med_info_parent(instance, getWeekday()),
                                builder: (context,
                                    AsyncSnapshot<DateTime?>
                                        last_medicine_snapshot) {
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
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.blue),
                                            strokeWidth: 5.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return StreamBuilder<List<String>>(
                                    stream: instance.getMedSchedByDayParent(
                                        instance, getWeekday()),
                                    builder: (context,
                                        AsyncSnapshot<List<String>> snapshot1) {
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
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.blue),
                                                strokeWidth: 5.0,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      switch (snapshot1.connectionState) {
                                        case ConnectionState.waiting:
                                          return Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.blue),
                                              strokeWidth: 5.0,
                                            ),
                                          );
                                        default:
                                          return Expanded(
                                            flex: 2,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.6,
                                              child: ChangeNotifierProvider(
                                                create: (context1) {
                                                  var progressNotifier =
                                                      ProgressBarNotifier(
                                                    instance,
                                                    snapshot1.data!,
                                                    last_medicine_snapshot
                                                        .data!,
                                                  );
                                                  progressNotifier
                                                      .initiateProgressBar(
                                                    instance,
                                                    snapshot1.data!,
                                                    last_medicine_snapshot
                                                        .data!,
                                                  );
                                                  return progressNotifier;
                                                },
                                                child: Consumer<
                                                    ProgressBarNotifier>(
                                                  builder: (context,
                                                      progressNotifier, child) {
                                                    return _buildProgressBar(
                                                        progressNotifier.value);
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                      }
                                    },
                                  );
                                }),
                          ],
                        ),
                        // Second row
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.35, // Adjust as needed
                          child: _buildGraph(instance,
                              sugarCards), // For demonstration purposes
                        ),
                        // Third row
                        // displaying all sent notifications
                        Container(
                          height: MediaQuery.of(context).size.height *
                              0.8, // Adjust as needed
                          child: Consumer<NotificationServices>(
                            builder: (context, notificationServices, child) {
                              return FutureBuilder<
                                  List<PendingNotificationRequest>>(
                                future:
                                    notificationServices.fetchNotifications(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            List<PendingNotificationRequest>>
                                        snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child:
                                            CircularProgressIndicator()); // Show a loading spinner while waiting
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}'); // Show error if there is any
                                  } else {
                                    List<PendingNotificationRequest>
                                        notifications = snapshot.data!;
                                    print('Notifications: $notifications');
                                    return _buildNotificationsCard(
                                        notifications,
                                        Colors.white,
                                        context,
                                        notificationServices);
                                  }
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          });
    })
        //   ,
        // )
        ;
  }

  Widget _buildNotificationsCard(
      List<PendingNotificationRequest> notifications,
      Color color,
      BuildContext context,
      NotificationServices notificationServices) {
    return Card(
      color: whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.amber[700]),
                    SizedBox(
                        width:
                            8), // provide some spacing between the icon and the text
                    Text(
                      'Recent Notifications',
                      style: TextStyle(
                          fontSize: 20, // adjust as needed
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0040a9)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () async {
                    notifications =
                        await notificationServices.fetchNotifications();
                    setState(() {});
                  },
                ),
              ],
            ),
            Divider(color: Color(0xff0040a9), thickness: 3),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text('No notifications',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)))
                  : ListView(
                      children: notifications.map((notification) {
                        // Parse the payload
                        Map<String, dynamic> payload =
                            jsonDecode(notification.payload!);
                        String title = payload['title'];
                        String body = payload['body'];

                        // Check if the notification is scheduled for today and before the current time
                        DateTime now = DateTime.now();
                        bool isTodayAndBeforeNow;
                        if (title.contains('Time to take')) {
                          // This is a recurring notification
                          String todayDayString =
                              DateFormat('EEEE').format(now);
                          DateTime notificationTime =
                              DateFormat('HH:mm').parse(payload['time']);
                          DateTime currentTime = DateFormat('HH:mm')
                              .parse(DateFormat('HH:mm').format(now));
                          isTodayAndBeforeNow =
                              payload['day'] == todayDayString &&
                                  !notificationTime.isAfter(currentTime);
                        } else if (title.contains('Doctor Appointment')) {
                          // This is a one-time notification
                          DateTime scheduledDate =
                              DateTime.fromMillisecondsSinceEpoch(
                                  payload['timestamp']);
                          isTodayAndBeforeNow = scheduledDate.day == now.day &&
                              scheduledDate.month == now.month &&
                              scheduledDate.year == now.year &&
                              scheduledDate.isBefore(now);
                        } else {
                          // Unknown notification type
                          print('Unknown notification type: $title');
                          isTodayAndBeforeNow = false;
                        }

                        // Only display the notification if it is scheduled for today and before the current time
                        return isTodayAndBeforeNow
                            ? Column(
                                children: [
                                  Text(
                                    '$title\n$body',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff0040a9)),
                                    textAlign: TextAlign.center,
                                  ),
                                  Divider(
                                      color: Color(0xff0040a9), thickness: 1),
                                ],
                              )
                            : Container();
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }
}

bool isThereNotifications() {
  return false;
}

//Progress bar for pet's health -----------------------------------------------------------------------
Widget _buildProgressBar(int value) {
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Align(
          alignment: Alignment(0.0, 0.0),
          child: Column(
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.05,
              ),
              Text(
                  'Pet\'s Health ' +
                      ((value / 5) * 100).toInt().toString() +
                      '%',
                  style: TextStyle(
                    color: Color(0xff0040a9),
                    fontWeight: FontWeight.bold,
                    fontSize: constraints.maxWidth * 0.08,
                  )),
              SizedBox(
                height: constraints.maxHeight * 0.04,
              ),
              Container(
                height: constraints.maxHeight * 0.8,
                width: 35,
                child: RotatedBox(
                  quarterTurns: -1,
                  child: AnimatedProgressBar(
                    value: value == 0 ? 0 : ((value / 5)).toDouble(),
                    duration: const Duration(seconds: 3),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 17, 0),
                        Colors.orange,
                        Color.fromARGB(255, 95, 197, 99)
                      ],
                    ),
                    backgroundColor: Colors.grey.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
}

String getWeekday() {
  var now = DateTime.now();
  var weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  return weekdays[now.weekday - 1];
}
// be careful we need to send the hearts number from the child page to parent page by
//using provider becuase the heart number is not saved in firebase ( wrap the card with future builder or something)

double getHealthValue(BuildContext context, List<String> all_med_times,
    DateTime? last_medicine, Map<String, dynamic> schedule_diff) {
  debugPrint("im hereeee");
  FirebaseService instance = Provider.of<FirebaseService>(context);
  DateTime now = DateTime.now();
  DateTime closestTimeAfter = schedule_diff['closestTimeAfter'];
  DateTime closestTimeBefore = schedule_diff['closestTimeBefore'];
  int duration = schedule_diff['interval'];
  debugPrint("duration: " + duration.toString());
  if (duration == 0 || last_medicine == null) return 1;
  if (last_medicine.isBefore(closestTimeBefore)) return 0;
  int last_now = closestTimeAfter.difference(last_medicine).abs().inMinutes;
  int numOfHearts = ((last_now / duration) * 5).ceil();
  debugPrint("health value:");
  debugPrint((numOfHearts / 5).toString());
  return (numOfHearts / 5);
}

Widget _buildNextAppointment(
    BuildContext context, AppointmentCard? appointmentCard) {
  String doctorName = 'No Appointments';
  String appointmentTime = '';
  String description = 'No Appointments';
  if (appointmentCard != null && appointmentCard.id != "") {
    doctorName = appointmentCard.doctor_name;
    appointmentTime =
        DateFormat('yyyy-MM-dd hh:mm a').format(appointmentCard.time);
    description = appointmentCard.description;
  }

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return Card(
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: constraints.maxWidth * 0.1,
                        color: blueColor,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text('Upcoming Appointments',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth * 0.06,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: constraints.maxWidth * 0.02,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            // Use Expanded instead of a fixed width Container
                            child: Text(description,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  color: blueColor,
                                  fontSize: constraints.maxHeight * 0.15,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),
                      if (appointmentCard != null && appointmentCard.id != "")
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(appointmentTime,
                              style: TextStyle(
                                color: blueColor,
                                fontSize: constraints.maxHeight * 0.09,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      SizedBox(
                        height: constraints.maxWidth * 0.02,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// View upcoming Medicine----------------------------------------------------------------------------------------
Widget _buildNextMedicine(BuildContext context, MedicineCard? medicineCard) {
  String medicineName = '';
  String time = '';
  if (medicineCard != null && medicineCard.id != "") {
    medicineName = medicineCard.medicine_name.toString();
    if (medicineCard.times['0'] != null) {
      time = medicineCard.times['0']!.first.toString();
    }
  }
  return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white, //Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: constraints.maxWidth * 0.1,
                      color: blueColor,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('Upcoming Medicine',
                        style: TextStyle(
                          color: blueColor, //Color(0xff0040a9),
                          fontWeight: FontWeight.bold,
                          fontSize: constraints.maxWidth * 0.06, // Adjust t
                        )),
                  ],
                ),
                SizedBox(
                  height: constraints.maxWidth * 0.02,
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: constraints.maxHeight * 0.2,
                          child: Text(medicineName,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: blueColor, //Color(0xff0040a9),
                                fontSize: constraints.maxHeight * 0.15,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    // SizedBox(height: constraints.maxHeight * 0.08),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(time,
                          style: TextStyle(
                            color: blueColor,
                            fontSize: constraints.maxHeight * 0.09,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
}

MedicineCard? getUpcomingMedicineCard(
    FirebaseService firebaseService, List<MedicineCard>? medicineSchedule) {
  MedicineCard? upcomingMedicineCard = null;
  DateTime now = DateTime.now();
  var timeFormat = DateFormat("h:mm a");
  String weekday = DateFormat('EEEE').format(now);
  DateTime currentTime = timeFormat.parse(timeFormat.format(now));
  Map<String, List<MedicineCard>> weeklySchedule =
      getWeeklySchedule(medicineSchedule);
  List<MedicineCard>? todayMedicine = weeklySchedule[weekday];

  if (todayMedicine != null && !todayMedicine.isEmpty) {
    todayMedicine.sort((a, b) {
      if (a.times['0'] == null || b.times['0'] == null) {
        return 0;
      }
      var timeA = timeFormat.parse(a.times['0']!.first);
      var timeB = timeFormat.parse(b.times['0']!.first);
      return timeA.compareTo(timeB);
    });

    for (MedicineCard medicineCard in todayMedicine) {
      //  print(medicineCard.medicine_name + medicineCard.times['0'].toString());
      if (medicineCard.times['0'] == null) {
        continue;
      }
      var medicineTime = timeFormat.parse(medicineCard.times['0']!.first);
      if (medicineTime.compareTo(currentTime) > 0) {
        upcomingMedicineCard = medicineCard;
        break;
      }
    }
  }
  return upcomingMedicineCard;
}

AppointmentCard? getUpcomingAppointmentCard(
    FirebaseService instance, List<AppointmentCard>? appointments) {
  // Check if appointments is null
  if (appointments == null) {
    return null;
  }

  // Sort the appointments in ascending order of time
  appointments.sort((a, b) => a.time.compareTo(b.time));

  // Get the current time
  DateTime now = DateTime.now();

  // Find the first appointment that is in the future
  for (AppointmentCard appointment in appointments) {
    if (appointment.time.isAfter(now)) {
      return appointment;
    }
  }

  // If no future appointment is found, return null
  return null;
}

// View last measured sugar level--------------------------------------------------------------------------------
Widget _buildLastSugarLevel(
    BuildContext context, FirebaseService instance, SugarCard sugarCard) {
  String sugarLevel = "--";
  if (sugarCard.id != "") {
    sugarLevel = sugarCard.sugarLevel.toString();
  }
  int color = 0xffffffff; //0xff0040a9;
  String image = 'lib/images/WhiteBlood.png';
  return Card(
    surfaceTintColor: Colors.white,
    color: Color(0xffcb1522), //Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: EdgeInsets.all(10),
    child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Image.asset(
                      image,
                      height: constraints.maxHeight * 0.2,
                      width: constraints.maxWidth * 0.2,
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.02,
                    ),
                    Text('Last sugar level',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.07,
                          color: Color(color), //Color(0xff0040a9),
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: constraints.maxHeight * 0.05,
              ),
              Center(
                child: Row(
                  children: [
                    Text(sugarLevel,
                        style: TextStyle(
                          color: Color(color), //Color(0xff0040a9),
                          fontSize: constraints.maxWidth * 0.15,
                          fontWeight: FontWeight.bold,
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Text('mg/dL',
                            style: TextStyle(
                              color: Color(color), //Color(0xff0040a9),
                              fontSize: constraints.maxWidth * 0.05,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

//Graph for sugar levels --------------------------------------------------------------------------------
Widget _buildGraph(FirebaseService instance, List<SugarCard> sugarCards) {
  if (sugarCards.isEmpty) {
    return Stack(children: <Widget>[
      _buildCard(Colors.white),
      Center(
          child: Text("No sugar levels yet",
              style: CustomTextStyle(20, blueColor, FontWeight.bold)))
    ]);
  }
  return Card(
    surfaceTintColor: Colors.white,
    color: Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: EdgeInsets.all(10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.only(right: 16.0, top: 16.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 30,
                minY: 0,
                maxY: 300,
                lineBarsData: [
                  LineChartBarData(
                    color: Color(0xff0040a9),
                    spots: instance.convertSugarCardsToGraph(sugarCards),
                    isCurved: false,
                    barWidth: 3,
                    dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          List<Color> colors = [
                            //Color(0xffcb1522)
                            Color(0xffa55fef),
                            Color(0xff3aafff),
                            Color(0xfffd8916),
                            Color(0xfffcca38)
                          ];

                          // Choose a color based on the index
                          Color color = colors[index % colors.length];
                          return FlDotCirclePainter(
                            radius: 5,
                            color: Color(0xffcb1522),
                          );
                        }),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: false,
                  drawHorizontalLine: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey, strokeWidth: 0.5),
                  getDrawingVerticalLine: (value) =>
                      FlLine(color: Colors.grey, strokeWidth: 0.5),
                ),
                // borderData: FlBorderData(
                //   show: true,
                //   border: Border.all(color: Colors.grey, width: 1),
                // ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    top: BorderSide.none,
                    right: BorderSide.none,
                    bottom: BorderSide(color: Colors.grey, width: 1),
                    left: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildCard(Color color) {
  return Card(
    color: color,
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    margin: EdgeInsets.all(10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      // child: Image.asset(
      //   'lib/images/cardBackground.jpg',
      //   fit: BoxFit.cover,
      // ),
      child: Container(
        color: color,
      ),
    ),
  );
}
