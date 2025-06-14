import 'package:flutter/material.dart';
import 'package:petbud/Designs.dart';
import 'package:petbud/parent/doctorAppointments/appointmentCard.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:petbud/parent/doctorAppointments/editAppointmentDialog.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';

class AppointmentsSchedule extends StatefulWidget {
  @override
  _AppointmentsScheduleState createState() => _AppointmentsScheduleState();
}

class _AppointmentsScheduleState extends State<AppointmentsSchedule> {
  bool _deleteMode = false;
  Color _iconColor = Color(0xff0040a9);
  final _formKey = GlobalKey<FormState>();
  //Controllers
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _TimeController = TextEditingController();
  TextEditingController _doctorNameController = TextEditingController();
  TextEditingController _hospitalNameController = TextEditingController();
  TextEditingController _alertTimeController = TextEditingController();

  // List of example AppointmentCard objects
  List<AppointmentCard> appointments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAppointments();
    });
    print(10000);
    for (var appointment in appointments) {
      print(appointment.description);
    }
  }

  void loadAppointments() async {
    FirebaseService instance =
        Provider.of<FirebaseService>(context, listen: false);
    List<AppointmentCard> loadedAppointments =
        await instance.getAppointmentsFromFirebase(instance);
    // Sort the appointments by time
    loadedAppointments.sort((a, b) => a.time.compareTo(b.time));
    setState(() {
      appointments = loadedAppointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseService instance =
        Provider.of<FirebaseService>(context, listen: false);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 250, 250).withOpacity(0.99),
      appBar: AppBar(
        title: Text(
          'Appointments Schedule',
          style: TextStyle(
            color: Color(0xff0040a9),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          SizedBox(width: 10),
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
      body: ListView.separated(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildCard(appointments[index], instance);
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: 15); // Adjust the height as needed
        },
      ),
      floatingActionButton: Container(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          backgroundColor: Color(0xffcb1522),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(50.0),
            ),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: whiteColor,
                  title: Text('Add Appointment',
                      style: TextStyle(
                        color: Color(0xff0040a9),
                        fontWeight: FontWeight.bold,
                      )),
                  content: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          CustomTextFromField(
                              controller: _descriptionController,
                              labelText: 'Description',
                              hintText: 'Description',
                              prefixIcon: Icons.description,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              }),
                          SizedBox(height: 15),
                          CustomTextFromField(
                              controller: _doctorNameController,
                              labelText: 'Doctor Name',
                              hintText: 'Doctor Name',
                              prefixIcon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a doctor name';
                                }
                                return null;
                              }),
                          SizedBox(height: 15),
                          CustomTextFromField(
                              controller: _hospitalNameController,
                              labelText: 'Hospital Name',
                              hintText: 'Hospital Name',
                              prefixIcon: Icons.local_hospital,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a hospital name';
                                }
                                return null;
                              }),
                          SizedBox(height: 15),
                          DateTimeField(
                            controller: _TimeController,
                            format: DateFormat("yyyy-MM-dd HH:mm"),
                            decoration: CustomInputDecoration('Date & Time',
                                'Date & Time', Icons.calendar_month),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please pick a date and time';
                              }
                              if (value.isBefore(DateTime.now())) {
                                return 'Date and time cannot be in the past';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // Save the time
                            },
                          ),
                          SizedBox(height: 15),
                          DateTimeField(
                            controller: _alertTimeController,
                            format: DateFormat("yyyy-MM-dd HH:mm"),
                            decoration: CustomInputDecoration(
                                'Alert Time', 'Alert Time', Icons.alarm),
                            onShowPicker: (context, currentValue) async {
                              final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (date != null) {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.combine(date, time);
                              } else {
                                return currentValue;
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please pick an alert time';
                              }
                              if (value.isBefore(DateTime.now())) {
                                return 'Alert time cannot be in the past';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              // Save the alert time
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    CustomButton("Cancel", whiteColor, blueColor,
                        () => Navigator.of(context).pop()), //cancle
                    CustomButton("Add", blueColor, whiteColor, () {
                      if (!_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('Please fill all fields correctly'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        setState(() {
                          // Insert Appointment to firebase:
                          instance.addAppointmentToFirebase(
                              _descriptionController.text,
                              _doctorNameController.text,
                              _hospitalNameController.text,
                              DateTime.parse(_TimeController.text),
                              DateTime.parse(_alertTimeController.text),
                              instance,
                              context);
                          loadAppointments();
                        });
                        // Close the dialog
                        Navigator.of(context).pop();
                      }
                    })
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(AppointmentCard appointmentCard, FirebaseService instance) {
    return Card(
      child: ListTile(
        leading: Image.asset('lib/images/appointment.png'),
        title: Text(
          appointmentCard.description,
          style: CustomTextStyle(18, blueColor, FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Doctor: ' + appointmentCard.doctor_name,
              style: CustomTextStyle(16, blueColor, FontWeight.bold),
            ),
            Text(
              'Hospital: ' + appointmentCard.hospital_name,
              style: CustomTextStyle(16, blueColor, FontWeight.bold),
            ),
            Text(
              'Time: ' +
                  DateFormat('yyyy-MM-dd – kk:mm').format(appointmentCard.time),
              style: CustomTextStyle(18, Colors.red, FontWeight.bold),
            ),
            Text(
              'Alert: ' +
                  DateFormat('yyyy-MM-dd – kk:mm')
                      .format(appointmentCard.alert_time),
              style: CustomTextStyle(18, Colors.red, FontWeight.bold),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _deleteMode
                ? IconButton(
                    icon: Icon(Icons.remove_circle, color: Color(0xffcb1522)),
                    onPressed: () {
                      // Insert Appointment to firebase:

                      setState(() {
                        instance.deleteAppointmentFromFirebase(
                            appointmentCard.id, instance);
                        loadAppointments();
                      });
                      // Close the dialog
                      //Navigator.of(context).pop();
                    },
                  )
                : Container(),
            IconButton(
              icon: Icon(Icons.more_vert, color: Color(0xff0040a9)),
              onPressed: () async {
                // Edit appointment alert dialog
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return EditAppointmentDialog(
                        appointmentCard: appointmentCard);
                  },
                );
                setState(() {
                  
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
