import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
Future<bool> isConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true; // I am connected to a mobile network.
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true; // I am connected to a wifi network.
  }
  return false; // No internet connection
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('No Internet Connection'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No Internet Connection',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Image.asset('lib/images/nointernet.jpg'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  String? _currentRoute = '/';

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        // I am connected to a mobile network.
        if (_currentRoute == '/noInternet' && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          //_currentRoute = '/';
        }
        _currentRoute = '/';
        debugPrint("Connected to the internet");
      } else {
        Navigator.of(context).pushNamed('/noInternet');
        _currentRoute = '/noInternet';
        // No internet connection
        debugPrint("No internet connection");
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
 _launchURL() async {
    const url = 'https://gist.github.com/yasmin-ir/cf28a25d829bb79d29ae8def554f835b';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Home'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'PetBud',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 20), // Reduce spacing
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login_parent');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('images/parents.png'),
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Reduce spacing
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/login_child');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: AssetImage('images/children.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              child: Text('Privacy Policy'),
              onPressed: _launchURL,
            ), // Add some spacing
          ],
        ),
      ),
    );
  }
}
