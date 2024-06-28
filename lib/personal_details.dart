import 'dart:convert';
import 'dart:math';

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
  const personal_details({super.key});

  // final String logintime;
  // personal_details({required this.logintime});
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
  String accessToken = '';
  String? Dateofjoining;
  String? formatteddateofjoining;
  DateTime? dateofjoin;
  String? logintime;
  String? cisid;
  String? employee_designation;
  String? ReportingTo;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        _loademployeresponse();
        loademployeeimage();
        loadAccessToken();
        getLoginTime();
        //  _checkLoginTime();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  // Future<String> getLoginTime() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('loginTime') ?? 'Unknown';
  // }
  Future<String?> getLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logintime = prefs.getString('loginTime') ?? 'Unknown';
    print('Login Time: $logintime');
    return logintime;
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninpersonaldetails:$accessToken");
  }

  void _loademployeresponse() async {
    // final loadedData = await SharedPreferencesHelper.getCategories();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('response_key');
    if (jsonString != null && jsonString.isNotEmpty) {
      final loadedData = jsonDecode(jsonString);
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
        final code = loadedData['code'];
        final designation = loadedData['designation'];
        final reportingTo = loadedData['reportingTo'];

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
        String formattedDOB = DateFormat('dd MMM yyyy').format(dobDate);
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
          formatteddateofjoining =
              DateFormat('dd MMM yyyy').format(dateofjoin!);
          print('formatteddateofjoining$formatteddateofjoining');
        } else {
          formatteddateofjoining =
              ''; // Handle the case when dateofjoin is null
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

          if (loadedData['reportingTo'] != null) {
            ReportingTo = reportingTo;
            print('reportingTo$reportingTo');
          } else {
            ReportingTo = '';
            // Handle the case when loadedData['experienceInCompany'] is null
            // For example, you could provide a default value or show an error message
          }
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
          if (code != null) {
            cisid = code;
          } else {
            cisid = '';
          }
          if (designation != null) {
            employee_designation = designation;
          } else {
            employee_designation = '';
          }

          // Gender = gender;
          if (gender != null) {
            Gender = gender;
          } else {
            // Handle the case where gender is null, maybe assign a default value
            Gender = "Unknown";
          }
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
    } else {
      print('Failed to load data');
    }
  }

  void _showtimeoutdialog(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Session Time Out",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Invalid Token",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "PLease Login Again",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Calibri',
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    //width: MediaQuery.of(context).size.width,
                    child: const Column(
                      children: [],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // void _checkLoginTime() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     DateTime currentTime = DateTime.now();
  //     DateTime formattedLoginTime = DateTime.parse(logintime!);
  //
  //     Duration timeDifference = currentTime.difference(formattedLoginTime);
  //
  //     if (timeDifference.inSeconds > 3600) {
  //       _showtimeoutdialog(context);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // DateTime currentTime = DateTime.now();
    // DateTime formattedlogintime = DateTime.parse(logintime!);
    // // Replace this with your actual login time
    // DateTime loginTime = formattedlogintime /* Replace with your login time */;
    //
    // // Calculate the time difference
    // Duration timeDifference = currentTime.difference(loginTime);
    //
    // // Check if the time difference is less than or equal to 1 hour (3600 seconds)
    // if (timeDifference.inSeconds <= 3600) {
    //   // Login is within the allowed window
    //
    //   print("Login is within 1 hour of current time.");
    // } else {
    //   // Login is outside the allowed window
    //   _showtimeoutdialog(context);
    //   print("Login is more than 1 hour from current time.");
    //   return Container(
    //     child: Text('this is a sample text'),
    //   );
    // }
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const home_screen()),
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
                    ? const Center(
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
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height /
                                        3.0,
                                    child: ClipPath(
                                      clipper: CurvedBottomClipper(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFf15f22),
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0, top: 5),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Container(
                                              //   child: Text(
                                              //     "Welcome!",
                                              //     style: TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'Calibri'),
                                              //   ),
                                              // ),
                                              const SizedBox(height: 8.0),
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      3.2,
                                                  child: Column(
                                                    children: [
                                                      if (photoData != "")
                                                        // SizedBox(
                                                        //     width: 90,
                                                        //     height: 85,
                                                        //     child: Image.memory(
                                                        //       _decodeBase64(
                                                        //           photoData),
                                                        //       width: 90,
                                                        //       height: 90,
                                                        //     ))
                                                        Container(
                                                          width: 120,
                                                          height: 120,
                                                          decoration:
                                                              const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            gradient:
                                                                LinearGradient(
                                                              colors: [
                                                                Color.fromARGB(
                                                                    255,
                                                                    184,
                                                                    55,
                                                                    0),
                                                                Colors.white,
                                                                Color.fromARGB(
                                                                    255,
                                                                    184,
                                                                    55,
                                                                    0),
                                                                Colors.white,
                                                              ],
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            child: ClipOval(
                                                              child:
                                                                  Image.memory(
                                                                _decodeBase64(
                                                                    photoData),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      else if (Gender !=
                                                          null) ...{
                                                        getDefaultImage(
                                                            Gender!),
                                                      } else ...{
                                                        Image.asset(
                                                          'assets/app_logo.png',
                                                          width: 90,
                                                          height: 90,
                                                        )
                                                      },
                                                      const SizedBox(
                                                          height: 5.0),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.5,
                                                        child: Text(
                                                          EmployeName,
                                                          softWrap: true,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  'Calibri'),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 2.0),
                                                      Text(
                                                        "$employee_designation",
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                            fontFamily:
                                                                'Calibri'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                side: const BorderSide(
                                                  color: Color(0xFFf15f22),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            5,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "Employee Id",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            5,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        5,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$cisid",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "Gender",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$Gender",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "Office Email Id ",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$OfficeEmailid",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "DOJ",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$formatteddateofjoining",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$Mobilenum",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  dob,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "Reporting To",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$ReportingTo",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                    Row(
                                                      children: [
                                                        const Expanded(
                                                          flex: 4,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            12,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  "Experience In Company",
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
                                                        const Expanded(
                                                          flex: 0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                child: Text(
                                                                  ":",
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        16,
                                                                    fontFamily:
                                                                        'Calibri',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                                    const EdgeInsets
                                                                        .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        0,
                                                                        0),
                                                                child: Text(
                                                                  "$Expincomapny",
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                                                    const SizedBox(height: 5.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                                        ],
                                      ))
                                  //)
                                ],
                              )),

                          // ClipPath for the curved bottom
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
    final url = Uri.parse('$baseUrl$GetEmployeePhoto$empolyeid');
    print('loademployeeimage  $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      },
    );
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
    String genderImage = gender == "Male"
        ? 'assets/men_emp.jpg'
        : gender == "Female"
            ? 'assets/women-emp.jpg'
            : 'assets/app_logo.png';

    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 184, 55, 0),
            Colors.white,
            Color.fromARGB(255, 184, 55, 0),
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipOval(
          child: Image.asset(
            width: 60,
            height: 50,
            genderImage,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Uint8List _decodeBase64(String base64String) {
    final List<String> parts = base64String.split(',');
    print('====>${parts.length}');

    if (parts.length != 2) {
      throw const FormatException(
          'Invalid base64 string: Incorrect number of parts');
    }

    final String dataPart = parts[1];

    try {
      return const Base64Codec().decode(dataPart);
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
        -5, size.height - roundingHeight * 2, size.width + 5, size.height);

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
