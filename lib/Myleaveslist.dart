import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/api%20config.dart';
import 'package:hrms/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Commonutils.dart';
import 'Model Class/EmployeeLeave.dart';

class Myleaveslist extends StatefulWidget {
  const Myleaveslist({super.key});

  @override
  Myleaveslist_screenState createState() => Myleaveslist_screenState();
}

class Myleaveslist_screenState extends State<Myleaveslist>
    with SingleTickerProviderStateMixin {
  String accessToken = '';
  String empolyeid = '';
  String todate = "";
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  // List<Map<String, dynamic>> leaveData = [];
  List<EmployeeLeave> leaveData = [];
  bool isLoading = true;

  late Future<List<EmployeeLeave>> EmployeeLeaveData;
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

  void addItems(List<EmployeeLeave> items) {
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < items.length; i++) {
        Future.delayed(Duration(milliseconds: 200 * i), () {
          _listKey.currentState!.insertItem(i);
        });
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
      //_loadleaveslist(empolyeid);
      EmployeeLeaveData = _loadleaveslist(empolyeid);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  Future<List<EmployeeLeave>> _loadleaveslist(String empolyeid) async {
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

    try {
      final url = Uri.parse('$baseUrl$getleavesapi$empolyeid/$currentYear');
      print('myleavesapi$url');
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
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
          //leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
          //leaveDataexcludingdeleted.clear();
          isLoading = false;
          List<EmployeeLeave> validLeaves = [];
          for (var leave in data) {
            if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
              validLeaves.add(EmployeeLeave.fromJson(leave));
            }
          }
          leaveData = validLeaves;
          addItems(leaveData);
        });
        print('leaveData${leaveData.length}');
        // Process the data as needed
        print('API Response jsonList : $data');
        print('API Response leaveData: $leaveData');
        print('API Response leaveData: ${leaveData.length}');
        return leaveData;
      } else {
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    }
    return [];
  }

