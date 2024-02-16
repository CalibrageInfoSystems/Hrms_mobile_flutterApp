import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hrms/leave_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Model Class/LookupDetail.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'apply_leave.dart';
import 'home_screen.dart';

class leaves_screen extends StatefulWidget {
  @override
  _leaves_screen_screenState createState() => _leaves_screen_screenState();
}

class _leaves_screen_screenState extends State<leaves_screen> {
  int currentTab = 0;
  DateTime _selectedMonthPL = DateTime.now();
  DateTime _selectedMonthCL = DateTime.now();
  DateTime _selectedMonthlwp = DateTime.now();
  double usedPrivilegeLeavesInYear = 0.0;
  double allottedPrivilegeLeaves = 0.0;
  double noOfleavesinPLs = 0.0;
  double noOfleavesinCLs = 0.0;
  double noOfleavesinLWP = 0.0;
  double usedCasualLeavesInMonth = 0.0;
  String EmployeName = '';
  int employeid = 0;
  double allottedPriviegeLeaves = 0.0;
  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  double availablepls = 0.0;
  double availablecls = 0.0;
  String accessToken = '';
  List<LookupDetail> lookupDetails = [];

  int DayWorkStatus = 0;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        loadAccessToken();
        _loademployeleaves();
        getDayWorkStatus();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  void _loademployeleaves() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final emplyeid = loadedData["employeeId"];
      final usedprivilegeleavesinyear = loadedData['usedPrivilegeLeavesInYear'];
      final allotedprivilegeleaves = loadedData['allottedPrivilegeLeaves'];
      final usedcausalleavesinmonth = loadedData['usedCasualLeavesInMonth'];
      final usedPrivilegeLeavesInMonth =
          loadedData['usedPrivilegeLeavesInMonth'];
      final usedcasualleavesinyear = loadedData['usedCasualLeavesInYear'];
      final usdl = loadedData['allottedCasualLeaves'];
      // final mobilenum = loadedData['mobileNumber'];
      // final bloodgroup = loadedData['bloodGroup'];
      print('allottedCasualLeaves: $usdl');

      print('usedprivilegeleavesinyear: $usedprivilegeleavesinyear');
      print('allotedprivilegeleaves: $allotedprivilegeleaves');
      print('usedcausalleavesinmonth: $usedcausalleavesinmonth');
      //  print('allotedpls: $allotedpls');
      print('usedcasualleavesinyear: $usedcasualleavesinyear');
      // print('mobilenum: $mobilenum');
      // print('bloodgroup: $bloodgroup');

