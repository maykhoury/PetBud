import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petbud/parent/HomePage.dart';
import 'package:petbud/signIn/firebase_services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

double circular_number = 15;

class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  static const int theme_color = 0xFF0040A9;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childUsernameController = TextEditingController();
  final _childEmailController = TextEditingController();
  final _childPasswordController = TextEditingController();

  String? _email,
      _password,
      _childUsername,
      _childEmail,
      _childPassword,
      _oldChildEmail;

  @override
  void initState() {
    super.initState();
    _setDefaultValues();
  }

  Future<void> _setDefaultValues() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      //await user.reload();
      _emailController.text = user.email ?? '';
      print(user.email);
      // You can't retrieve user password for security reasons
      // _passwordController.text = user.password ?? '';
    }

    // Fetch child's email from Firestore
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (docSnapshot.exists) {
      _childEmailController.text =
          (docSnapshot.data() as Map<String, dynamic>)?['childEmail'] ?? '';
      _oldChildEmail =
          (docSnapshot.data() as Map<String, dynamic>)?['childEmail'] ?? '';
      _childUsernameController.text =
          (docSnapshot.data() as Map<String, dynamic>)?['childUsername'] ?? '';
    }
  }


  Future<void> _updateAccountDetails() async {
    try {
      await Provider.of<FirebaseService>(context, listen: false)
          .UpdateAccountDetails(
              email: _email,
              password: _password,
              childEmail: _childEmail,
              childUsername: _childUsername,
              childPassword: _childPassword,
              oldChildEmail: _oldChildEmail);
    } catch (e) {
      print('Failed to update account\'s settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          //padding: EdgeInsets.only(top: 50),
          child: Container(
            alignment: Alignment.center,
            width: screenWidth / 1.1, // Set the width of the Card
            child: Card(
              color: Colors.white, // Set card color to white
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                // padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Container(
                        //   width: 200,
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(circular_number),
                              borderSide: const BorderSide(
                                  color: Color(theme_color), width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(circular_number),
                              borderSide: BorderSide(
                                  color: Color(theme_color),
                                  width:
                                      2.0), // Change this to your desired color
                            ),
                            prefixIcon:
                                Icon(Icons.email, color: Color(theme_color)),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Color(theme_color)),
                            hintText: 'Enter email',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          String pattern = r'^[^@]+@[^@]+\.[^@]+';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        //  width: 200,
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(circular_number),
                              borderSide: const BorderSide(
                                  color: Color(theme_color), width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(circular_number),
                              borderSide: BorderSide(
                                  color: Color(theme_color),
                                  width:
                                      2.0), // Change this to your desired color
                            ),
                            prefixIcon:
                                Icon(Icons.lock, color: Color(theme_color)),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Color(theme_color)),
                            hintText: 'Enter password',
                            hintStyle: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                      	  width: double.infinity,
			  //hintText: 'Child\'s password',
                        child: ElevatedButton(
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
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Please fill all the fields correctly')),
                            );
                          } else {
                            try {
                              _updateAccountDetails();
                              FirebaseAuth.instance.signOut();
                              Navigator.pushNamed(context, '/');
                            } catch (e) {
                              setState(() {
                                _setDefaultValues();
                              });
                              print(e);
                            }
			   }
                          },
                          child: Text('Update Account Details',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.amber[700]),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(circular_number),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              Map<Permission, PermissionStatus> statuses =
                                  await [
                                Permission.camera,
                                Permission.photos,
                                Permission.notification,
                                Permission.reminders,
                              ].request();
                              bool allPermissionsGranted = statuses.values
                                  .every((status) => status.isGranted);

                              if (allPermissionsGranted) {
                                print("granted!");
                                // all permissions granted
                              } else {
                                print("elseeee");
                                  // one or more permissions denied, handle accordingly
  statuses.forEach((permission, status) {
    if (!status.isGranted) {
      print('${permission.toString()} permission denied');
    }
  });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Permission Denied'),
                                      content: Text('One or more permissions have been denied. You can enable them in the app settings.'),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Open Settings'),
                                          onPressed: () {
                                            openAppSettings();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } catch (e) {
                              print("ERRORRRRR");
                              print(e);
                            }
                          },
                          child: Text('Allow permissions',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        // width: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(circular_number),
                              ),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Account'),
                                  content: Text(
                                      'Are you sure you want to delete your account?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('NO'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('YES'),
                                      onPressed: () async {
                                        await Provider.of<FirebaseService>(
                                                context,
                                                listen: false)
                                            .deleteUserAndMarkChildAsDeleted(
                                                context);
                                        // Navigate to home screen
                                        Navigator.pushReplacementNamed(
                                            context, '/');
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Delete Account',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
