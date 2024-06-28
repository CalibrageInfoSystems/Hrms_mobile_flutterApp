import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/Notifications_screen.dart';
import 'package:hrms/SharedPreferencesHelper.dart';
import 'package:hrms/personal_details.dart';
import 'package:hrms/projects_screen.dart';

import 'Constants.dart';

import 'Myleaveslist.dart';
import 'Resginaton_request.dart';
import 'feedback_Screen.dart';
import 'leaves_screen.dart';
import 'main.dart';

// const CURVE_HEIGHT = 320.0;
// const AVATAR_RADIUS = CURVE_HEIGHT * 0.23;
// const AVATAR_DIAMETER = AVATAR_RADIUS * 2.5;

class home_screen extends StatefulWidget {
  const home_screen({super.key});

  @override
  _home_screenState createState() => _home_screenState();
}

class _home_screenState extends State<home_screen>
    with SingleTickerProviderStateMixin {
  int currentTab = 0;
  bool islogin = false;
  final FocusNode _projectsFocusNode = FocusNode();
  final FocusNode _leavesFocusNode = FocusNode();
  static const primaryColor = Color(0xFFf15f22);

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;
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
    return WillPopScope(
        onWillPop: () async {
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => personal_details()),
          // ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: primaryColor,
                title: const Text(
                  'HRMS',
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                actions: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Notifications()),
                      );
                    },
                    child: const Icon(
                      Icons.notification_important,
                      //  size: 15.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 15.0,
                  )
                ],
              ),
              drawer: Drawer(
                width: 260.0,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DrawerHeader(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 184, 55, 0),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/cislogo-new.svg',
                        width: 80,
                        height: 100,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: SvgPicture.asset(
                              'assets/atten.svg',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: primaryColor,
                            ),
                            title: const Text(
                              'My Leaves',
                              style: TextStyle(
                                // color: Colors.black,
                                color: primaryColor,
                                fontFamily: 'hind_semibold',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Myleaveslist()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.notification_important,
                              // color: Colors.black,
                              color: primaryColor,
                              weight: 20,
                            ),
                            title: const Text(
                              'Notifications',
                              style: TextStyle(
                                // color: Colors.black,
                                color: primaryColor,
                                fontFamily: 'hind_semibold',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Notifications()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.copy,
                              color: primaryColor,
                              weight: 20,
                            ),
                            title: const Text(
                              'Resignation Request',
                              style: TextStyle(
                                // color: Colors.black,
                                color: primaryColor,
                                fontFamily: 'hind_semibold',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Resgination_req()),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.star,
                              color: primaryColor,
                            ),
                            title: const Text(
                              'Feedback',
                              style: TextStyle(
                                // color: Colors.black,

                                color: primaryColor,
                                fontFamily: 'hind_semibold',
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const feedback_Screen()),
                              );
                              // Handle the onTap action for Logout
                            },
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: primaryColor,
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          // color: Colors.black,
                          color: primaryColor,
                          fontFamily: 'hind_semibold',
                        ),
                      ),
                      onTap: () {
                        logOutDialog();
                      },
                    ),
                  ],
                ),
              ),
              body: _buildBody(),
              floatingActionButton: FloatingActionButton(
                elevation: 0,
                onPressed: () {
                  setState(() {
                    currentTab = 0;
                  });
                },
                backgroundColor: const Color(
                    0xFFf15f22), // Set the background color to orange
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      color: Colors.white,
                      width: 3.0), // Set border color and width
                  borderRadius:
                      BorderRadius.circular(60), // Adjust the radius as needed
                ),
                //   mini: true,
                child: Image.asset(
                  'assets/user_1.png',
                  width: 18,
                  height: 23,
                  color: Colors.white,
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                height: 58,
                shape: const CircularNotchedRectangle(),
                padding: const EdgeInsets.only(bottom: 10.0),
                notchMargin: currentTab == 0 ? 8 : 0,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                currentTab = 1;
                              });
                              _projectsFocusNode.requestFocus();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3 / 1,
                              //    padding: EdgeInsets.only(left: 25.0),
                              margin: const EdgeInsets.only(left: 25.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentTab = 1;
                                  });
                                  _projectsFocusNode.requestFocus();
                                },
                                // child: Container(
                                // width: MediaQuery.of(context).size.width,

                                child: Focus(
                                    focusNode: _projectsFocusNode,
                                    child: Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              currentTab = 1;
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: SvgPicture.asset(
                                                  'assets/2560114.svg', // Replace with the actual path to your SVG icon
                                                  height:
                                                      20, // Adjust the height as needed
                                                  width:
                                                      20, // Adjust the width as needed
                                                  color: primaryColor,
                                                ),
                                              ),
                                              const Text(
                                                "Projects",
                                                style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Calibri'),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3 /
                                              1,
                                          height: 4,
                                          child: Container(
                                            color: currentTab == 1
                                                ? primaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    )),
                                // ),
                              ),
                            )),

                        // SizedBox(width: 10.0),
                        InkWell(
                          onTap: () {
                            setState(() {
                              currentTab = 2;
                            });
                            _leavesFocusNode.requestFocus();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.7 / 1,
                            padding: const EdgeInsets.only(right: 15.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentTab = 2;
                                });
                                _leavesFocusNode.requestFocus();
                              },
                              child: Container(
                                // padding: EdgeInsets.only(right: 20.0),
                                child: Focus(
                                    focusNode: _leavesFocusNode,
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.all(13.0),
                                              child: SvgPicture.asset(
                                                'assets/leave_8.svg', // Replace with the actual path to your SVG icon
                                                height:
                                                    22, // Adjust the height as needed
                                                width:
                                                    20, // Adjust the width as needed
                                                color: primaryColor,
                                              ),
                                            ),
                                            const Text(
                                              "Leaves",
                                              style: TextStyle(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri'),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5 /
                                              1,
                                          height: 4,
                                          child: Container(
                                            color: currentTab == 2
                                                ? primaryColor
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _buildBody() {
    switch (currentTab) {
      case 0:
        return const personal_details();
      case 1:
        return const projects_screen();
      case 2:
        return const leaves_screen();

      default:
        return const home_screen();
      //return Container();
    }
  }

  void logOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are You Sure You Want to Logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirmLogout(); // Perform logout action
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void onConfirmLogout() {
    SharedPreferencesHelper.putBool(Constants.IS_LOGIN, false);
    Commonutils.showCustomToastMessageLong(
        "Logout Successfully", context, 0, 3);
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => LoginPage()));

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
