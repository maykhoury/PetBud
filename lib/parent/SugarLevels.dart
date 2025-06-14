import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petbud/Designs.dart';
import 'package:petbud/parent/SugarCard.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:petbud/parent/SugarCard.dart';

class SugarLevelsScreen extends StatefulWidget {
  @override
  _SugarLevelsScreenState createState() => _SugarLevelsScreenState();
}

class _SugarLevelsScreenState extends State<SugarLevelsScreen> {
  List<SugarCard> _listItems = <SugarCard>[];
  final PanelController _panelController = PanelController();

  Color _iconColor = Color(0xff0040a9);
  bool _deleteMode = false;
  _SugarLevelsScreenState() {}

  Widget listWidget(FirebaseService instance) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: _listItems.length,
        itemBuilder: (context, index) {
          return Center(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                child: Card(
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: SugarLevel(instance, _listItems, index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget SugarLevel(
      FirebaseService instance, List<SugarCard> _listItems, int index) {
    return Stack(
      children: <Widget>[
        ListTile(
          trailing: _deleteMode
              ? IconButton(
                  icon: Icon(Icons.remove_circle, color: Color(0xffcb1522)),
                  onPressed: () {
                    instance.deleteSugarCardFromFirebase(
                        _listItems[index].id, instance);
                  },
                )
              : null,
          leading: Container(
              height: 25,
              width: 25,
              child: Image.asset('lib/images/BloodDrop.png')),
          title: Text(
            printDate(_listItems[index].date_time),
            //"hi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff0040a9),
            ),
          ),
          subtitle: Text(
            'Sugar Level - ' +
                _listItems[index].sugarLevel.toString() +
                ' mg/dL',
            style: TextStyle(
              color: Color(0xff0040a9),
            ),
          ),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: Text(
            printTime(_listItems[index].date_time), //.printTime(),
            //"hi",
            style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Color(0xff006fdc)),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final PanelController _panelController = PanelController();
    FirebaseService instance = Provider.of<FirebaseService>(context);
    // future: _listItems =  instance.getSugarLevels();
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
              return Text(
                  'Error: ${snapshot.error}'); // Show error if something went wrong
            } else {
              _listItems = snapshot.data!;
              return Scaffold(
                  backgroundColor:
                      Color.fromARGB(255, 250, 250, 250).withOpacity(0.99),
                  appBar: AppBar(
                    title: Text(
                      'Sugar Levels',
                      style: TextStyle(
                        color: Color(0xff0040a9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: <Widget>[
                      SizedBox(width: 50),
                      IconButton(
                        icon: Icon(Icons.delete, color: _iconColor),
                        onPressed: () {
                          setState(() {
                            if (_iconColor == Color(0xff0040a9)) {
                              _iconColor = Color(0xffcb1522);
                              _deleteMode = true;
                            } else {
                              _iconColor = Color(0xff0040a9);
                              _deleteMode = false;
                            }
                          });
                        },
                      ),
                      SizedBox(width: 10), // Adjust the width as needed
                    ],

                    //elevation:5.0,
                  ),
                  body: SlidingUpPanel(
                    minHeight: MediaQuery.of(context).size.height * 0.07,
                    controller: _panelController,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    body: Column(children: <Widget>[
                      SizedBox(height: 10),
                      Expanded(child: listWidget(instance)),
                    ]),
                    panelBuilder: (controller) => PanelWidget(
                      controller: controller,
                      panelController: _panelController,
                    ),
                  ));
            }
          });
    });
  }
}

class PanelWidget extends StatefulWidget {
  final ScrollController controller;
  final PanelController panelController;

  PanelWidget(
      {Key? key, required this.controller, required this.panelController})
      : super(key: key);

  @override
  _PanelWidgetState createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  late TextEditingController _timeController;
  late TextEditingController _dateController;
  late TextEditingController sugarLevelController;

  final _formKey = GlobalKey<FormState>();
  final _sugarLevelKey = GlobalKey<FormFieldState>();
  final _timeLevellKey = GlobalKey<FormFieldState>();
  final _dateLevelKey = GlobalKey<FormFieldState>();

  bool sugarValidate = true;
  bool dateValidate = true;
  bool timeValidate = true;
  bool allValidate = true;
  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController();
    _dateController = TextEditingController();
    sugarLevelController = TextEditingController();
  }

  Widget buildDragHandle() => Center(
        child: Container(
          width: 30,
          height: 5,
          decoration: BoxDecoration(
            color: Color(0xff0040a9),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    FirebaseService instance = Provider.of<FirebaseService>(context);

    double screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: ListView(controller: widget.controller, children: <Widget>[
        SizedBox(height: 12),
        buildDragHandle(),
        SizedBox(height: 12),
        Center(
          child: Text('Add a new Sugar level',
              style: TextStyle(
                color: Color(0xff0040a9),
              )),
        ),
        SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: screenWidth * 0.9,
            height: 400,
            child: Column(
              children: [
                Container(
                    width: screenWidth * 0.95,
                    //   child: TextField(
                    child: TextFormField(
                      key: _sugarLevelKey,
                      keyboardType: TextInputType.number,
                      controller: sugarLevelController,
                      decoration: CustomInputDecoration(
                          'Sugar Level in mg/dL', 'Sugar Level', Icons.add),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a number';
                        } else if (int.parse(value) > 300) {
                          return 'Please enter a number less than or equal to 200';
                        } else if(int.parse(value) < 0) {
                          return 'Please enter a number greater than 0';
                        }
                        return null;
                      },
                    )),
                SizedBox(height: 20),
                Container(
                  width: screenWidth * 0.95,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a number';
                      } else {
                        DateTime selectedDate =
                            DateFormat('yyyy-MM-dd').parse(value);
                        if (selectedDate.isAfter(DateTime.now())) {
                          return 'Please enter a date that is not in the future';
                        }
                      }
                      return null;
                    },
                    controller: _dateController,
                    decoration: CustomInputDecoration(
                        'Date', 'Date', Icons.calendar_today_rounded),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDate != null) {
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                        _dateController.text = formattedDate;
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth * 0.95,
                  child: TextFormField(
                    validator: EmptyValidator("Time"),
                    readOnly: true,
                    controller: _timeController,
                    decoration: CustomInputDecoration(
                        "Time", "Time", Icons.access_time),
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        _timeController.text = pickedTime.format(context);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: screenWidth * 0.5,
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xff0040a9)),
                          elevation: MaterialStateProperty.all<double>(5.0),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                      
                          if (!_formKey.currentState!.validate())
                          {
                              printSnackBar(context, "Please fill all fields correctly");
                          }
                          else {
                            DateTime time =
                                DateFormat.jm().parse(_timeController.text);
                            DateTime date = DateFormat('yyyy-MM-dd')
                                .parse(_dateController.text);
                            DateTime date_time = DateTime(date.year, date.month,
                                date.day, time.hour, time.minute);
                            double sugarLevel =
                                double.parse(sugarLevelController.text);
                            instance.AddSugarLevelToFirebase(
                                date_time, sugarLevel, instance);
                          }
                        },
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
                        )))
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

String printDate(DateTime date_time) {
  DateTime date = DateTime(date_time.year, date_time.month, date_time.day);
  return DateFormat('MM/dd/yyyy').format(date);
}

String printTime(DateTime date_time) {
  DateFormat dateFormat = DateFormat.jm(); // jm format for time in AM/PM format
  String time = dateFormat.format(date_time);
  return time;
}

void printSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}