      setState(() {
        employeid = emplyeid;
        print('employeid: $employeid');
        allotcausalleaves = usdl.toDouble();
        EmployeName = employeeName;
        usedPrivilegeLeavesInYear = usedprivilegeleavesinyear.toDouble();
        allottedPrivilegeLeaves = allotedprivilegeleaves.toDouble();
        usedCasualLeavesInMonth = usedcausalleavesinmonth.toDouble();
        usedCasualLeavesInYear = usedcasualleavesinyear.toDouble();
        // allottedPriviegeLeaves = allotedpls;
        //  usedCasualLeavesInYear = usedcasualleavesinyear;
        availablepls = allottedPrivilegeLeaves.toDouble() -
            usedPrivilegeLeavesInYear.toDouble();

        print("Available Privilege Leaves: $availablepls");

        availablecls =
            allotcausalleaves.toDouble() - usedCasualLeavesInYear.toDouble();

        print('Available Causal Leaves: $availablecls');
        DateTime now = DateTime.now();
        // Extract the current month from the DateTime object
        int currentMonth = now.month;
        // Print the current month
        print('Current month: $currentMonth');
        montlyleavesPl(currentMonth);
        montlyleavesCL(currentMonth);
        montlyleaveslwp(currentMonth);
        //  print('availablecls: $availablecls');
      });
    }
    // availablepls = allottedPrivilegeLeaves - usedPrivilegeLeavesInYear;
    // availablecls = allotcausalleaves - usedCasualLeavesInYear;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3.5;

    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); //
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                Image.asset(
                  'assets/background_layer_2.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),

                // SingleChildScrollView for scrollable content
                SingleChildScrollView(
                  child: Container(
                    padding:
                        EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hello!",
                              style: TextStyle(
                                fontSize: 26,
                                color: Colors.black,
                                fontFamily: 'Calibri',
                              ),
                            ),
                            // Padding(
                            //   padding:
                            //       EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0),
                            //   child: Container(
                            //     width: double.infinity,
                            //     decoration: BoxDecoration(
                            //       color: Color(0xFFf15f22),
                            //       borderRadius: BorderRadius.circular(6.0),
                            //     ),
                            //     child:
                            // ElevatedButton(
                            //   onPressed: () async {
                            //     Navigator.of(context).pushReplacement(
                            //       MaterialPageRoute(
                            //         builder: (context) => apply_leave(
                            //           buttonName: "test", // Example button name
                            //           lookupDetailId: -3, // Pass the lookupDetailId
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   child: Text(
                            //     'Apply',
                            //     style: TextStyle(
                            //       color: Colors.white,
                            //       fontSize: 16,
                            //       fontFamily: 'hind_semibold',
                            //     ),
                            //   ),
                            //   style: ElevatedButton.styleFrom(
                            //     primary: Colors.transparent,
                            //     elevation: 0,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(4.0),
                            //     ),
                            //   ),
                            // ),
                            //   ),
                            //  ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => apply_leave(
                                      buttonName: "test", // Example button name
                                      lookupDetailId: -3,
                                      employename:
                                          '${EmployeName}', // Pass the lookupDetailId
                                    ),
                                  ),
                                );
                                // Handle the apply button click event
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFf15f22),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              child: Text(
                                "Apply",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 8.0,
                        ),
                        Text(
                          "$EmployeName",
                          style: TextStyle(
                            fontSize: 26,
                            color: Color(0xFFf15f22),
                            fontFamily: 'Calibri',
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        // Add some space between text views and containers

                        // Row of three containers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(6.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF746cdf),
                                    Color(0xFF81aed5),
                                  ], // Adjust the colors as needed
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 19.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "PL",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Calibri'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$usedPrivilegeLeavesInYear",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Calibri'),
                                      ),
                                      SizedBox(
                                        width: 2.0,
                                      ),
                                      Text(
                                        "/",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.0,
                                      ),
                                      Text(
                                        "$allottedPrivilegeLeaves",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Calibri'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.0),
                                // Adjust the radius as needed
                                border: Border.all(
                                  color: Color(0xFF7F7FE1),
                                  // Specify the border color
                                  width:
                                      2.0, // Adjust the border width as needed
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "Monthly PL's",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFf15f22),
                                          fontFamily: 'Calibri'),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: width / 6,
                                        height: 30.0,
                                        child: IconButton(
                                          padding: EdgeInsets.only(right: 0.0),
                                          onPressed: () {
                                            _selectPreviousMonthPL();
                                          },
                                          iconSize: 20.0,
                                          icon: Icon(
                                            Icons.arrow_left,
                                            color: Color(0xFFf15f22),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: width /
                                            1.6, // Set your desired width here
                                        child: Text(
                                          DateFormat('MMMM')
                                              .format(_selectedMonthPL),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Color(0xFF746cdf),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        width: width / 6,
                                        height: 30.0,
                                        child: IconButton(
                                            padding: EdgeInsets.only(left: 0),
                                            onPressed: () {
                                              _selectNextMonthPL();
                                            },
                                            iconSize: 20.0,
                                            icon: Icon(
                                              Icons.arrow_right,
                                              color: Color(0xFFf15f22),
                                            ),
                                            alignment: Alignment.center),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "$noOfleavesinPLs",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Calibri',
                                        color: Color(0xFFf15f22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.0),
                                // Adjust the radius as needed
                                border: Border.all(
                                  color: Color(0xFF7F7FE1),
                                  // Specify the border color
                                  width:
                                      2.0, // Adjust the border width as needed
                                ),
                              ),
                              child: Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.0),
                                  // Adjust the padding as needed
                                  child: Text(
                                    "Available PL's",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Calibri',
                                      color: Color(0xFFf15f22),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Your click listener logic here
                                      print("Container Clicked!");

                                      printLookupDetailId('PL');
                                      // if (availablepls <= 0) {
                                      //   // Show a toast message
                                      //   Commonutils.showCustomToastMessageLong(
                                      //       'No PLs available!', context, 1, 3);
                                      // } else {
                                      //   printLookupDetailId('PL');
                                      // }

                                      // Navigator.of(context).pushReplacement(
                                      //   MaterialPageRoute(
                                      //       builder: (context) => apply_leave()),
                                      // );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "$availablepls",
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Color(0xFFf15f22),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 3.0,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            "Click Here to Apply",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Calibri',
                                              color: Color(0xFF7F7FE1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                              // Other child widgets or content can be added here
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF746cdf),
                                    Color(0xFF81aed5),
                                  ], // Adjust the colors as needed
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 19.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "CL",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Calibri',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "$usedCasualLeavesInYear",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Calibri',
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.0,
                                      ),
                                      Text(
                                        "/",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2.0,
                                      ),
                                      Text(
                                        "$allotcausalleaves",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Calibri',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.0),
                                // Adjust the radius as needed
                                border: Border.all(
                                  color: Color(0xFF7F7FE1),
                                  // Specify the border color
                                  width:
                                      2.0, // Adjust the border width as needed
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "Monthly CL's",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Calibri',
                                        color: Color(0xFFf15f22),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: width / 6,
                                        height: 30.0,
                                        child: IconButton(
                                          padding: EdgeInsets.only(right: 0.0),
                                          onPressed: () {
                                            _selectPreviousMonthCL();
                                          },
                                          iconSize: 20.0,
                                          icon: Icon(
                                            Icons.arrow_left,
                                            color: Color(0xFFf15f22),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: width /
                                            1.6, // Set your desired width here
                                        child: Text(
                                          DateFormat('MMMM')
                                              .format(_selectedMonthCL),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                            color: Color(0xFF746cdf),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Container(
                                        width: width / 6,
                                        height: 30.0,
                                        child: IconButton(
                                            padding: EdgeInsets.only(left: 0),
                                            onPressed: () {
                                              _selectNextMonthCL();
                                            },
                                            iconSize: 20.0,
                                            icon: Icon(
                                              Icons.arrow_right,
                                              color: Color(0xFFf15f22),
                                            ),
                                            alignment: Alignment.center),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1.0),
                                    // Adjust the padding as needed
                                    child: Text(
                                      "$noOfleavesinCLs",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Calibri',
                                        color: Color(0xFFf15f22),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Other child widgets or content can be added here
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: Color(0xFF7F7FE1),
                                  width: 2.0,
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  printLookupDetailId('CL');
                                },
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Text(
                                        "Available CL's",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Calibri',
                                          color: Color(0xFFf15f22),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 4.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$availablecls",
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Calibri',
                                              color: Color(0xFFf15f22),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 3.0,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(
                                              "Click Here to Apply",
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri',
                                                color: Color(0xFF7F7FE1),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            //
                          ],
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Container(
                        //       width: MediaQuery.of(context).size.width / 3.5,
                        //       height: 90,
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(6.0),
                        //         gradient: LinearGradient(
                        //           begin: Alignment.topCenter,
                        //           end: Alignment.bottomCenter,
                        //           colors: [
                        //             Color(0xFF875eca),
                        //             Color(0xFFe83a4c),
                        //           ], // Adjust the colors as needed
                        //         ),
                        //       ),
                        //       child: Column(
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.only(top: 19.0),
                        //             child: Text(
                        //               "LWP",
                        //               style: TextStyle(
                        //                 fontSize: 18,
                        //                 fontWeight: FontWeight.w600,
                        //                 fontFamily: 'Calibri',
                        //                 color: Colors.white,
                        //               ),
                        //             ),
                        //           ),
                        //           SizedBox(height: 10.0),
                        //           Row(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             children: [
                        //               Text(
                        //                 "0",
                        //                 style: TextStyle(
                        //                   fontSize: 15,
                        //                   fontWeight: FontWeight.w600,
                        //                   fontFamily: 'Calibri',
                        //                   color: Colors.white,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 2.0),
                        //               Text(
                        //                 "/",
                        //                 style: TextStyle(
                        //                   fontSize: 18,
                        //                   fontWeight: FontWeight.bold,
                        //                   color: Colors.white,
                        //                 ),
                        //               ),
                        //               SizedBox(width: 2.0),
                        //               Text(
                        //                 "10",
                        //                 style: TextStyle(
                        //                   fontSize: 15,
                        //                   fontWeight: FontWeight.w600,
                        //                   fontFamily: 'Calibri',
                        //                   color: Colors.white,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width / 3.5,
                        //       height: 90,
                        //       decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(6.0),
                        //         // Adjust the radius as needed
                        //         border: Border.all(
                        //           color: Color(0xFF7F7FE1),
                        //           // Specify the border color
                        //           width: 2.0, // Adjust the border width as needed
                        //         ),
                        //       ),
                        //       child: Column(
                        //         children: [
                        //           Padding(
                        //             padding: const EdgeInsets.only(top: 3.0),
                        //             // Adjust the padding as needed
                        //             child: Text(
                        //               "Monthly LWP",
                        //               style: TextStyle(
                        //                 fontSize: 16,
                        //                 fontWeight: FontWeight.w600,
                        //                 fontFamily: 'Calibri',
                        //                 color: Color(0xFFf15f22),
                        //               ),
                        //             ),
                        //           ),
                        //           Row(
                        //             children: [
                        //               Container(
                        //                 width: width / 6,
                        //                 height: 30.0,
                        //                 child: IconButton(
                        //                   padding: EdgeInsets.only(right: 0.0),
                        //                   onPressed: () {
                        //                     //_selectPreviousMonth();
                        //                     _selectPreviousMonthlwp();
                        //                   },
                        //                   iconSize: 20.0,
                        //                   icon: Icon(
                        //                     Icons.arrow_left,
                        //                     color: Color(0xFFf15f22),
                        //                   ),
                        //                 ),
                        //               ),
                        //               Container(
                        //                 width: width /
                        //                     1.6, // Set your desired width here
                        //                 child: Text(
                        //                   DateFormat('MMMM')
                        //                       .format(_selectedMonthlwp),
                        //                   style: TextStyle(
                        //                     fontSize: 14,
                        //                     fontWeight: FontWeight.w600,
                        //                     fontFamily: 'Calibri',
                        //                     color: Color(0xFF746cdf),
                        //                   ),
                        //                   textAlign: TextAlign.center,
                        //                 ),
                        //               ),
                        //               Container(
                        //                 width: width / 6,
                        //                 height: 30.0,
                        //                 child: IconButton(
                        //                     padding: EdgeInsets.only(left: 0),
                        //                     onPressed: () {
                        //                       // _selectNextMonth();
                        //                       _selectNextMonthlwp();
                        //                     },
                        //                     iconSize: 20.0,
                        //                     icon: Icon(
                        //                       Icons.arrow_right,
                        //                       color: Color(0xFFf15f22),
                        //                     ),
                        //                     alignment: Alignment.center),
                        //               ),
                        //             ],
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.only(top: 1.0),
                        //             // Adjust the padding as needed
                        //             child: Text(
                        //               "$noOfleavesinLWP",
                        //               style: TextStyle(
                        //                 fontSize: 20,
                        //                 fontWeight: FontWeight.w600,
                        //                 fontFamily: 'Calibri',
                        //                 color: Color(0xFFf15f22),
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //
                        //       // Other child widgets or content can be added here
                        //     ),
                        //     Container(
                        //       width: MediaQuery.of(context).size.width / 3.5,
                        //       height: 90,
                        //       // decoration: BoxDecoration(
                        //       //   color: Colors.white,
                        //       //   borderRadius: BorderRadius.circular(6.0),
                        //       //   // Adjust the radius as needed
                        //       //   border: Border.all(
                        //       //     color: Color(0xFF7F7FE1),
                        //       //     // Specify the border color
                        //       //     width: 2.0, // Adjust the border width as needed
                        //       //   ),
                        //       // ),
                        //       child: Column(children: [
                        //         // Padding(
                        //         //   padding: const EdgeInsets.only(top: 3.0),
                        //         //   // Adjust the padding as needed
                        //         //   child: Text(
                        //         //     "Available PL's",
                        //         //     style: TextStyle(
                        //         //       fontSize: 16,
                        //         //       fontWeight: FontWeight.w600,
                        //         //       fontFamily: 'Calibri',
                        //         //       color: Color(0xFFf15f22),
                        //         //     ),
                        //         //   ),
                        //         // ),
                        //         // Container(
                        //         //     padding: EdgeInsets.only(top: 4.0),
                        //         //     child: Column(
                        //         //       crossAxisAlignment: CrossAxisAlignment.center,
                        //         //       children: [
                        //         //         Text(
                        //         //           "8",
                        //         //           style: TextStyle(
                        //         //             fontSize: 26,
                        //         //             fontWeight: FontWeight.w600,
                        //         //             fontFamily: 'Calibri',
                        //         //             color: Color(0xFFf15f22),
                        //         //           ),
                        //         //         ),
                        //         //         SizedBox(
                        //         //           height: 3.0,
                        //         //         ),
                        //         //         Align(
                        //         //           alignment: Alignment.bottomCenter,
                        //         //           child: Text(
                        //         //             "Click Hear to Apply",
                        //         //             style: TextStyle(
                        //         //               fontSize: 11,
                        //         //               fontWeight: FontWeight.w600,
                        //         //               fontFamily: 'Calibri',
                        //         //               color: Color(0xFF7F7FE1),
                        //         //             ),
                        //         //           ),
                        //         //         )
                        //         //       ],
                        //         //     ))
                        //       ]),
                        //       // Other child widgets or content can be added here
                        //     ),
                        //   ],
                        // ),
                        // Your existing content...

                        // Add LeavesScreen content here if needed
                        // Your existing content...

                        // Add LeavesScreen content here if needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void printLookupDetailId(String buttonName) {
    if (lookupDetails.isNotEmpty) {
      LookupDetail selectedItem = lookupDetails.firstWhere(
        (item) => item.name == buttonName,
        orElse: () {
          // Provide a default value when no element is found
          return LookupDetail(
            lookupDetailId: 0, // Adjust the default values accordingly
            code: '',
            name: '',
            lookupId: 0,
            isActive: false,
            createdAt: '',
            updatedAt: '',
            createdBy: '',
            updatedBy: '',
          );
        },
      );
      if (selectedItem != null) {
        // Handle the case when an element is found
        print(selectedItem.lookupDetailId);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => apply_leave(
              buttonName: buttonName, // Example button name
              lookupDetailId: selectedItem.lookupDetailId,
              employename: '$EmployeName', // Pass the lookupDetailId
            ),
          ),
        );
      } else {
        // Handle the case when no element is found
        print('Item not found for buttonName: $buttonName');
      }
    } else {
      // Handle the case when the list is empty
      print('lookupDetails list is empty');
    }

    // Find the item with the specified name in the lookupDetails list
  }

  Future<void> getDayWorkStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      DayWorkStatus = prefs.getInt('dayWorkStatus') ?? 0;
    });
    print("DayWorkStatus:$DayWorkStatus");
    fetchDataleavetype(DayWorkStatus);
    // Provide a default value if not found
  }

  Future<void> fetchDataleavetype(int dayWorkStatus) async {
    final url = Uri.parse(baseUrl + getdropdown + '$dayWorkStatus');
    print('fetchDataleavetype :${url}');
    final response = await http.get((url));

    // final response = await http.get(Uri.parse('http://182.18.157.215/HRMS/API/hrmsapi/Lookup/LookupDetails/44'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);

      setState(() {
        lookupDetails =
            jsonData.map((data) => LookupDetail.fromJson(data)).toList();
      });
    } else {
      Commonutils.showCustomToastMessageLong(
          ' Error :  ${response.statusCode} ', context, 1, 3);
      throw Exception(
          'Failed to load data. Status Code: ${response.statusCode}');
    }
  }

  void _selectPreviousMonthPL() {
    setState(() {
      int previousMonthPL = _selectedMonthPL.month - 1;
      int monthId = previousMonthPL == 0 ? 12 : previousMonthPL;
      _selectedMonthPL = DateTime(_selectedMonthPL.year, previousMonthPL);
      montlyleavesPl(monthId);
      // Now, you can use the monthId variable as needed
      print('previous Month ID: $monthId');
    });
  }

  void _selectNextMonthPL() {
    setState(() {
      int nextMonthPL = _selectedMonthPL.month + 1;
      int monthId = nextMonthPL > 12 ? 1 : nextMonthPL;
      _selectedMonthPL = DateTime(_selectedMonthPL.year, nextMonthPL);
      montlyleavesPl(monthId);
      // Now, you can use the monthId variable as needed
      print('Next Month ID: $monthId');
    });
  }

  void _selectPreviousMonthCL() {
    setState(() {
      int previousMonthCL = _selectedMonthCL.month - 1;
      int monthId = previousMonthCL == 0 ? 12 : previousMonthCL;
      _selectedMonthCL = DateTime(_selectedMonthCL.year, previousMonthCL);
      montlyleavesCL(monthId);
      // Now, you can use the monthId variable as needed
      print('previous Month ID: $monthId');
    });
  }

  void _selectNextMonthCL() {
    setState(() {
      int nextMonthCl = _selectedMonthCL.month + 1;
      int monthId = nextMonthCl > 12 ? 1 : nextMonthCl;
      _selectedMonthCL = DateTime(_selectedMonthCL.year, nextMonthCl);
      montlyleavesCL(monthId);
      // Now, you can use the monthId variable as needed
      print('Next Month ID: $monthId');
    });
  }

  void _selectPreviousMonthlwp() {
    setState(() {
      int previousMonthlwp = _selectedMonthlwp.month - 1;
      int monthIdlwp = previousMonthlwp == 0 ? 12 : previousMonthlwp;
      _selectedMonthlwp = DateTime(_selectedMonthlwp.year, previousMonthlwp);
      montlyleaveslwp(monthIdlwp);
      // Now, you can use the monthId variable as needed
      print('previous Month ID: $monthIdlwp');
    });
  }

  void _selectNextMonthlwp() {
    setState(() {
      int nextMonthlwp = _selectedMonthlwp.month + 1;
      int monthIdlwp = nextMonthlwp > 12 ? 1 : nextMonthlwp;
      _selectedMonthlwp = DateTime(_selectedMonthlwp.year, nextMonthlwp);
      montlyleaveslwp(monthIdlwp);
      // Now, you can use the monthId variable as needed
      print('Next Month ID: $monthIdlwp');
    });
  }

  Future<void> montlyleavesPl(int monthId) async {
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');
    try {
      final url = Uri.parse(baseUrl +
          getmontlyleaves +
          '/$monthId' +
          '/$employeid' +
          '/$currentYear');
      print('monthlyleavesPlsapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        print('response data : ${data}');
        List<leave_model> leaveInfos =
            data.map((json) => leave_model.fromJson(json)).toList();

        // Now you have a List of LeaveInfo objects
        for (var leaveInfo in leaveInfos) {
          print('LeavePLType: ${leaveInfo.leaveType}');
          // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
          print('Used PLs in Month: ${leaveInfo.usedPLsInMonth.toDouble()}');
          double noofPL = leaveInfo.usedPLsInMonth.toDouble();
          print('noofPL:$noofPL');
          setState(() {
            noOfleavesinPLs = noofPL.toDouble();
            print('noOfleavesinPLs:$noOfleavesinPLs');
          });
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
  }

  Future<void> montlyleavesCL(int monthId) async {
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');
    try {
      final url = Uri.parse(baseUrl +
          getmontlyleaves +
          '/$monthId' +
          '/$employeid' +
          '/$currentYear');
      print('monthlyleavesClsapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        print('response data : ${data}');
        List<leave_model> leaveInfos =
            data.map((json) => leave_model.fromJson(json)).toList();

        // Now you have a List of LeaveInfo objects
        for (var leaveInfoCl in leaveInfos) {
          print('LeaveClType: ${leaveInfoCl.leaveType}');
          // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
          print('UsedCLsin Month: ${leaveInfoCl.usedCLsInMonth.toDouble()}');

          double noofCL = leaveInfoCl.usedCLsInMonth.toDouble();
          print('noofCL:$noofCL');
          setState(() {
            noOfleavesinCLs = noofCL.toDouble();
            print('noOfleavesinCls:$noOfleavesinCLs');
          });
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
  }

  Future<void> montlyleaveslwp(int monthId) async {
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');
    try {
      final url = Uri.parse(baseUrl +
          getmontlyleaves +
          '/$monthId' +
          '/$employeid' +
          '/$currentYear');
      print('monthlyleaveslwpapi: $url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers: $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      print("responsecode ${response.statusCode}");

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        print('response data : ${data}');
        List<leave_model> leaveInfos =
            data.map((json) => leave_model.fromJson(json)).toList();

        // Now you have a List of LeaveInfo objects
        for (var leaveInfoLWP in leaveInfos) {
          if (leaveInfoLWP.leaveType == "LWP") {
            print('LeaveLWPType: ${leaveInfoLWP.leaveType}');
            // print('Used CLs in Month: ${leaveInfo.usedCLsInMonth}');
            print('UsedLWPin Month: ${leaveInfoLWP.usedPLsInMonth}');
            double noofCL = leaveInfoLWP.usedPLsInMonth.toDouble();

            setState(() {
              noOfleavesinLWP = noofCL.toDouble();
              print('noOfleavesinLWP:$noOfleavesinLWP');
            });
          }
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninapplyleave:$accessToken");
  }
}
