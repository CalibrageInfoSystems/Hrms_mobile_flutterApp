import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/personal_details.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Commonutils.dart';
import 'Model Class/EmployeeLeave.dart';
import 'SharedPreferencesHelper.dart';

class Myleaveslist extends StatefulWidget {
  @override
  Myleaveslist_screenState createState() => Myleaveslist_screenState();
}

class Myleaveslist_screenState extends State<Myleaveslist> {
  String accessToken = '';
  String empolyeid = '';
  String todate = "";
  // List<Map<String, dynamic>> leaveData = [];
  List<EmployeeLeave> leaveData = [];
  bool isLoading = true;

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
        loademployeid();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      _loadleaveslist(empolyeid);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  void _loadleaveslist(String empolyeid) async {
    // Specify the API endpoint
    // final String apiUrl =
    //     'http://182.18.157.215/HRMS/API/hrmsapi/Attendance/GetLeavesForSelfEmployee/' + '$empolyeid';
    // print('API apiUrl: $apiUrl');

    // final url = Uri.parse(baseUrl + getleavesapi + empolyeid);
    // print('myleavesapi$url');
    // Check if accessToken is not null before using it

    // Get the current date and time
    DateTime now = DateTime.now();

    // Extract the current year
    int currentYear = now.year;

    // Print the current year
    print('Current Year: $currentYear');

    if (accessToken != null) {
      try {
        final url = Uri.parse(baseUrl + getleavesapi + empolyeid + '/$currentYear');
        print('myleavesapi$url');
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        };
        print('API headers: $accessToken');

        final response = await http.get(url, headers: headers);
        print('response body : ${response.body}');
        //  final response = await http.get(Uri.parse(url), headers: headers);
        print("responsecode ${response.statusCode}");
        // Check if the request was successful (status code 200)
        if (response.statusCode == 200) {
          // Parse the JSON response
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
            isLoading = false;
          });

          // Process the data as needed
          print('API Response jsonList : $data');
          print('API Response leaveData: $leaveData');
          print('API Response leaveData: ${leaveData.length}');
        } else {
          Commonutils.showCustomToastMessageLong('Error: ${response.body}', context, 1, 4);
          // Handle error if the request was not successful
          print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        }
      } catch (error) {
        // Handle any exceptions that occurred during the request
        print('Error: $error');
      }
    } else {
      // Handle the case where accessToken is null
      print('Error: accessToken is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFFf15f22),
            title: Text(
              'HRMS',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : leaveData.isEmpty
                  ? Center(child: Text('No Leaves Applied!'))
                  : ListView.builder(
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        final borderColor = _getStatusBorderColor(leave.status!);
                        String? leavetodate;
                        DateTime from_date = DateTime.parse(leave.fromDate);
                        String leavefromdate = DateFormat('dd-MM-yyyy').format(from_date);
                        if (leave.toDate != null) {
                          todate = leave.toDate!;
                          DateTime to_date = DateTime.parse(todate);
                          leavetodate = DateFormat('dd-MM-yyyy').format(to_date);
                        } else {
                          leavetodate = leavefromdate;
                        }
                        Color backgroundColor = leave.isDeleted == null || leave.isDeleted == false
                            ? Color(0xFFfbf2ed) // Default color
                            : Colors.grey.shade300;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(color: borderColor, width: 1.5),
                            ),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Leave Type: ',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        Text(
                                          '${leave.leaveType}',
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(width: 16.0),
                                        // Adjust the spacing between Leave Type and Leave Status
                                        Container(
                                          padding: EdgeInsets.all(8.0),

                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color: borderColor, // Set the border color
                                              width: 2.0, // Set the border width
                                            ),
                                          ),
                                          // decoration: BoxDecoration(
                                          //   color: Colors.white,
                                          //   borderRadius: BorderRadius.circular(8.0),
                                          // ),
                                          child: Text(
                                            '${leave.status}',
                                            style: TextStyle(
                                              color: borderColor, // Border color of the card
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Half Day Leave :',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        leave.isHalfDayLeave == null || leave.isHalfDayLeave == false
                                            ? Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              )
                                            : Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'From Date: ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${leavefromdate}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: '   To Date:  ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: {leavetodate} != null ? leavetodate : '${leavefromdate}',
                                            style: TextStyle(
                                              color: Color(0xFF000000),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              fontFamily: 'Calibri',
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Leave Description : ',
                                            style: TextStyle(color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri'),
                                          ),
                                          TextSpan(
                                            text: '${leave.note}',
                                            style: TextStyle(color: Color(0xFF000000), fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Calibri'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ));
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Orange border for 'Pending' status
      case 'Approved':
        return Colors.green.shade600; // Green border for 'Approved' status
      // Add more cases for other statuses if needed
      default:
        return Colors.red; // Red border for other statuses
    }
  }

  String _formatDate(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateFormat('dd-mm-yyyy').parse(dateString);

    // Format the DateTime object into the desired format
    return DateFormat('dd-mm-yyyy').format(dateTime);
  }
}
