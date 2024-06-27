import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/Model%20Class/login%20model%20class.dart';
import 'package:hrms/Splash_screen.dart';
import 'package:hrms/changepassword.dart';
import 'package:hrms/security_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/svg.dart';
import 'package:hrms/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Commonutils.dart';
import 'Constants.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
        Commonutils.showCustomToastMessageLong('Not connected to the internet', context, 1, 4);
        print('The Internet Is not  Connected');
      }
    });
    // requestPhonePermission();
  }

  // Future<void> validate() async {
  //   // Define timeout duration (15 seconds)
  //   const Duration timeoutDuration = Duration(seconds: 15);
  //
  //   // Create a Completer to handle API request completion
  //   Completer<void> completer = Completer<void>();
  //
  //   // Start a timer
  //   Timer timer = Timer(timeoutDuration, () {
  //     if (!completer.isCompleted) {
  //       // Cancel the API request
  //       print('Timeout occurred: Timer function executed');
  //       completer.completeError('Timeout occurred');
  //     }
  //   });
  //
  //   bool isValid = true;
  //   bool hasValidationFailed = false;
  //   if (isValid && _usernamecontroller.text.isEmpty) {
  //     print('Validation failed: Username is empty');
  //     Commonutils.showCustomToastMessageLong('Please Enter Username', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //     FocusScope.of(context).unfocus();
  //   }
  //   if (isValid && _passwordcontroller.text.isEmpty) {
  //     print('Validation failed: Password is empty');
  //     isValid = false;
  //     hasValidationFailed = true;
  //     Commonutils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
  //     FocusScope.of(context).unfocus();
  //   } else {
  //     bool isConnected = await Commonutils.checkInternetConnectivity();
  //     if (isConnected) {
  //       print('Connected to the internet');
  //     } else {
  //       print('No internet connection');
  //       Commonutils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
  //       FocusScope.of(context).unfocus();
  //     }
  //   }
  //
  //   String username = _usernamecontroller.text;
  //   String password = _passwordcontroller.text;
  //
  //   if (isValid) {
  //     await _performAPICall(completer, username, password);
  //   }
  //
  //   // Wait for API request completion or timeout
  //   try {
  //     await completer.future;
  //   } catch (e) {
  //     // Handle API request completion or timeout
  //     print('Error or Timeout: $e');
  //     if (e.toString() == 'Timeout occurred') {
  //       // Show toast message for timeout
  //       print('API request timed out. Retrying...');
  //       Commonutils.showCustomToastMessageLong('API request timed out. Retrying...', context, 1, 4);
  //       // Retry the API request after 15 seconds
  //       Future.delayed(Duration(seconds: 15), () {
  //         validate();
  //       });
  //     } else {
  //       // Show toast message for other errors
  //       Commonutils.showCustomToastMessageLong('Error occurred: $e', context, 1, 4);
  //     }
  //   } finally {
  //     // Cancel the timer
  //     timer.cancel();
  //   }
  // }

  // Future<void> validate() async {
  //   // Define timeout duration (15 seconds)
  //   Duration timeoutDuration = Duration(seconds: 5);
  //
  //   // Create a Completer to handle API request completion
  //   Completer<void> completer = Completer<void>();
  //
  //   // Start a timer
  //   Timer timer = Timer(timeoutDuration, () {
  //     if (!completer.isCompleted) {
  //       // Cancel the API request
  //       completer.completeError('Timeout occurred');
  //     }
  //   });
  //
  //   bool isValid = true;
  //   bool hasValidationFailed = false;
  //   if (isValid && _usernamecontroller.text.isEmpty) {
  //     Commonutils.showCustomToastMessageLong('Please Enter Username', context, 1, 4);
  //     isValid = false;
  //     hasValidationFailed = true;
  //     FocusScope.of(context).unfocus();
  //   }
  //   if (isValid && _passwordcontroller.text.isEmpty) {
  //     isValid = false;
  //     hasValidationFailed = true;
  //     Commonutils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
  //     FocusScope.of(context).unfocus();
  //   } else {
  //     bool isConnected = await Commonutils.checkInternetConnectivity();
  //     if (isConnected) {
  //       print('Connected to the internet');
  //     } else {
  //       Commonutils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
  //       FocusScope.of(context).unfocus();
  //       print('Not connected to the internet');
  //     }
  //   }
  //
  //   String username = _usernamecontroller.text;
  //   String password = _passwordcontroller.text;
  //
  //   if (isValid) {
  //     await _performAPICall(completer, username, password);
  //   }
  //
  //   // Wait for API request completion or timeout
  //   try {
  //     await completer.future;
  //   } catch (e) {
  //     // Handle API request completion or timeout
  //     print('Error or Timeout: $e');
  //     if (e.toString() == 'Timeout occurred') {
  //       // Show toast message for timeout
  //       Commonutils.showCustomToastMessageLong('Something went wrong. This is taking longer than expected. Please login again', context, 1, 4);
  //       //Commonutils.showCustomToastMessageLong('API request timed out', context, 1, 4);
  //       // Retry the API request after 15 seconds
  //       Future.delayed(Duration(seconds: 15), () {
  //         //   validate();
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (context) => LoginPage()),
  //         );
  //       });
  //     } else {
  //       // Show toast message for other errors
  //       Commonutils.showCustomToastMessageLong('Error occurred: $e', context, 1, 4);
  //     }
  //   } finally {
  //     // Cancel the timer
  //     timer.cancel();
  //   }
  // }

  // Future<void> _performAPICall(Completer<void> completer, String username, String password) async {
  //   final request = {"userName": username, "password": password, "rememberMe": true};
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   print('Request Body: ${json.encode(request)}');
  //   try {
  //     final url = Uri.parse(baseUrl + getlogin);
  //     print('LoginUrl: $url');
  //     // Send the POST request
  //     final response = await http.post(
  //       url,
  //       body: json.encode(request),
  //       headers: {
  //         'Content-Type': 'application/json', // Set the content type header
  //       },
  //     );
  //     print('loginreponse$response');
  //     print('login response: ${response.statusCode}');
  //
  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> jsonResponse = json.decode(response.body);
  //
  //       accessToken = jsonResponse['accessToken'];
  //       String refreshToken = jsonResponse['refreshToken'];
  //
  //       SharedPreferences prefs = await SharedPreferences.getInstance();
  //       await prefs.setString("accessToken", accessToken!);
  //       print('accesstokensaved');
  //
  //       Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken!);
  //
  //       isfirst_time = decodedToken['IsFirstTimeLogin'];
  //       print('isfirst_timeloginornot:$isfirst_time');
  //       userid = decodedToken['Id'];
  //       print('useridfromjwttoken:$userid');
  //
  //       employeeId = decodedToken['EmployeeId'];
  //       SharedPreferences emplyid = await SharedPreferences.getInstance();
  //       await emplyid.setString("employeeId", employeeId!);
  //       print('EmployeeIdsaved');
  //
  //       print('AccessToken: $accessToken');
  //       print('RefreshToken: $refreshToken');
  //       print('EmployeeId: $employeeId');
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       empolyelogin(employeeId!, isfirst_time, userid);
  //     } else {
  //       FocusScope.of(context).unfocus();
  //       Commonutils.showCustomToastMessageLong('Invalid Username or Password ', context, 1, 4);
  //       print('response is not success');
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       print('Failed to send the request. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     print('Error: $e');
  //     completer.completeError('Error: $e');
  //   } finally {
  //     // Cancel the timer
  //     completer.complete(); // Complete the completer
  //   }
  // }

//Working Code commented by Arun on 19/4/2024 for adding timer
  Future<void> validate() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    bool apiCallCompleted = false;
    if (isValid && _usernamecontroller.text.isEmpty) {
      Commonutils.showCustomToastMessageLong('Please Enter Username', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
      FocusScope.of(context).unfocus();
    }
    if (isValid && _passwordcontroller.text.isEmpty) {
      isValid = false;
      hasValidationFailed = true;
      Commonutils.showCustomToastMessageLong('Please Enter Password', context, 1, 4);
      FocusScope.of(context).unfocus();
    } else {
      bool isConnected = await Commonutils.checkInternetConnectivity();
      if (isConnected) {
        print('Connected to the internet');
      } else {
        Commonutils.showCustomToastMessageLong('No Internet Connection', context, 1, 4);
        FocusScope.of(context).unfocus();
        print('Not connected to the internet');
      }
    }

    String username = _usernamecontroller.text;
    String password = _passwordcontroller.text;
    // String username = "ArunShetty";
    // String password = "Arun@120898";

    if (isValid && !hasValidationFailed) {
      final request = {"userName": username, "password": password, "rememberMe": true};
      setState(() {
        _isLoading = true;
      });
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
        ).timeout(const Duration(seconds: 10), onTimeout: () {
          apiCallCompleted = false;
          Commonutils.showCustomToastMessageLong('Something Went Wrong Please Login Again', context, 1, 4);
          return http.Response('Timeout', HttpStatus.requestTimeout);
        });
        // if (apiCallCompleted == false) {
        //   Commonutils.showCustomToastMessageLong('Something Went Wrong Please Login Again', context, 1, 4);
        // }
        print('loginreponse$response');
        print('login response: ${response.statusCode}');
        print('statusCode=====>${response.statusCode}');

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
          // if (isfirst_time == 'True') {
          //   //navigate to next screen
          //   print('navigate to next screen');
          //   Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(
          //         builder: (context) => security_questionsscreen(
          //               userid: '$userid',
          //             )),
          //   );
          // } else {
          employeeId = decodedToken['EmployeeId'];
          SharedPreferences emplyid = await SharedPreferences.getInstance();
          await emplyid.setString("employeeId", employeeId!);

          SharedPreferences userId = await SharedPreferences.getInstance();
          await userId.setString("UserId", userid);
          print('EmployeeIdsaved');

          print('AccessToken: $accessToken');
          print('RefreshToken: $refreshToken');
          print('EmployeeId: $employeeId');
          setState(() {
            _isLoading = false;
            apiCallCompleted = true;
          });

          empolyelogin(employeeId!, isfirst_time, userid);

          // }
        } else {
          FocusScope.of(context).unfocus();
          Commonutils.showCustomToastMessageLong('Invalid Username or Password ', context, 1, 4);
          print('response is not success');
          setState(() {
            apiCallCompleted = false;
            _isLoading = false;
          });

          print('Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ///   apiCallCompleted = false;
        print('Error: $e');
      }
    }
  }

  Future<void> empolyelogin(String empolyeid, String isfirstTime, String userid) async {
    setState(() {
      _isLoading = true;
    });
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
        print('Savedresponse: $responseData');
        await SharedPreferencesHelper.saveCategories(responseData);

        if (isfirstTime == 'True') {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => ChangePasword(
                      userid: userid,
                      newpassword: '',
                      confirmpassword: '',
                    )),
          );
        } else if (isfirstTime == 'False') {
          DateTime loginTime = DateTime.now();
          String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(loginTime);
          print('formattedTimelogin:$formattedTime');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('loginTime', formattedTime);
          SharedPreferencesHelper.putBool(Constants.IS_LOGIN, true);
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const home_screen()),
          );
        }

        // Navigate to the home screen
      } else {
        Commonutils.showCustomToastMessageLong('Error  ${response.statusCode}', context, 1, 4);
        print('response is not success');
        print('Failed to send the request. Status code: ${response.statusCode}');
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
    Future.delayed(const Duration(seconds: 2), () {
      // Navigate to the next page when loading is complete
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const securityscreen()),
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
                      ? const CustomCircularProgressIndicator()
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
                            const SizedBox(height: 2.0),
                            const Text(
                              'HRMS',
                              style: TextStyle(
                                color: Color(0xFFf15f22),
                                fontSize: 26.0,
                                fontFamily: 'Calibri',
                                fontWeight: FontWeight.bold, // Set the font weight to bold
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 25.0, left: 40.0, right: 40.0),
                              child: TextFormField(
                                ///     keyboardType: TextInputType.name,
                                ///
                                keyboardType: TextInputType.name,
                                maxLength: 8,
                                controller: _usernamecontroller,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // Allow only alphanumeric characters
// Allow only alphanumeric characters
                                ],
                                onChanged: (value) {
                                  // Handle onChanged event to ensure the text stays when special characters are entered
                                  if (value.contains(RegExp(r'[^a-zA-Z0-9]'))) {
                                    // If the text contains characters other than alphanumeric, remove those characters
                                    _usernamecontroller.text = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                                    _usernamecontroller.selection = TextSelection.fromPosition(
                                        TextPosition(offset: _usernamecontroller.text.length)); // Keep the cursor at the end
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: 'User Name',
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFf15f22),
                                      ),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        color: Color(0xFFf15f22),
                                      ),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    hintStyle: const TextStyle(
                                      color: Colors.black26, // Label text color
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                    alignLabelWithHint: true,
                                    counterText: ""),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
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
                                    borderSide: const BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFFf15f22),
                                    ),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  hintStyle: const TextStyle(
                                    color: Colors.black26, // Label text color
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                  alignLabelWithHint: true,
                                  counterText: "",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility_off : Icons.visibility,
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
                                maxLength: 25,

                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Calibri',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0, left: 45.0, right: 43.0),
                              child: GestureDetector(
                                onTap: _loadNextPage,
                                // onTap: () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => security_questionsscreen(
                                //               newpassword: '',
                                //               confirmpassword: '',
                                //               userid: '',
                                //             )),
                                //   );
                                // },
                                child: const SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Color(0xFFf15f22), fontSize: 14, fontFamily: 'Calibri'),
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
                              padding: const EdgeInsets.only(top: 35.0, left: 40.0, right: 40.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFf15f22),
                                  borderRadius: BorderRadius.circular(6.0),
                                  // Adjust the border radius as needed
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    validate();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Calibri'),
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

  // Future<List<dynamic>> fetchLookupKeys() async {
  //   final response = await http.get(Uri.parse(baseUrl + lookupkeys));
  //   // final response = await http.get(Uri.parse('http://182.18.157.215/HRMS/API/hrmsapi/Lookup/LookupKeys'));
  //
  //   if (response.statusCode == 200) {
  //     // Parse the JSON response
  //     Map<String, dynamic> jsonData = json.decode(response.body);
  //     Map<String, dynamic> lookups = jsonData['Lookups'];
  //
  //     // Save DayWorkStatus in SharedPreferences
  //     saveDayWorkStatus(lookups['DayWorkStatus']);
  //     saveLeaveReasons(lookups['LeaveReasons']);
  //     // Return the entire response as a List<dynamic>
  //     return json.decode(response.body);
  //   } else {
  //     // If the server did not return a 200 OK response,
  //     // throw an exception.
  //     throw Exception('Failed to load Lookup Keys. Status Code: ${response.statusCode}');
  //   }
  // }
  Future<Map<String, dynamic>> fetchLookupKeys() async {
    final url = Uri.parse(baseUrl + lookupkeys);
    print('LookupdetailsApi: $url');
    // Send the POST request
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      },
    );
    print('Lookupdetailsresponse:$response');
    //  final response = await http.get(Uri.parse(baseUrl + lookupkeys));
    // final url = Uri.parse(baseUrl + getlogin);
    if (response.statusCode == 200) {
      // Parse the JSON response
      Map<String, dynamic> jsonData = json.decode(response.body);
      Map<String, dynamic> lookups = jsonData['Lookups'];

      // Save DayWorkStatus in SharedPreferences
      saveDayWorkStatus(lookups['DayWorkStatus']);
      saveLeaveReasons(lookups['LeaveReasons']);
      saveResignationReason(lookups['ResignationReasons']);
      // Return the entire response as a Map<String, dynamic>
      return jsonData;
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception.
      throw Exception('Failed to load Lookup Keys. Status Code: ${response.statusCode}');
    }
  }

// Function to save DayWorkStatus in SharedPreferences
  Future<void> saveDayWorkStatus(int dayWorkStatus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('dayWorkStatus', dayWorkStatus);
  }

  Future<void> saveResignationReason(int Resignationreq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('ResignationReasons', Resignationreq);
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
class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 50, // Adjust the width as needed
        height: 50, // Adjust the height as needed
        // decoration: BoxDecoration(
        // color: Colors.white,
        //  shape: BoxShape.circle,
        // gradient: LinearGradient(
        //   colors: [
        //     Colors.blue,
        //     Colors.green,
        //   ],
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        // ),
        //),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 33.0,
              width: 33.0,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/cislogo-new.svg',
                height: 30.0,
                width: 30.0,
              ),
            ),
            const CircularProgressIndicator(
              strokeWidth: 3, // Adjust the stroke width of the CircularProgressIndicator
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFFf15f22),
              ), // Color for the progress indicator itself
            ),
          ],
        ),
      ),
    );
  }
}
