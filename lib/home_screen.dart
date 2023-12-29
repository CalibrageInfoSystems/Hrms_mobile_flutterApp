import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/projects_screen.dart';

import 'Constants.dart';
import 'Myleaveslist.dart';
import 'leaves_screen.dart';
import 'main.dart';

// const CURVE_HEIGHT = 320.0;
// const AVATAR_RADIUS = CURVE_HEIGHT * 0.23;
// const AVATAR_DIAMETER = AVATAR_RADIUS * 2.5;

class home_screen extends StatefulWidget {
  @override
  _home_screenState createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  int currentTab = 0;
  bool islogin = false;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
      } else {
        print('The Internet Is not  Connected');
      }
    });
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFf15f22),
            title: Text(
              'HRMS',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                      // Remove the DecorationImage with AssetImage
                      ),
                  child: SvgPicture.asset(
                    'assets/cislogo-new.svg', // Replace with the path to your SVG icon
                    width: 80, // Adjust the width as needed
                    height: 100, // Adjust the height as needed
                  ),
                ),

                ListTile(
                  leading: SvgPicture.asset(
                    'assets/atten.svg',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    color: Colors.black,
                  ),
                  title: Text(
                    'My Leaves',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'hind_semibold',
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Myleaveslist()),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(Icons.logout), // Change the icon as needed
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'hind_semibold',
                    ),
                  ),
                  onTap: () {
                    logOutDialog();
                    // Handle the onTap action for Logout
                  },
                ),
                // Add more ListTiles or other widgets as needed
              ],
            ),
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            elevation: 0,
            //   mini: true,
            child: Image.asset(
              'assets/user_1.png',
              width: 18,
              height: 23,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                currentTab = 0;
              });
            },
            backgroundColor:
                Color(0xFFf15f22), // Set the background color to orange
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.white,
                  width: 3.0), // Set border color and width
              borderRadius:
                  BorderRadius.circular(60), // Adjust the radius as needed
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            height: 58,
            shape: CircularNotchedRectangle(),
            padding: EdgeInsets.only(bottom: 10.0),
            notchMargin: currentTab == 0 ? 8 : 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTab = 1;
                        });
                      },
                      // child: Container(
                      // width: MediaQuery.of(context).size.width,

                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentTab = 1;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(14.0),
                                  child: SvgPicture.asset(
                                    'assets/2560114.svg', // Replace with the actual path to your SVG icon
                                    height: 20, // Adjust the height as needed
                                    width: 20, // Adjust the width as needed
                                    color: Color(0xFFf15f22),
                                  ),
                                ),
                                const Text(
                                  "Projects",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 15,
                            width: 90,
                            height: 4,
                            child: Container(
                              color: currentTab == 1
                                  ? Color(0xFFf15f22)
                                  : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                      // ),
                    ),
                    SizedBox(width: 15.0),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTab = 2;
                        });
                      },
                      child: Container(
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(13.0),
                                  child: SvgPicture.asset(
                                    'assets/leave_8.svg', // Replace with the actual path to your SVG icon
                                    height: 22, // Adjust the height as needed
                                    width: 20, // Adjust the width as needed
                                    color: Color(0xFFf15f22),
                                  ),
                                ),
                                const Text(
                                  "Leaves",
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri'),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              left: 15,
                              width: 90,
                              height: 4,
                              child: Container(
                                color: currentTab == 2
                                    ? Color(0xFFf15f22)
                                    : Colors.transparent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildBody() {
    switch (currentTab) {
      case 0:
        return personal_details();
      case 1:
        return projects_screen();
      case 2:
        return leaves_screen();

      default:
        return home_screen();
      //return Container();
    }
  }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirmLogout(); // Perform logout action
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void onConfirmLogout() {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong("Logout Successful", context, 0, 3);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}
