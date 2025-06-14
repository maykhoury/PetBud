import 'package:flutter/material.dart';
import 'firebase_services.dart';
import 'package:provider/provider.dart';

double circular_number = 15;

class LoginChildScreen extends StatefulWidget {
  @override
  _LoginChildScreenState createState() => _LoginChildScreenState();
}

class _LoginChildScreenState extends State<LoginChildScreen> {
  static const int theme_color = 0xFF0040A9;
  final _formKey = GlobalKey<FormState>();
  String username = '', password = '';
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
          // title: const DefaultTextStyle(
          //   style: TextStyle(color: Colors.white), // Set text color to white
          //   child: Text('Child Login'),
          // ),
          // backgroundColor: Theme.of(context)
          //     .primaryColor, // Set AppBar color to match theme's primary color
          ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("images/room_bg.png"), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            // container
            padding: EdgeInsets.only(top: 50),
            child: Container(
              width: screenWidth / 1.3, // Set the width of the Card
              child: Card(
                color: Colors.white, // Set card color to white
                elevation: 5, // Add shadow to the card
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    // Add this
                    child: Consumer<FirebaseService>(
                      builder: (context, firebaseService, child) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize
                                .min, // Limit the height of the Column
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'images/rabbit_flow.png', // Replace with your image
                                width: 100,
                                height: 100,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Color(theme_color)), // Corrected here
                              ),
                              const SizedBox(height: 20), // Add space
                              TextFormField(
                                controller: usernameController,
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
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color(theme_color),
                                  ),
                                  labelText: 'Child Username',
                                  labelStyle:
                                      TextStyle(color: Color(theme_color)),
                                  hintText: 'Enter username',
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Color(theme_color)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter username';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
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
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(theme_color),
                                  ),
                                  labelText: 'Child Password',
                                  labelStyle:
                                      TextStyle(color: Color(theme_color)),
                                  hintText: 'Enter password',
                                  hintStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              if (firebaseService.status ==
                                  Status.Authenticating)
                                CircularProgressIndicator()
                              else
                                ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(theme_color)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            circular_number),
                                      ),
                                    ),
                                  ),
                                  child: Text('Login',
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () async {
                                    if (!_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Please fill all fields correctly"),
                                        ),
                                      );
                                    } else {
                                      // Handle login
                                      username = usernameController.text;
                                      password = passwordController.text;
                                      try {
                                        await firebaseService.loginChild(
                                            username, password);
                                        // Navigate to another screen or update the state
                                        Navigator.pushNamed(
                                            context, '/bedroom_screen');
                                      } catch (e) {
                                        print(e);
                                        if(e == 'The account has been successfully deleted.')
                                        {
                                           ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                e.toString()),
                                          ),
                                        );
                                        }
                                        // Handle the error
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                firebaseService.errorMessage),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