/* 
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
            // leaveData = data.map((json) => EmployeeLeave.fromJson(json)).toList();
            List<EmployeeLeave> validLeaves = [];
            data.forEach((leave) {
              if (leave['isDeleted'] == false || leave['isDeleted'] == null) {
                validLeaves.add(EmployeeLeave.fromJson(leave));
              }
            });
            leaveData = validLeaves;
            isLoading = false;
          });
          print('leaveData${leaveData.length}');
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
 */
  @override
  Widget build(BuildContext context) {
    final textscale = MediaQuery.of(context).textScaleFactor;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const home_screen()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: const Color(0xFFf15f22),
              title: const Text(
                'HRMS',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const home_screen()),
                  );
                  // Implement your logic to navigate back
                },
              ),
            ),
            body:
                // isLoading
                //     ? Center(child: CircularProgressIndicator())
                //     : leaveData.isEmpty
                //         ? Center(child: Text('No Leaves Applied!'))
                //         :
                FutureBuilder(
              future: EmployeeLeaveData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CustomCircularProgressIndicator();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  // EmployeeLeave employeeLeave = EmployeeLeaveData
                  List<EmployeeLeave> data = snapshot.data!;
                  if (data.isEmpty) {
                    return Center(
                        child: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: const Text('No Leaves Applied!'),
                    ));
                  } else {
                    return AnimatedList(
                      key: _listKey,
                      initialItemCount: 0,
                      itemBuilder: (context, index, animation) {
                        final leave = leaveData[index];
                        final borderColor = _getStatusBorderColor(leave.status);
                        String? leavetodate;
                        DateTime fromDate = DateTime.parse(leave.fromDate);
                        String leavefromdate =
                            DateFormat('dd MMM yyyy').format(fromDate);
                        if (leave.toDate != null) {
                          todate = leave.toDate!;
                          DateTime toDate = DateTime.parse(todate);
                          leavetodate =
                              DateFormat('dd MMM yyyy').format(toDate);
                        } else {
                          leavetodate = leavefromdate;
                        }
                        // Color backgroundColor = leave.isDeleted == null || leave.isDeleted == false
                        //     ? Color(0xFFfbf2ed) // Default color
                        //     : Colors.grey.shade300;
                        Color backgroundColor = leave.isMarkedForDeletion
                            ? Colors.grey
                                .shade300 // Grey background if marked for deletion
                            : leave.isDeleted == null ||
                                    leave.isDeleted == false
                                ? const Color(0xFFfbf2ed) // Default color
                                : Colors.grey.shade300;

                        DateTime fromDatefordelete =
                            DateFormat('yyyy-MM-dd').parse(leave.fromDate);

                        bool hideDeleteIcon =
                            fromDatefordelete.isBefore(DateTime.now());

                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16.0),
                                border:
                                    Border.all(color: borderColor, width: 1.5),
                              ),
                              child: ListTile(
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 0.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Leave Type: ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          Text(
                                            leave.leaveType,
                                            style: const TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          const Spacer(),
                                          const SizedBox(width: 16.0),
                                          GestureDetector(
                                            onTap: () {
                                              _showConfirmationDialog(leave);
                                            },
                                            // child: leave.isLeaveUsed == true // Check if isLeaveUsed is true
                                            //     ? Container() // Hide the delete icon if isLeaveUsed is true
                                            //     : Icon(
                                            //   CupertinoIcons.delete,
                                            //   color: leave.isDeleted == null || leave.isDeleted == false ? Colors.red : Colors.transparent,
                                            // ),
                                            child: hideDeleteIcon
                                                ? Container()
                                                : const Icon(
                                                    CupertinoIcons.delete,
                                                    color: Colors.red,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Half Day Leave :',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          leave.isHalfDayLeave == null ||
                                                  leave.isHalfDayLeave == false
                                              ? const Text(
                                                  ' No',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Calibri',
                                                  ),
                                                )
                                              : const Text(
                                                  ' Yes',
                                                  style: TextStyle(
                                                    color: Color(0xFF000000),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Calibri',
                                                  ),
                                                )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Leave Status :',
                                              style: TextStyle(
                                                  color: Color(0xFFf37345),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri'),
                                            ),
                                            TextSpan(
                                              text: ' ${leave.status}',
                                              style: TextStyle(
                                                  color: _getStatusColor(
                                                      leave.status),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Calibri'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'From Date: ',
                                              style: TextStyle(
                                                color: Color(0xFFf37345),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            TextSpan(
                                              text: leavefromdate,
                                              style: const TextStyle(
                                                color: Color(0xFF000000),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            const TextSpan(
                                              text: '   To Date:  ',
                                              style: TextStyle(
                                                color: Color(0xFFf37345),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                            TextSpan(
                                              text: {leavetodate} != null
                                                  ? leavetodate
                                                  : leavefromdate,
                                              style: const TextStyle(
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
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Leave Description : ',
                                              style: TextStyle(
                                                  color: Color(0xFFF44614),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri'),
                                            ),
                                            TextSpan(
                                              text: leave.note,
                                              style: const TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Calibri'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Padding(
                                    //   padding: EdgeInsets.only(bottom: 4.0),
                                    //   child: Row(
                                    //     children: [
                                    //       Text('Leave Description :',
                                    //           style: TextStyle(
                                    //               color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri')),
                                    //       Text(
                                    //         '${leave.note}',
                                    //         style:
                                    //             TextStyle(color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri'),
                                    //       )
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
/* 
                    return ListView.builder(
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        final borderColor = _getStatusBorderColor(leave.status);
                        String? leavetodate;
                        DateTime fromDate = DateTime.parse(leave.fromDate);
                        String leavefromdate =
                            DateFormat('dd MMM yyyy').format(fromDate);
                        if (leave.toDate != null) {
                          todate = leave.toDate!;
                          DateTime toDate = DateTime.parse(todate);
                          leavetodate =
                              DateFormat('dd MMM yyyy').format(toDate);
                        } else {
                          leavetodate = leavefromdate;
                        }
                        // Color backgroundColor = leave.isDeleted == null || leave.isDeleted == false
                        //     ? Color(0xFFfbf2ed) // Default color
                        //     : Colors.grey.shade300;
                        Color backgroundColor = leave.isMarkedForDeletion
                            ? Colors.grey
                                .shade300 // Grey background if marked for deletion
                            : leave.isDeleted == null ||
                                    leave.isDeleted == false
                                ? const Color(0xFFfbf2ed) // Default color
                                : Colors.grey.shade300;

                        DateTime fromDatefordelete =
                            DateFormat('yyyy-MM-dd').parse(leave.fromDate);

                        bool hideDeleteIcon =
                            fromDatefordelete.isBefore(DateTime.now());
//MARK: Work
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(16.0),
                              border:
                                  Border.all(color: borderColor, width: 1.5),
                            ),
                            child: ListTile(
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 0.0),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Leave Type: ',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        Text(
                                          leave.leaveType,
                                          style: const TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        const Spacer(),
                                        const SizedBox(width: 16.0),
                                        GestureDetector(
                                          onTap: () {
                                            _showConfirmationDialog(leave);
                                          },
                                          // child: leave.isLeaveUsed == true // Check if isLeaveUsed is true
                                          //     ? Container() // Hide the delete icon if isLeaveUsed is true
                                          //     : Icon(
                                          //   CupertinoIcons.delete,
                                          //   color: leave.isDeleted == null || leave.isDeleted == false ? Colors.red : Colors.transparent,
                                          // ),
                                          child: hideDeleteIcon
                                              ? Container()
                                              : const Icon(
                                                  CupertinoIcons.delete,
                                                  color: Colors.red,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: [
                                        const Text(
                                          'Half Day Leave :',
                                          style: TextStyle(
                                            color: Color(0xFFf37345),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Calibri',
                                          ),
                                        ),
                                        leave.isHalfDayLeave == null ||
                                                leave.isHalfDayLeave == false
                                            ? const Text(
                                                ' No',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri',
                                                ),
                                              )
                                            : const Text(
                                                ' Yes',
                                                style: TextStyle(
                                                  color: Color(0xFF000000),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Calibri',
                                                ),
                                              )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Leave Status :',
                                            style: TextStyle(
                                                color: Color(0xFFf37345),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                          TextSpan(
                                            text: ' ${leave.status}',
                                            style: TextStyle(
                                                color: _getStatusColor(
                                                    leave.status),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'From Date: ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: leavefromdate,
                                            style: const TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          const TextSpan(
                                            text: '   To Date:  ',
                                            style: TextStyle(
                                              color: Color(0xFFf37345),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
                                            ),
                                          ),
                                          TextSpan(
                                            text: {leavetodate} != null
                                                ? leavetodate
                                                : leavefromdate,
                                            style: const TextStyle(
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
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Leave Description : ',
                                            style: TextStyle(
                                                color: Color(0xFFF44614),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                          TextSpan(
                                            text: leave.note,
                                            style: const TextStyle(
                                                color: Color(0xFF000000),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.only(bottom: 4.0),
                                  //   child: Row(
                                  //     children: [
                                  //       Text('Leave Description :',
                                  //           style: TextStyle(
                                  //               color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri')),
                                  //       Text(
                                  //         '${leave.note}',
                                  //         style:
                                  //             TextStyle(color: Color(0xFFF44614), fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Calibri'),
                                  //       )
                                  //     ],
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                   */
                  }
                } else {
                  return const Text('Error: Unable to fetch data');
                }
              },
            )));
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Orange border for 'Pending' status
      case 'Approved':
        return Colors.green.shade600;
      case 'Accepted':
        return Colors.blueAccent;
      case 'Rejected':
        return Colors.red;
      // Add more cases for other statuses if needed
      default:
        return Colors.red; // Red border for other statuses
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green.shade600;
      case 'Accepted':
        return Colors.blueAccent;
      case 'Rejected':
        return Colors.red;

      default:
        return Colors.red;
    }
  }

  void _showConfirmationDialog(EmployeeLeave leave) {
    showDialog(
      // barrierDismissible: false,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Confirmation",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Color(0xFFf15f22),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      // Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      //  Navigator.of(context, rootNavigator: true).pop(context);
                    },
                    child: const Icon(
                      CupertinoIcons.multiply,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/caution-sign.png',
                          height: 30,
                          width: 30,
                        ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        const Text('Are You Sure You Want To Delete?')
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    deleteapi(leave.employeeLeaveId);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                  child: const Text(
                    'No',
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

  String _formatDate(String dateString) {
    // Parse the string into a DateTime object
    DateTime dateTime = DateFormat('dd-mm-yyyy').parse(dateString);

    // Format the DateTime object into the desired format
    return DateFormat('dd-mm-yyyy').format(dateTime);
  }

  Future<void> deleteapi(int leaveid) async {
    setState(() {
      isLoading = true; // Show circular progress indicator
    });
    final url = Uri.parse("$baseUrl$deleteleave/$leaveid");
    print('deleteleaveapi:$url');
    print('API headers:1 $accessToken');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': accessToken,
      };

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        bool isSuccess = responseData['isSuccess'];
        String message = responseData['message'];
        if (isSuccess) {
          int index =
              leaveData.indexWhere((leave) => leave.employeeLeaveId == leaveid);

          if (index != -1) {
            // Mark the item for deletion
            setState(() {
              leaveData[index].isMarkedForDeletion = true;
            });
          }
          Commonutils.checkInternetConnectivity().then((isConnected) {
            if (isConnected) {
              print('The Internet Is Connected');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Myleaveslist()),
              );
            } else {
              Commonutils.showCustomToastMessageLong(
                  'Please Check Your Internet Connection', context, 1, 4);
            }
          });
          // Close dialog
          ///  Navigator.of(context).pop();

          Commonutils.showCustomToastMessageLong(message, context, 0, 4);
        } else {
          Commonutils.showCustomToastMessageLong(message, context, 1, 4);
        }
      } else {
        // Handle error if the request was not successful
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
      print('Error: $error');
    } finally {
      setState(() {
        isLoading = false; // Show circular progress indicator
      });
    }
  }
}

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
              strokeWidth:
                  3, // Adjust the stroke width of the CircularProgressIndicator
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
