import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/Model%20Class/login%20model%20class.dart';
import 'package:hrms/Splash_screen.dart';
import 'package:hrms/custom_dialog.dart';
import 'package:hrms/security_questions.dart';
import 'package:hrms/security_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/home_screen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernamecontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  String? selectedPhoneNumber;
  List<loginmodel> loginlist = [];
  String? employeeId;
  bool isLoading = false;
  String? accessToken;
  bool _obscureText = true;
  String isfirst_time = "";
  bool _isLoading = false;
  String userid = '';
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
        Commonutils.showCustomToastMessageLong(
            'Not connected to the internet', context, 1, 4);
        print('The Internet Is not  Connected');
      }
    });
    // requestPhonePermission();
  }

  Future<void> validate() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    if (isValid && _usernamecontroller.text.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Username', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }
    if (isValid && _passwordcontroller.text.isEmpty) {
      isValid = false;
      hasValidationFailed = true;
      Commonutils.showCustomToastMessageLong(
          'Please Enter Password', context, 1, 4);
      FocusScope.of(context).unfocus();
    } else {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (isConnected) {
        print('Connected to the internet');
      } else {
        Commonutils.showCustomToastMessageLong(
            'No Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        print('Not connected to the internet');
      }
    }

    String username = _usernamecontroller.text;
    String password = _passwordcontroller.text;
    // String username = "ArunShetty";
    // String password = "Arun@120898";

    if (isValid) {
      final request = {
        "userName": username,
        "password": password,
        "rememberMe": true
      };
      print('Request Body: ${json.encode(request)}');
      try {
        final url = Uri.parse(baseUrl + getlogin);
        print('LoginUrl: $url');
        // Send the POST request
        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json', // Set the content type header
          },
        );
        print('loginreponse$response');
        print('login response: ${response.statusCode}');
        print('statusCode=====>${response.statusCode}');
        // if (response.body == "User not found") {
        //   Commonutils.showCustomToastMessageLong(
        //       'Please Check the User Name & Password', context, 1, 4);
        // }
        // Check the response status code

        if (response.statusCode == 200) {
          //  Map<String, dynamic> jsonResponse = json.decode(response.body);
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          accessToken = jsonResponse['accessToken'];
          String refreshToken = jsonResponse['refreshToken'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("accessToken", accessToken!);
          print('accesstokensaved');

          Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);

          isfirst_time = decodedToken['IsFirstTimeLogin'];
          print('isfirst_timeloginornot:$isfirst_time');
          userid = decodedToken['Id'];
          print('useridfromjwttoken:$userid');
          if (isfirst_time == 'True') {
            //navigate to next screen
            print('navigate to next screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => security_questionsscreen(
                        userid: '$userid',
                      )),
            );
          } else {
            employeeId = decodedToken['EmployeeId'];
            SharedPreferences emplyid = await SharedPreferences.getInstance();
            await emplyid.setString("employeeId", employeeId!);
            print('EmployeeIdsaved');

            print('AccessToken: $accessToken');
            print('RefreshToken: $refreshToken');
            print('EmployeeId: $employeeId');

            empolyelogin(employeeId!);
            Commonutils.showCustomToastMessageLong(
                'Login Successful', context, 0, 2);
          }
        } else {
          FocusScope.of(context).unfocus();
          Commonutils.showCustomToastMessageLong(
              'Invalid Username or Password ', context, 1, 4);
          print('response is not success');

          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
    ;
  }

  Future<void> empolyelogin(String empolyeid) async {
    try {
      final url = Uri.parse(baseUrl + getselfempolyee + empolyeid);
      print('SelfEmpolyeeUrl: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': '$accessToken',
        },
      );
      print('login response: ${response.body}');

      // Check the response status code
      if (response.statusCode == 200) {
        fetchLookupKeys();
        // Save the response data to shared preferences
        final Map<String, dynamic> responseData = json.decode(response.body);
        //await AuthService.saveSecondApiResponse(responseData);
        print('Savedresponse: ${responseData}');
        await SharedPreferencesHelper.saveCategories(responseData);
        SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
        // Navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => home_screen()),
        );
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error  ${response.statusCode}', context, 1, 4);
        print('response is not success');
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
        // Handle error scenarios
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _loadNextPage() {
    // Show progress indicator
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay to mimic loading
    Future.delayed(Duration(seconds: 2), () {
      // Navigate to the next page when loading is complete
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => securityscreen()),
      ).then((_) {
        // Hide progress indicator when returning from the next page
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          // Handle back button press here
          // You can add any custom logic before closing the app
          return true; // Return true to allow back button press and close the app
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                // Background Image

                Positioned.fill(
                  child: Image.asset(
                    'assets/background_layer_2.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Your Login Screen Widgets
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator.adaptive()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Text Field for Username or Email

                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SvgPicture.asset(
                                'assets/cislogo-new.svg',
                                height: 120.0,
                                width: 55.0,
                              ),
                            ),
                            SizedBox(height: 2.0),
                            Text(
                              'HRMS',
                              style: TextStyle(
                                color: Color(0xFFf15f22),
                                fontSize: 26.0,
                                fontFamily: 'Calibri',
                                fontWeight: FontWeight
                                    .bold, // Set the font weight to bold
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 25.0, left: 40.0, right: 40.0),
                              child: TextFormField(
                                ///     keyboardType: TextInputType.name,

                                controller: _usernamecontroller,
                                onTap: () {
                                  // requestPhonePermission();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Username',
                                  filled: true,
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.black26, // Label text color
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  alignLabelWithHint: true,
                                ),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 20.0, left: 40.0, right: 40.0),
                              child: TextFormField(
                                // keyboardType: TextInputType.phone,

                                controller: _passwordcontroller,
                                obscureText: _obscureText,
                                onTap: () {
                                  //requestPhonePermission();
                                },

                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Colors.black26, // Label text color
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  alignLabelWithHint: true,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      // Toggle the password visibility
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                ),

                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 6.0, left: 45.0, right: 43.0),
                              child: GestureDetector(
                                onTap: _loadNextPage,
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                        color: Color(0xFFf15f22),
                                        fontSize: 14,
                                        fontFamily: 'Calibri'),
                                  ),
                                ),
                              ),
                              // GestureDetector(
                              //   onTap: () {
                              //     // Add your click handling logic here
                              //     Future.delayed(Duration(seconds: 2), () {
                              //       Navigator.of(context).pushReplacement(
                              //         MaterialPageRoute(
                              //             builder: (context) => securityscreen()),
                              //       );
                              //     });
                              //   },
                              //   child: Container(
                              //     width: double.infinity,
                              //     child: Text(
                              //       'Forgot Password?',
                              //       style: TextStyle(
                              //         color: Color(0xFFf15f22),
                              //         fontSize: 14,
                              //         fontFamily: 'hind_semibold',
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ),
                            // Login Button
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 35.0, left: 40.0, right: 40.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFf15f22),
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adjust the border radius as needed
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    validate();
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Calibri'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> saveAccessToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("accessToken", token);
  }

  Future<List<dynamic>> fetchLookupKeys() async {
    final response = await http.get(Uri.parse(baseUrl + lookupkeys));
    // final response = await http.get(Uri.parse('http://182.18.157.215/HRMS/API/hrmsapi/Lookup/LookupKeys'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);
      Map<String, dynamic> lookups = jsonData['Lookups'];

      // Save DayWorkStatus in SharedPreferences
      saveDayWorkStatus(lookups['DayWorkStatus']);
      saveLeaveReasons(lookups['LeaveReasons']);
      // Return the entire response as a List<dynamic>
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception(
          'Failed to load Lookup Keys. Status Code: ${response.statusCode}');
    }
  }

// Function to save DayWorkStatus in SharedPreferences
  Future<void> saveDayWorkStatus(int dayWorkStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dayWorkStatus', dayWorkStatus);
  }

  Future<void> saveLeaveReasons(int LeaveReasons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('leavereasons', LeaveReasons);
  }
}

// class AuthService {
//   static Future<void> saveAuthData(
//       String accessToken, String refreshToken, String employeeId) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('accessToken', accessToken);
//     prefs.setString('refreshToken', refreshToken);
//     prefs.setString('employeeId', employeeId);
//   }
//
//   static Future<void> saveSecondApiResponse(
//       Map<String, dynamic> responseData) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('secondApiResponse', json.encode(responseData));
//   }
// }
