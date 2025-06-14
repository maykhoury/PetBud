import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petbud/Designs.dart';
import 'package:petbud/parent/doctorAppointments/appointmentCard.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';

class EditAppointmentDialog extends StatefulWidget {
  AppointmentCard appointmentCard;

  EditAppointmentDialog({required this.appointmentCard});

  @override
  _EditAppointmentDialogState createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  //fetch the data to these controllers
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _TimeController = TextEditingController();
  TextEditingController _doctorNameController = TextEditingController();
  TextEditingController _hospitalNameController = TextEditingController();
  TextEditingController _alertTimeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.appointmentCard.description;
    _doctorNameController.text = widget.appointmentCard.doctor_name;
    _hospitalNameController.text = widget.appointmentCard.hospital_name;
    _TimeController.text =
        DateFormat('yyyy-MM-dd – kk:mm').format(widget.appointmentCard.time);
    _alertTimeController.text = DateFormat('yyyy-MM-dd – kk:mm')
        .format(widget.appointmentCard.alert_time);
  }

  @override
  Widget build(BuildContext context) {
    FirebaseService instance = Provider.of<FirebaseService>(context);
    return AlertDialog(
      title: Text('Edit Appointment',
          style: CustomTextStyle(18, blueColor, FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                initialValue: widget.appointmentCard.time,
                decoration: CustomInputDecoration(
                    'Date & Time', 'Date & Time', Icons.calendar_month),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date and time';
                  }
                  if (value.isBefore(DateTime.now())) {
                    return 'Date and time cannot be in the past';
                  }
                  return null;
                },
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
                onSaved: (value) {
                  // Save the time
                },
              ),
              SizedBox(height: 15),
              DateTimeField(
                controller: _alertTimeController,
                format: DateFormat("yyyy-MM-dd HH:mm"),
                initialValue: widget.appointmentCard.alert_time,
                decoration: CustomInputDecoration(
                    'Alert Time', 'Alert Time', Icons.alarm),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a date and time';
                  }
                  return null;
                },
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
                onSaved: (value) {
                  // Save the alert time
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            CustomButton("Cancel", whiteColor, blueColor,
                () => Navigator.of(context).pop()), //cancel
            CustomButton("Save", blueColor, whiteColor, () {
              if (!_formKey.currentState!.validate()) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Please fill all the fields'),
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
                  //update the appointmentCard
                  widget.appointmentCard.description =
                      _descriptionController.text;
                  widget.appointmentCard.doctor_name =
                      _doctorNameController.text;
                  widget.appointmentCard.hospital_name =
                      _hospitalNameController.text;
                  String dateTimeString =
                      _TimeController.text.replaceAll(' – ', 'T');
                  widget.appointmentCard.time = DateTime.parse(dateTimeString);
                  String dateAlertTimeString =
                      _alertTimeController.text.replaceAll(' – ', 'T');
                  widget.appointmentCard.alert_time =
                      DateTime.parse(dateAlertTimeString);
                  // Insert Appointment to firebase:
                  instance.updateAppointmentInFirebase(
                    widget.appointmentCard.id,
                    _descriptionController.text,
                    _doctorNameController.text,
                    _hospitalNameController.text,
                    DateTime.parse(dateTimeString),
                    DateTime.parse(dateAlertTimeString),
                    instance,
                    context,
                  );
                });
                // Close the dialog
                Navigator.of(context).pop();
                // Show a SnackBar with the message "Saved!"
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved!')),
                );
              }
            }), //Edit appointment and after that pop!
          ],
        ),
      ],
    );
  }
}
