import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:petbud/settings/customStepper.dart';
import 'package:provider/provider.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const int theme_color = 0xFF0040A9;
double circular_number = 15;

class MedicalInfoUpdate extends StatefulWidget {
  @override
  _MedicalInfoUpdateState createState() => _MedicalInfoUpdateState();
}

class _MedicalInfoUpdateState extends State<MedicalInfoUpdate> {
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _physicianNameController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _childNameController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  bool isTextFound1 = false; //for the check boxes
  bool isTextFound2 = false;
  bool isTextFound3 = false;
  String? _gender;
  String? _childName;
  DateTime? _birthdate;
  String? _weight;
  String? _height;
  String _weightMetric = 'lb';
  String _heightMetric = 'ft';
  String? _diabetesType;
  String? _physicianName;
  String? _hospitalName;
  late List<dynamic> _selectedSymptoms = [];

  late Future<void> _defaultValuesFuture;

  @override
  void initState() {
    super.initState();
    _defaultValuesFuture = _setDefaultValues();
  }

  Future<void> _setDefaultValues() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("User not found!");
      return;
    }

    // Fetch data from Firestore

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      _childNameController.text = data?['childName'] ?? '';
      _birthdate = (data['birthdate'] as Timestamp?)?.toDate();
      _gender = data['gender'] as String?;

      Map<String, dynamic> heightData =
          (data['height'] as Map<String, dynamic>?) ?? {};
      _heightController.text = heightData?['value'] ?? '';
      _heightMetric = heightData?['metric'] ?? 'ft';

      Map<String, dynamic> weightData =
          (data['weight'] as Map<String, dynamic>?) ?? {};
      _weightController.text = weightData?['value'] ?? '';
      _weightMetric = weightData?['metric'] ?? 'lb';

      Map<String, dynamic> medicalDetailsData =
          (data['medicalDetails'] as Map<String, dynamic>?) ?? {};
      _hospitalNameController.text = medicalDetailsData?['hospitalName'] ?? '';
      _physicianNameController.text = medicalDetailsData['physicianName'] ?? '';

      // Fetch and set diabetes type
      _diabetesType = medicalDetailsData['diabetesType'] as String?;

      // Get the symptoms list
      List<dynamic> symptomsData =
          medicalDetailsData['symptoms'] as List<dynamic>;

      // Fetch and set symptoms
      _selectedSymptoms = symptomsData;
    }
  }

  @override
  void dispose() {
    _childNameController.dispose();
    _birthdateController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _hospitalNameController.dispose();
    _physicianNameController.dispose();
    super.dispose();
  }

  Future<void> _updateFunction() async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .updateUserMedicalData(
        childName: _childName,
        birthdate: _birthdate,
        gender: _gender,
        weight: _weight,
        height: _height,
        weightMetric: _weightMetric,
        heightMetric: _heightMetric,
        diabetesType: _diabetesType,
        physicianName: _physicianName,
        hospitalName: _hospitalName,
        symptoms: Set<String>.from(_selectedSymptoms ?? []),
      );
    } catch (e) {
      print('Failed to update user medical data: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: screenWidth,
          child: Card(
            color: Colors.white,
            elevation: 2,
            child: Column(
              children: [
                Expanded(
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: _currentStep,
                    onStepTapped: (step) => setState(() => _currentStep = step),
                    controlsBuilder: (BuildContext context,
                        ControlsDetails controlsDetails) {
                      return Container();
                    },
                    steps: [
                      Step(
                        title: _currentStep == 0
                            ? Icon(Icons.check, color: Color(theme_color))
                            : IconTheme(
                                data: IconThemeData(color: Color(theme_color)),
                                child: const Text('General',
                                    style:
                                        TextStyle(color: Color(theme_color))),
                              ),
                        content: FutureBuilder(
                          future: _defaultValuesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                      strokeWidth: 5.0,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return _buildStepContent(1);
                            }
                          },
                        ),
                      ),
                      Step(
                        title: _currentStep == 1
                            ? Icon(Icons.check, color: Color(theme_color))
                            : IconTheme(
                                data: IconThemeData(color: Color(theme_color)),
                                child: const Text('Medical',
                                    style:
                                        TextStyle(color: Color(theme_color))),
                              ),
                        content: FutureBuilder(
                          future: _defaultValuesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                      strokeWidth: 5.0,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return _buildStepContent(2);
                            }
                          },
                        ),
                      ),
                      Step(
                        title: _currentStep == 2
                            ? Icon(Icons.check, color: Color(theme_color))
                            : IconTheme(
                                data: IconThemeData(color: Color(theme_color)),
                                child: const Text('Symptoms',
                                    style:
                                        TextStyle(color: Color(theme_color))),
                              ),
                        content: FutureBuilder(
                          future: _defaultValuesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blue),
                                      strokeWidth: 5.0,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return _buildStepContent(3);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      iconSize: 50,
                      padding: EdgeInsets.all(15),
                      color: Color(theme_color),
                      onPressed: _currentStep > 0
                          ? () => setState(() => _currentStep -= 1)
                          : null,
                      icon: Icon(Icons.arrow_back, size: 40.0),
                    ),
                    if (_currentStep < 2)
                      IconButton(
                        iconSize: 50,
                        padding: EdgeInsets.all(15),
                        color: Color(theme_color),
                        onPressed: _currentStep < 2
                            ? () {
                                GlobalKey<FormState> currentKey;
                                switch (_currentStep) {
                                  case 0:
                                    currentKey = _formKey1;
                                    break;
                                  case 1:
                                    currentKey = _formKey2;
                                    break;
                                  default:
                                    throw Exception(
                                        'Invalid step: $_currentStep');
                                }
                                if (!currentKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Please fill all the fields correctly')),
                                  );
                                } else {
                                  setState(() => _currentStep += 1);
                                }
                              }
                            : null,
                        icon: Icon(Icons.arrow_forward, size: 40.0),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (!_formKey1.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please fill all the fields correctly')),
                            );
                          } else {
                            _updateFunction();
                            Navigator.pushNamed(context, '/parent_home_page');
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(theme_color)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(circular_number),
                            ),
                          ),
                        ),
                        child: Text('Save Info',
                            style: TextStyle(color: Colors.white)),
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Color(theme_color),
                        //   foregroundColor: Colors.white,
                        // ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 1:
        return _buildStep1Content();
      case 2:
        return _buildStep2Content();
      case 3:
        return _buildStep3Content();
      default:
        throw Exception('Invalid step: $step');
    }
  }

  Widget _buildStep1Content() {
    return Form(
      key: _formKey1,
      child: Column(
        children: <Widget>[
          Text('General Info',
              style: TextStyle(
                  color: Color(theme_color),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          TextFormField(
            controller: _childNameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.person, color: Color(theme_color)),
              labelText: 'Child Name',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter child name',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            onChanged: (value) {
              _childName = value;
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter child name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            //controler?
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.cake, color: Color(theme_color)),
              labelText: 'Birthdate',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter birthdate',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            readOnly: true,
            controller: TextEditingController(
                text: _birthdate != null ? _formatDate(_birthdate!) : ''),
            onTap: () async {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext builder) {
                    return Container(
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        onDateTimeChanged: (DateTime date) {
                          setState(() {
                            _birthdate = date;
                          });
                        },
                        initialDateTime: _birthdate ?? DateTime.now(),
                        minimumYear: 1900,
                        maximumYear: DateTime.now().year,
                      ),
                    );
                  });
            },
            validator: (value) {
              if (_birthdate == null) {
                return 'Please select a birthdate';
              }
              if (_birthdate!.isAfter(DateTime.now())) {
                return 'Birthdate cannot be in the future';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Text(
            'Gender',
            style: TextStyle(
                color: Color(theme_color),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          Row(
            children: <Widget>[
              Flexible(
                flex: 2,
                child: Transform.translate(
                  offset: Offset(-16, 0),
                  child: Center(
                    // Add this
                    child: RadioListTile<String>(
                      selectedTileColor: (Color(theme_color)),
                      title: const Text('Male',
                          style: TextStyle(color: Color(theme_color))),
                      value: 'male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Transform.translate(
                  offset: Offset(-30, 0),
                  child: Center(
                    // Add this
                    child: RadioListTile<String>(
                      selectedTileColor: (Color(theme_color)),
                      title: const Text('Female',
                          style: TextStyle(color: Color(theme_color))),
                      value: 'female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(circular_number),
                      borderSide:
                          BorderSide(color: Color(theme_color), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(circular_number),
                      borderSide:
                          BorderSide(color: Color(theme_color), width: 2.0),
                    ),
                    prefixIcon:
                        Icon(Icons.line_weight, color: Color(theme_color)),
                    labelText: 'Weight',
                    labelStyle: TextStyle(color: Color(theme_color)),
                    hintText: 'Enter weight',
                    hintStyle:
                        TextStyle(fontSize: 12, color: Color(theme_color)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _weight = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight';
                    }
                    double? weight = double.tryParse(value);
                    if (weight == null) {
                      return 'Please enter a valid number';
                    }
                    if (weight <= 0 || weight > 1000) {
                      return 'Please enter a reasonable weight';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10), // Add this
              Expanded(
                flex: 1,
                child: CupertinoSlidingSegmentedControl<String>(
                  children: {
                    'lb': Text('lb'),
                    'kg': Text('kg'),
                  },
                  groupValue: _weightMetric,
                  onValueChanged: (value) {
                    setState(() {
                      _weightMetric = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(circular_number),
                      borderSide:
                          BorderSide(color: Color(theme_color), width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(circular_number),
                      borderSide:
                          BorderSide(color: Color(theme_color), width: 2.0),
                    ),
                    prefixIcon: Icon(Icons.height, color: Color(theme_color)),
                    labelText: 'Height',
                    labelStyle: TextStyle(color: Color(theme_color)),
                    hintText: 'Enter height',
                    hintStyle:
                        TextStyle(fontSize: 12, color: Color(theme_color)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _height = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter height';
                    }
                    double? height = double.tryParse(value);
                    if (height == null) {
                      return 'Please enter a valid number';
                    }
                    if (height <= 0 || height > 300) {
                      return 'Please enter a reasonable height';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 10), // Add this
              Expanded(
                flex: 1,
                child: CupertinoSlidingSegmentedControl<String>(
                  children: {
                    'ft': Text('ft'),
                    'cm': Text('cm'),
                  },
                  groupValue: _heightMetric,
                  onValueChanged: (value) {
                    setState(() {
                      _heightMetric = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Content() {
    return Form(
      key: _formKey2,
      child: Column(
        children: <Widget>[
          Text('Medical Info',
              style: TextStyle(
                  color: Color(theme_color),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              labelText: 'Type of Diabetes',
              labelStyle: TextStyle(color: Color(theme_color)),
            ),
            value: _diabetesType,
            items: <String>['Type 1', 'Type 2']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _diabetesType = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a type of diabetes';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _physicianNameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.person, color: Color(theme_color)),
              labelText: 'Physician Name',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter physician name',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            onChanged: (value) {
              setState(() {
                _physicianName = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter physician name';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _hospitalNameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.local_hospital, color: Color(theme_color)),
              labelText: 'Hospital',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter hospital',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            onChanged: (value) {
              setState(() {
                _hospitalName = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter hospital name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Content() {
    final symptoms = [
      'Increased thirst',
      'Unexplained weight loss',
      'Fatigue',
      // Add more symptoms here...
    ];

    return Column(
      children: <Widget>[
        Text('Diabetes Symptoms',
            style: TextStyle(
                color: Color(theme_color),
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('Choose the symptoms that are relevant to your child:',
            style: TextStyle(color: Color(theme_color), fontSize: 18)),
        SizedBox(height: 10),
        ...symptoms
            .map((symptom) => Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(circular_number),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(symptom,
                        style:
                            TextStyle(color: Color(theme_color), fontSize: 16)),
                    subtitle: Text('description',
                        style:
                            TextStyle(color: Color(theme_color), fontSize: 14)),
                    leading: Checkbox(
                      value: _selectedSymptoms.contains(symptom),
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true) {
                            _selectedSymptoms.add(symptom);
                          } else {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
