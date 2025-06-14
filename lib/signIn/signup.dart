import 'package:flutter/material.dart';
import 'firebase_services.dart';
import 'package:provider/provider.dart';

double circular_number = 15;

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const int theme_color = 0xFF0040A9;
    return Scaffold(
      // appBar: AppBar(
      //   title: const DefaultTextStyle(
      //     style: TextStyle(color: Colors.white),
      //     child: Text('Sign Up',  color: Color(theme_color)),
      //   ),
      //   backgroundColor: Theme.of(context).primaryColor,
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/room_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Container(
              width: screenWidth / 1.15,
              child: Card(
                color: Colors.white,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: SignUpForm(),
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

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _parentDetailsKey = GlobalKey<FormState>();
  final _childDetailsKey = GlobalKey<FormState>();
  int _formIndex = 0;

  // Create references to the states
  final _parentDetailsFormState = _ParentDetailsFormState();
  final _childDetailsFormState = _ChildDetailsFormState();

  @override
  Widget build(BuildContext context) {
    const int theme_color = 0xFF0040A9;
    String parentEmail = '',
        parentPassword = '',
        childEmail = '',
        childUsername = '',
        childPassword = '';
    return Consumer<FirebaseService>(
      builder: (context, firebaseService, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Image.asset(
                'images/rabbit_flow.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(theme_color)),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    child: Text('Parent Details',
                        style: TextStyle(color: Color(theme_color))),
                    onPressed: () {
                      setState(() {
                        _formIndex = 0;
                      });
                    },
                  ),
                  Text('/', style: TextStyle(color: Color(theme_color))),
                  TextButton(
                    child: Text('Child Details',
                        style: TextStyle(color: Color(theme_color))),
                    onPressed: () {
                      setState(() {
                        _formIndex = 1;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              IndexedStack(
                index: _formIndex,
                children: <Widget>[
                  ParentDetailsForm(_parentDetailsFormState, _parentDetailsKey),
                  ChildDetailsForm(_childDetailsFormState, _childDetailsKey),
                ],
              ),
              const SizedBox(height: 20),
              TextButton(
                child: Text("Already have an account? Login here",
                    style: TextStyle(color: Color(theme_color))),
                onPressed: () {
                  // Navigate to sign up screen
                  Navigator.pushNamed(context, '/login_parent');
                },
              ),
              if (_formIndex == 0)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(theme_color)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(circular_number),
                      ),
                    ),
                  ),
                  child: Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: () {
                    if (!_parentDetailsKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all fields correctly"),
                        ),
                      );
                    } else {
                      setState(() {
                        _formIndex = 1;
                      });
                    }
                  },
                )
              else if (firebaseService.status == Status.Authenticating)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Color(theme_color)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(circular_number),
                      ),
                    ),
                  ),
                  child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    // Handle Sign Up
                    if (!_childDetailsKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please fill all fields correctly"),
                        ),
                      );
                    } else {
                      parentEmail =
                          _parentDetailsFormState._emailController.text;
                      parentPassword =
                          _parentDetailsFormState._passwordController.text;
                      childEmail = _childDetailsFormState._emailController.text;
                      childUsername =
                          _childDetailsFormState._usernameController.text;
                      childPassword =
                          _childDetailsFormState._passwordController.text;

                      try {
                        await firebaseService.signUpParent(
                            parentEmail,
                            parentPassword,
                            childEmail,
                            childUsername,
                            childPassword,
                            context);
                            
                        // Navigate to another screen or update the state
                        Navigator.pushNamed(context, '/medical_info');
                        debugPrint('Supposed to have changed screen???');
                      } catch (e) {
                        print(e);

                        // Handle the error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(firebaseService.errorMessage),
                          ),
                        );
                        throw e;
                      }
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class ParentDetailsForm extends StatefulWidget {
  final _ParentDetailsFormState parentDetailsFormState;
  final GlobalKey<FormState> formKey;

  ParentDetailsForm(this.parentDetailsFormState, this.formKey);

  @override
  _ParentDetailsFormState createState() => parentDetailsFormState;
}

class _ParentDetailsFormState extends State<ParentDetailsForm> {
  static const int theme_color = 0xFF0040A9;
  String parentEmail = '', parentPassword = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide:
                    const BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(
                    color: Color(theme_color),
                    width: 2.0), // Change this to your desired color
              ),
              prefixIcon: Icon(Icons.mail, color: Color(theme_color)),
              labelText: 'Parent Email',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter your email',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
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
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide:
                    const BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(
                    color: Color(theme_color),
                    width: 2.0), // Change this to your desired color
              ),
              prefixIcon: Icon(Icons.lock, color: Color(theme_color)),
              labelText: 'Parent Password',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter your password',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ChildDetailsForm extends StatefulWidget {
  final _ChildDetailsFormState childDetailsFormState;
  final GlobalKey<FormState> formKey;

  ChildDetailsForm(this.childDetailsFormState, this.formKey);

  @override
  _ChildDetailsFormState createState() => childDetailsFormState;
}

class _ChildDetailsFormState extends State<ChildDetailsForm> {
  static const int theme_color = 0xFF0040A9;
  String childEmail = '', childUsername = '', childPassword = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide:
                    const BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(
                    color: Color(theme_color),
                    width: 2.0), // Change this to your desired color
              ),
              prefixIcon: Icon(Icons.person, color: Color(theme_color)),
              labelText: 'Child Username',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter child username',
              hintStyle: TextStyle(fontSize: 12, color: Color(theme_color)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter child username';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide:
                    const BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(
                    color: Color(theme_color),
                    width: 2.0), // Change this to your desired color
              ),
              prefixIcon: Icon(Icons.mail, color: Color(theme_color)),
              labelText: 'Child Email',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter child email',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter child email';
              }
              String pattern = r'^[^@]+@[^@]+\.[^@]+';
              RegExp regex = RegExp(pattern);
              if (!regex.hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide:
                    const BorderSide(color: Color(theme_color), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(circular_number),
                borderSide: BorderSide(
                    color: Color(theme_color),
                    width: 2.0), // Change this to your desired color
              ),
              prefixIcon: Icon(Icons.lock, color: Color(theme_color)),
              labelText: 'Child Password',
              labelStyle: TextStyle(color: Color(theme_color)),
              hintText: 'Enter child password',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              }
              if(value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
