import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Commonutils.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';
import 'home_screen.dart';

class personal_details extends StatefulWidget {
  @override
  _personal_screen_screenState createState() => _personal_screen_screenState();
}

class _personal_screen_screenState extends State<personal_details> {
  int currentTab = 0;
  bool isLoading = false;
  String EmployeName = '';
  String dob = '';
  String EmailId = '';
  String? OfficeEmailid;
  String? Expincomapny;
  String? Mobilenum;
  String? Bloodgroup;
  String formattedDOB = '';
  String? Gender;
  String photoData = "";
  String empolyeid = '';
  String? Dateofjoining;
  String? formatteddateofjoining;
  DateTime? dateofjoin;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        _loademployeresponse();
        loademployeeimage();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  void _loademployeresponse() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final dateofbirth = loadedData['originalDOB'];
      final emailid = loadedData['emailId'];
      final officemailid = loadedData['officeEmailId'];
      final expincompany = loadedData['experienceInCompany'];
      final mobilenum = loadedData['mobileNumber'];
      final bloodgroup = loadedData['bloodGroup'];
      final gender = loadedData["gender"];
      final dateofjoining = loadedData['dateofJoin'];
      //   "gender"
      // : "Male"
      print('employeeName: $employeeName');
      print('dob: $dateofbirth');
      print('emailid: $emailid');
      print('officemail: $officemailid');
      print('expincompany: $expincompany');
      print('mobilenum: $mobilenum');
      print('bloodgroup: $bloodgroup');

      // Format the date of birth into "dd/MM/yyyy"
      DateTime dobDate = DateTime.parse(dateofbirth);
      String formattedDOB = DateFormat('dd-MM-yyyy').format(dobDate);
      print('formattedDOB: $formattedDOB');

      // DateTime dateofjoin = DateTime.parse(dateofjoining);

// Check if dateofjoining is not null before parsing
      if (dateofjoining != null) {
        dateofjoin = DateTime.parse(dateofjoining!);
      }
      // String formatteddateofjoining =
      //     DateFormat('dd-MM-yyyy').format(dateofjoin!);

// Check if dateofjoin is not null before formatting
      if (dateofjoin != null) {
        formatteddateofjoining = DateFormat('dd-MM-yyyy').format(dateofjoin!);
        print('formatteddateofjoining$formatteddateofjoining');
      } else {
        formatteddateofjoining == ''; // Handle the case when dateofjoin is null
        // For example, you could provide a default value or show an error message
      }

      print('formatteddateofjoining: $formatteddateofjoining');

