import 'package:flutter/material.dart';
import 'package:petbud/Designs.dart';
import 'package:petbud/signIn/home_screen.dart';
import 'account_settings.dart';
import 'medical_info.dart';
import 'medical_info_update.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  static const int theme_color = 0xFF0040A9;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
  'Settings',
  style: TextStyle(fontSize: 25, color: blueColor, fontWeight: FontWeight.bold),
),
        leading:  BackButton(color: blueColor,), // This adds the back button
        // leading: IconButton(
        //   icon: Icons.arrow_back,
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (context) => HomeScreen()),
        //     );
        //   },
        // ),

        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(theme_color), // Color of the selected tab
          unselectedLabelColor: Colors.grey, // Color of the unselected tabs
          indicatorColor:
              Color(theme_color), // Color of the indicator below the selected tab
          tabs: const [
            Tab(text: 'Account Settings'),
            Tab(text: 'Medical Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AccountSettings(),
          MedicalInfoUpdate(),
        ],
      ),
    );
  }
}
