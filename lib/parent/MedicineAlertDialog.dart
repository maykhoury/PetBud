import 'dart:io';

import 'package:flutter/material.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
import 'MedicineCard.dart';
import 'package:petbud/Designs.dart';
import 'MedicinePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class MedicineAlertDialog extends StatefulWidget {
  MedicineCard medicineCard;

  MedicineAlertDialog({required this.medicineCard});

  @override
  _MedicineAlertDialog createState() => _MedicineAlertDialog();
}

class _MedicineAlertDialog extends State<MedicineAlertDialog> {
  List<Map<String, dynamic>> timeFields = [];
  bool isEditing = false;
  TextEditingController _medicineNameController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    FirebaseService instance =
        Provider.of<FirebaseService>(context, listen: false);
    instance.getMedicineSchedule().then((medicines) {
      if (medicines != null) {
        Map<String, List<MedicineCard>> weeklySchedule = {
          'Monday': [],
          'Tuesday': [],
          'Wednesday': [],
          'Thursday': [],
          'Friday': [],
          'Saturday': [],
          'Sunday': [],
        };

        for (var medicine in medicines) {
          if (!medicine.times.isEmpty) {
            for (var entry in medicine.times.entries) {
              List<MedicineCard> medicineCards = entry.value.map((time) {
                return MedicineCard(
                  id: medicine.id,
                  medicine_name: medicine.medicine_name,
                  dosage: medicine.dosage,
                  times: {
                    '0': [time]
                  },
                  image: medicine.image,
                );
              }).toList();
              weeklySchedule[entry.key]?.addAll(medicineCards);
            }
          }
        }

        MedicineCard? medicine =
            medicines.firstWhereOrNull((m) => m.id == widget.medicineCard.id);
        if (medicine != null) {
          print(medicine.times.entries);
          fillTextBoxes(medicine);
        }
      }
    });
  }

  // ... rest of your code

  void fillTextBoxes(MedicineCard medicine) {
    _medicineNameController.text = medicine.medicine_name;
    _dosageController.text = medicine.dosage;

    // Clear the timeFields list
    timeFields.clear();

    // Iterate over the times map of the medicine
    for (var entry in medicine.times.entries) {
      String day = entry.key;
      List<String> timesForDay = entry.value;
      print('Day: $day, Times: $timesForDay');
      // Call addTimeField for each time
      for (String time in timesForDay) {
        addTimeField(day: day, time: time);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //ProgressNotifier progressNotifier = Provider.of<ProgressNotifier>(context);
    FirebaseService instance = Provider.of<FirebaseService>(context);
    MedicineCard medicine = widget.medicineCard;
    return FractionallySizedBox(
      widthFactor: 3,
      child: AlertDialog(
        backgroundColor: whiteColor.withOpacity(0.9),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Add this line
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: medicine.image.isEmpty
                      ? Image.asset("lib/images/defaultmedicine.jpg",
                          fit: BoxFit.fill)
                      : Image.network(medicine.image, fit: BoxFit.fill),
                ),
                SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    isEditing
                        ? Expanded(
                            child: CustomTextFromField(
                                controller: _medicineNameController,
                                labelText: 'Medicine Name',
                                hintText: 'Medicine Name',
                                prefixIcon: Icons.medication_outlined,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a medicine name';
                                  }
                                  return null;
                                }),
                          )
                        : Row(
                            children: <Widget>[
                              Icon(Icons.medication_outlined, color: redColor),
                              Text(
                                "Medicine name: ${medicine.medicine_name}",
                                style: CustomTextStyle(
                                    20, blueColor, FontWeight.bold),
                              ),
                            ],
                          ),
                  ],
                ),
                SizedBox(height: 10),
                isEditing
                    ? CustomTextFromField(
                        controller: _dosageController,
                        labelText: 'Dosage',
                        hintText: 'Dosage',
                        prefixIcon: Icons.add_chart,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a dosage';
                          }
                          return null;
                        })
                    : Text("Dosage: ${medicine.dosage} ",
                        style: CustomTextStyle(15, blueColor, FontWeight.bold)),
                SizedBox(height: 20),
                for (var field in timeFields)
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            isEditing
                                ? IconButton(
                                    icon: Icon(Icons.delete, color: redColor),
                                    onPressed: () {
                                      setState(() {
                                        timeFields.remove(field);
                                        //TODO: remove it from firebase database!!
                                      });
                                    },
                                  )
                                : Container(),
                            Expanded(
                              flex: 5,
                              child: isEditing
                                  ? DropdownButtonFormField<String>(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a day';
                                        }
                                        return null;
                                      },
                                      decoration: CustomInputDecoration(
                                          'Day', 'Day', null),
                                      value: field['day'],
                                      hint: Text("day",
                                          style: CustomTextStyle(
                                              15, blueColor, FontWeight.bold)),
                                      items: <String>[
                                        'Sunday',
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday',
                                        'Saturday'
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: CustomTextStyle(15,
                                                Colors.black, FontWeight.bold),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          field['day'] = newValue;
                                        });
                                      },
                                    )
                                  : Text(
                                      'Day: ${field['day']}',
                                      style: CustomTextStyle(
                                          15, blueColor, FontWeight.bold),
                                    ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Container(width: 1, height: 10)),
                            Expanded(
                              flex: 5,
                              child: isEditing
                                  ? Container(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a date';
                                          }
                                          return null;
                                        },
                                        readOnly: true,
                                        controller: field['controller'],
                                        decoration: CustomInputDecoration(
                                            'Time', 'Time', Icons.access_time),
                                        onTap: () async {
                                          TimeOfDay? pickedTime =
                                              await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );

                                          if (pickedTime != null) {
                                            field['controller'].text =
                                                pickedTime.format(context);
                                            field['time'] =
                                                pickedTime.format(context);
                                          }
                                        },
                                      ),
                                    )
                                  : Text(
                                      'Time: ${field['time']}',
                                      style: CustomTextStyle(
                                          15, blueColor, FontWeight.bold),
                                    ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  ),
                SizedBox(height: 20),
                if (isEditing)
                  CustomButton(
                      'Add Time', whiteColor, blueColor, () => addTimeField()),
                SizedBox(height: 20),
                if (isEditing)
                        CustomButton('Delete', whiteColor, Colors.red, () {
                          instance.deleteMedicineFromFirebase(medicine.id);
                          //progressNotifier.update();
                          Navigator.pop(context);
                        }), //TODO: DO WE NEED TO CANCEL NOTIFICATION?
                        SizedBox(height: 20)
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: blueColor), // Change color as needed
                ),
              ),
              CustomButton(
                isEditing ? 'Save' : 'Edit',
                blueColor,
                whiteColor,
                () {
                  setState(() {
                    if (!_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all the fields')),
                      );
                      return;
                    }
                    isEditing = !isEditing;

                    if (!isEditing) {
                      instance.updateMedicineInFirebase(
                          context,
                          medicine.id,
                          _medicineNameController.text,
                          _dosageController.text,
                          timeFields,
                          medicine.image);
                    //  progressNotifier.update();
                      medicine = MedicineCard(
                        id: medicine.id,
                        medicine_name: _medicineNameController.text,
                        dosage: _dosageController.text,
                        times: {
                          for (var field in timeFields)
                            field['day']: [field['time']]
                        },
                        image: medicine.image,
                      );
                      widget.medicineCard = medicine;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void addTimeField({String? day = null, String? time = null}) {
    setState(() {
      timeFields.add({
        'day': day,
        'time': time,
        'controller': TextEditingController(text: time ?? ''),
      });
    });
  }
}