      setState(() {
        EmployeName = employeeName;
        dob = formattedDOB;
        EmailId = emailid;
        // OfficeEmailid = officemailid;
        if (loadedData['officeEmailId'] != null) {
          OfficeEmailid = loadedData['officeEmailId'] as String;
          print('OfficeEmailid$OfficeEmailid');
        } else {
          OfficeEmailid = '';
          // Handle the case when loadedData['experienceInCompany'] is null
          // For example, you could provide a default value or show an error message
        }
        print('OfficeEmailid$OfficeEmailid');
        if (loadedData['experienceInCompany'] != null) {
          Expincomapny = loadedData['experienceInCompany'] as String;
          print('Expincomapny$Expincomapny');
        } else {
          Expincomapny = '';
          // Handle the case when loadedData['experienceInCompany'] is null
          // For example, you could provide a default value or show an error message
        }
        Mobilenum = mobilenum;
        Bloodgroup = bloodgroup;
        Gender = gender;

// Check if formatteddateofjoining is not null before using it
        if (formatteddateofjoining != null) {
          Dateofjoining = formatteddateofjoining;
          print('Dateofjoining$Dateofjoining');
        } else {
          Dateofjoining = '';
          // Handle the case when formatteddateofjoining is null
          // For example, you could provide a default value or show an error message
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
          // Handle back button press here
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body:
                // SingleChildScrollView(
                //   physics: NeverScrollableScrollPhysics(),
                // child:
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(
                        children: [
                          // Background Image
                          Image.asset(
                            'assets/background_layer_2.png', // Replace with your image path
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),

                          // ClipPath for the curved bottom
                          ClipPath(
                            clipper: CurvedBottomClipper(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFf15f22),
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 3.1,
                              child: Padding(
                                padding: EdgeInsets.only(left: 35, top: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Hello!",
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.black,
                                            fontFamily: 'Calibri'),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.0,
                                    ),
                                    Text(
                                      "$EmployeName",
                                      style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                          fontFamily: 'Calibri'),
                                    ),
                                    // Add more widgets if needed
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  if (photoData != null && photoData != "")
                                    Image.memory(
                                      _decodeBase64(photoData ?? ""),
                                      width: 90,
                                      height: 110,
                                    )
                                  else
                                    getDefaultImage(Gender!),

                                  // if (Gender == "Male")
                                  //   Image.asset(
                                  //     'assets/men_emp.jpg',
                                  //     width: 90,
                                  //     height: 110,
                                  //   )
                                  // else if (Gender == "Female")
                                  //   Image.asset(
                                  //     'assets/women-emp.jpg',
                                  //     width: 90,
                                  //     height: 110,
                                  //   ),

                                  //  SizedBox(height: 40.0),
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: BorderSide(
                                          color: Color(0xFFf15f22),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                            10.0), // Adjust the padding as needed
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 5, 0, 0),
                                                        child: Text(
                                                          "DOB",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 5, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 5, 0, 0),
                                                        child: Text(
                                                          "$dob",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Email",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$EmailId",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Official Mail ID ",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$OfficeEmailid",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Date of Joining",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$Dateofjoining",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Exp in this Company",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$Expincomapny",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Mobile Number ",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$Mobilenum",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12, 0, 0, 0),
                                                        child: Text(
                                                          "Blood Group",
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFFf15f22),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 0,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 0, 0),
                                                        child: Text(
                                                          ":",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Calibri',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                10, 0, 0, 0),
                                                        child: Text(
                                                          "$Bloodgroup",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'Calibri',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                                ],
                              ))
                        ],
                      ),
          ),
        ));
  }

  Future<void> loademployeeimage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
    });
    print("empolyeidinapplyleave:$empolyeid");
    // final response = await http.get('http://182.18.157.215/HRMS/API/hrmsapi/Employee/GetEmployeePhoto/91');
    final url = Uri.parse(baseUrl + GetEmployeePhoto + '$empolyeid');
    print('loademployeeimage  $url');
    final response = await http.get((url));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        photoData =
            data['ImageData'] ?? ""; // Initialize with an empty string if null
        print('photoData==== $photoData');
      });
    } else {
      // Handle error
      print('Failed to load employee photo');
    }
  }

  Widget getDefaultImage(String gender) {
    return gender == "Male"
        ? Image.asset(
            'assets/men_emp.jpg',
            width: 90,
            height: 110,
          )
        : gender == "Female"
            ? Image.asset(
                'assets/women-emp.jpg',
                width: 90,
                height: 110,
              )
            : Container(); // You can replace Container() with another default image or widget
  }

  Uint8List _decodeBase64(String base64String) {
    final List<String> parts = base64String.split(',');
    print('====>${parts.length}');

    if (parts.length != 2) {
      throw FormatException('Invalid base64 string: Incorrect number of parts');
    }

    final String dataPart = parts[1];

    try {
      return Base64Codec().decode(dataPart);
    } catch (e) {
      throw FormatException('Invalid base64 string: $e');
    }
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // I've taken approximate height of curved part of view
    // Change it if you have exact spec for it
    final roundingHeight = size.height * 6 / 5;
    //   final roundingHeight =  size.height ;

    // this is top part of path, rectangle without any rounding
    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    // this is rectangle that will be used to draw arc
    // arc is drawn from center of this rectangle, so it's height has to be twice roundingHeight
    // also I made it to go 5 units out of screen on left and right, so curve will have some incline there
    final roundingRectangle = Rect.fromLTRB(
        -79, size.height - roundingHeight * 2, size.width + 5, size.height);

    final path = Path();
    path.addRect(filledRectangle);

    // so as I wrote before: arc is drawn from center of roundingRectangle
    // 2nd and 3rd arguments are angles from center to arc start and end points
    // 4th argument is set to true to move path to rectangle center, so we don't have to move it manually
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // returning fixed 'true' value here for simplicity, it's not the part of actual question, please read docs if you want to dig into it
    // basically that means that clipping will be redrawn on any changes
    return true;
  }
}
