import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/parent/MedicineAlertDialog.dart';
import 'MedicineCard.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:petbud/Designs.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:permission_handler/permission_handler.dart';

class AddMedicineDialog extends StatefulWidget {
  BuildContext may;
  AddMedicineDialog(this.may);
  @override
  _AddMedicineDialog createState() => _AddMedicineDialog();
}

class _AddMedicineDialog extends State<AddMedicineDialog> {
  List<Map<String, dynamic>> timeFields = [];
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController dosageController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  XFile? pickedFile;
  final _formKey = GlobalKey<FormState>();
  bool timeAdded = false;
  //TextEditingController _timeController = TextEditingController();

  void addTimeField() {
    setState(() {
      timeFields.add({
        'day': null,
        'time': null,
        'controller': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseService instance = Provider.of<FirebaseService>(context);
    //ProgressNotifier progressNotifier = Provider.of<ProgressNotifier>(context);
    BuildContext buildContext = context;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FractionallySizedBox(
        widthFactor:
            3, // Set the width factor to control the width of the AlertDialog
        child: AlertDialog(
          // Your AlertDialog code here
          backgroundColor: whiteColor.withOpacity(0.9),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Medicine',
                  style: TextStyle(
                      color: Color(0xff0040a9),
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
              IconButton(
                  icon: Icon(Icons.camera_alt_rounded,
                      color: blueColor, size: 25),
                  onPressed: () {
                    AddPicture(context);
                  }),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  if (pickedFile != null)
                    Container(
                      height: 100,
                      width: 100,
                      child: pickedFile != null
                          ? Image.file(
                              File(pickedFile!.path),
                              fit: BoxFit.fill,
                            )
                          : Icon(
                              Icons.add_a_photo,
                              color: blueColor,
                              size: 50,
                            ),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15), // Adjust as needed
                        image: DecorationImage(
                            image: FileImage(File(pickedFile!.path)),
                            fit: BoxFit.cover),
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextFromField(
                      controller: medicineNameController,
                      labelText: 'Medicine Name',
                      hintText: 'Medicine Name',
                      prefixIcon: Icons.medication_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a medicine name';
                        }
                        return null;
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  CustomTextFromField(
                      controller: dosageController,
                      labelText: 'Dosage',
                      hintText: 'Dosage',
                      prefixIcon: Icons.add_chart,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a dosage';
                        }
                        double? dosage = double.tryParse(value);
                        if (dosage == null) {
                          return 'Please enter a valid number';
                        }
                        if (dosage <= 0) {
                          return 'Dosage must be greater than 0';
                        }
                        return null;
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  for (var field in timeFields)
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField<String>(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a day';
                                    }
                                    return null;
                                  },
                                  decoration:
                                      CustomInputDecoration('Day', 'Day', null),
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
                                        style: CustomTextStyle(
                                            15, Colors.black, FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      field['day'] = newValue;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(width: 1, height: 10)),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a time';
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
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  CustomButton('Add Time', whiteColor, blueColor, () {
                    timeAdded = true;
                    addTimeField();
                  }),
                  SizedBox(height: 20)
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: blueColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CustomButton('Add', blueColor, whiteColor, () {
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
                return;
              }
              if (timeAdded == false) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Please add at least one time'),
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
                return;
              }
              String medicineName = medicineNameController.text.toString();
              String dosage = dosageController.text.toString();
              //DateTime time = DateFormat.jm().parse(_timeController.text);
              File imageFile = File('');
              if (pickedFile != null) {
                imageFile = File(pickedFile!.path);
              }
              print('image file is $imageFile');
              instance.addMedicineToFirebase(medicineName, dosage, timeFields,
                  instance, imageFile, widget.may);
            //  progressNotifier.update();
              Navigator.of(context).pop();
            }),
            // TextButton(
            //   child: Text('Add'),
            //   onPressed: () {
            //     String medicineName = medicineNameController.text.toString();
            //     String dosage = dosageController.text.toString();
            //     //DateTime time = DateFormat.jm().parse(_timeController.text);
            //     instance.addMedicineToFirebase(
            //         medicineName, dosage, timeFields, instance);
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> AddPicture(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Photo Library'),
                    onTap: () async {
                      pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Camera'),
                    onTap: () async {
                      pickedFile =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile == null) {
                        print('No image selected.');
                        return;
                      } else {
                        print("fine");
                      }
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class MedicinePageScreen extends StatefulWidget {
  @override
  _MedicinePageScreenState createState() => _MedicinePageScreenState();
}

class _MedicinePageScreenState extends State<MedicinePageScreen> {
  bool delete_mode = false;
  late Future<List<MedicineCard>> medicines;
  // List<MedicineCard> medicine_lis=[];
  @override
  @override
  Widget build(BuildContext context) {
    FirebaseService instance = Provider.of<FirebaseService>(context);
    BuildContext may = context;
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 250, 250, 250).withOpacity(0.99),
        appBar: AppBar(
          title: Text('Medicine Schedule',
              style: TextStyle(
                color: Color(0xff0040a9),
                fontWeight: FontWeight.bold,
              )),
          bottom: TabBar(
            indicatorColor: Color(0xff0040a9),
            labelColor: Color(0xff0040a9),
            unselectedLabelColor: Color(0xff0040a9).withOpacity(0.5),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                  child: Text('Sun',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Mon',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Tue',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Wed',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Thu',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Fri',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
              Tab(
                  child: Text('Sat',
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.024))),
            ],
          ),
        ),
        body: Consumer<FirebaseService>(
          builder: (context, FirebaseService, child) {
            return FutureBuilder(
              future: instance.getMedicineSchedule(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<MedicineCard>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading bar if the Future is still loading
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 5.0,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Show the rest of your page if the Future has completed

                  Map<String, List<MedicineCard>> weeklySchedule = {
                    'Monday': [],
                    'Tuesday': [],
                    'Wednesday': [],
                    'Thursday': [],
                    'Friday': [],
                    'Saturday': [],
                    'Sunday': [],
                  };

                  if (snapshot.data != null) {
                    for (var medicine in snapshot.data!) {
                      if (!medicine.times.isEmpty) {
                        for (var entry in medicine.times.entries) {
                          List<MedicineCard> medicineCards =
                              entry.value.map((time) {
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
                  }
                  return TabBarView(
                    children: [
                      SundayTab(weeklySchedule['Sunday']),
                      MondayTab(weeklySchedule['Monday']),
                      TuesdayTab(weeklySchedule['Tuesday']),
                      WednesdayTab(weeklySchedule['Wednesday']),
                      ThursdayTab(weeklySchedule['Thursday']),
                      FridayTab(weeklySchedule['Friday']),
                      SaturdayTab(weeklySchedule['Saturday']),
                    ],
                  );
                }
              },
            );
          },
        ),
        floatingActionButton: Container(
          height: 70,
          width: 70,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddMedicineDialog(may);
                },
              );
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Color(0xffcb1522),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(50.0), // The border radius of the FAB
              ),
            ),
            // Replace with your icon
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget ShowList(List<MedicineCard>? medicine_lis, String day) {
    if (medicine_lis == null || medicine_lis.isEmpty) {
      return Center(child: Text('No medicines for ' + day));
    } else {
      return ListView.builder(
        itemCount: medicine_lis.length,
        itemBuilder: (context, index) {
          return oneRow(medicine_lis[index], context);
        },
      );
    }
  }

  Widget SundayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Sunday");
    //return Text('Sunday');
  }

  Widget MondayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Monday");
  }

  Widget TuesdayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Tuesday");
  }

  Widget WednesdayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Wednesday");
  }

  Widget ThursdayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Thursday");
  }

  Widget FridayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Friday");
  }

  Widget SaturdayTab(List<MedicineCard>? medicines) {
    return ShowList(medicines, "Saturday");
  }

  Widget oneRow(MedicineCard medicineCard1, BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: MediaQuery.of(context).size.width * 0.3,
              child: Column(
                children: [
                  _buildCard(medicineCard1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(MedicineCard medicineCard) {
    return Expanded(
      child: Card(
        surfaceTintColor: Colors.white,
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.white,
            child: CardInfo(medicineCard),
          ),
        ),
      ),
    );
  }

  Widget CardInfo(MedicineCard medicineCard) {
    return Stack(children: <Widget>[
      Container(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: medicineCard.image.isEmpty
                  ? Image.asset("lib/images/defaultmedicine.jpg",
                      fit: BoxFit.fill)
                  : Image.network(medicineCard.image, fit: BoxFit.fill),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        SizedBox(width: 5),
                        Icon(Icons.medication,
                            color: Color(0xffcb1522), size: 20),
                        SizedBox(width: 5),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Text(
                              medicineCard.medicine_name,
                              style: TextStyle(
                                color: Color(0xff0040a9),
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxHeight * 0.7,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Text(
                              medicineCard.times['0']?.first ?? 'No Time',
                              style: TextStyle(
                                color: Color(0xff0040a9),
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxHeight * 0.5,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
        right: 10,
        top: 10,
        child: IconButton(
          icon: Icon(Icons.more_vert, size: 24.0, color: Color(0xff0040a9)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return MedicineAlertDialog(medicineCard: medicineCard);
              },
            );
          },
        ),
      )
    ]);
  }
}

Map<String, List<MedicineCard>> getWeeklySchedule(
    List<MedicineCard>? snapshot) {
  Map<String, List<MedicineCard>> weeklySchedule = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  if (snapshot != null) {
    for (var medicine in snapshot!) {
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
  }
  print("weeeeek1" + weeklySchedule.toString());
  return weeklySchedule;
}
