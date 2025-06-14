import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const int theme_color = 0xFF0040A9;
double circular_number = 15;

class MedicalInfoPage extends StatefulWidget {
  @override
  _MedicalInfoPageState createState() => _MedicalInfoPageState();
}

class _MedicalInfoPageState extends State<MedicalInfoPage> {
  int _currentStep = 0;
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
  Set<String> _selectedSymptoms = {};

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not found!");
      throw Exception('User is null');
    }
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    setState(() {
      _childName = data['childName'] ?? '';
      _birthdate = (data['birthdate'] as Timestamp?)?.toDate();
      _gender = data['gender'] ?? '';
      _weight = data['weight']?['value'] ?? '';
      _height = data['height']?['value'] ?? '';
      _weightMetric = data['weight']?['metric'] ?? 'lb';
      _heightMetric = data['height']?['metric'] ?? 'ft';
      _diabetesType = data['medicalDetails']?['diabetesType'] ?? '';
      _physicianName = data['medicalDetails']?['physicianName'] ?? '';
      _hospitalName = data['medicalDetails']?['hospitalName'] ?? '';
      _selectedSymptoms =
          Set<String>.from(data['medicalDetails']?['symptoms'] ?? []);
    });
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
        symptoms: _selectedSymptoms,
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
    return Scaffold(
      appBar: AppBar(
        // leading: const BackButton(color: Color(theme_color)), // This adds the back button
        title: const Text('Child Details',
            style: TextStyle(color: Color(theme_color))),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder:
                  (BuildContext context, ControlsDetails controlsDetails) {
                // Empty Container to remove the default buttons
                return Container();
              },
              steps: [
                Step(
                  title: const Text('General',
                      style: TextStyle(color: Color(theme_color))),
                  content: _buildStepContent(1),
                ),
                Step(
                  title: const Text('Medical',
                      style: TextStyle(color: Color(theme_color))),
                  content: _buildStepContent(2),
                ),
                Step(
                  title: const Text('Symptoms',
                      style: TextStyle(color: Color(theme_color))),
                  content: _buildStepContent(3),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                  backgroundColor: Color(theme_color), // button color
                ),
                onPressed: _currentStep > 0
                    ? () => setState(() => _currentStep -= 1)
                    : null,
                child: Icon(Icons.arrow_back,
                    size: 50, color: Colors.white), // icon color
              ),
              if (_currentStep < 2)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(15),
                    backgroundColor: Color(theme_color), // button color
                  ),
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
                              throw Exception('Invalid step: $_currentStep');
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
                  child: Icon(Icons.arrow_forward,
                      size: 50, color: Colors.white), // icon color
                )
              else
                ElevatedButton(
                  onPressed: () {
                    if (!_formKey1.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Please fill all the fields correctly')),
                      );
                    } else {
                      _updateFunction(); // Call your update function
                      Navigator.pushNamed(context,
                          '/parent_home_page'); // Navigate to the settings page
                    }
                  },
                  child: Text('Save Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(theme_color), // background
                    foregroundColor: Colors.white, // foreground
                  ),
                ),
            ],
          ),
        ],
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
          TextFormField(
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
          Text('Gender',
              style: TextStyle(
                  color: Color(theme_color),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Row(
            children: <Widget>[
              Expanded(
                  child: RadioListTile<String>(
                title: const Text('Male'),
                value: 'male',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              )),
              Expanded(
                  child: RadioListTile<String>(
                title: const Text('Female'),
                value: 'female',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              )),
            ],
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.line_weight, color: Color(theme_color)),
              labelText: 'Weight',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter weight',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
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
          CupertinoSlidingSegmentedControl<String>(
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
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(color: Color(theme_color), width: 2.0),
              ),
              prefixIcon: Icon(Icons.height, color: Color(theme_color)),
              labelText: 'Height',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter height',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
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
          CupertinoSlidingSegmentedControl<String>(
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
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
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
