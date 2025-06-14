import 'package:flutter/material.dart';
import 'firebase_services.dart';
import 'package:provider/provider.dart';

double circular_number = 15;

class LoginParentScreen extends StatefulWidget {
  @override
  _LoginParentScreenState createState() => _LoginParentScreenState();
}

class _LoginParentScreenState extends State<LoginParentScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const int theme_color = 0xFF0040A9;
    return Scaffold(
      appBar: AppBar(
          //   title: const DefaultTextStyle(
          //     style: TextStyle(color: Colors.white), // Set text color to white
          //     child: Text('Parent Login'),
          //   ),
          //   backgroundColor: Theme.of(context)
          //       .primaryColor, // Set AppBar color to match theme's primary color
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
                                    color: Color(theme_color),
                                    fontSize: 24,
                                    fontWeight:
                                        FontWeight.bold), // Corrected here
                              ),
                              const SizedBox(height: 20), // Add space
                              TextFormField(
                                controller: emailController,
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
                                  prefixIcon: Icon(Icons.mail,
                                      color: Color(theme_color)),
                                  labelText: 'Parent Email',
                                  labelStyle:
                                      TextStyle(color: Color(theme_color)),
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Color(theme_color)),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
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
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(theme_color)),
                                  labelText: 'Parent Password',
                                  labelStyle:
                                      TextStyle(color: Color(theme_color)),
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(
                                      fontSize: 12, color: Color(theme_color)),
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
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
                                              "Please enter valid email and password"),
                                        ),
                                      );
                                    } else {
                                      // Handle login
                                      email = emailController.text;
                                      password = passwordController.text;
                                      try {
                                        await firebaseService.loginParent(
                                            email, password);
                                        // Navigate to another screen or update the state
                                        Navigator.pushNamed(
                                            context, '/parent_home_page');
                                      } catch (e) {
                                        print(e);
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
                              TextButton(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Color(theme_color)),
                                    children: <TextSpan>[
                                      TextSpan(text: "Don't have an account? "),
                                      TextSpan(
                                        text: 'Sign up here',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  // Navigate to sign up screen
                                  Navigator.pushNamed(context, '/signup');
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
