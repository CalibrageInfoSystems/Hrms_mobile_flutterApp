import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Commonutils.dart';
import 'package:hrms/home_screen.dart';
import 'package:hrms/leaves_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'Model Class/HolidayResponse.dart';
import 'api config.dart';

class apply_leave extends StatefulWidget {
  final String buttonName;
  final int lookupDetailId;

  apply_leave({required this.buttonName, required this.lookupDetailId});
  @override
  _apply_leaveeState createState() => _apply_leaveeState();
}

class _apply_leaveeState extends State<apply_leave> {
  int selectedTypeCdId = -1;
  List<dynamic> dropdownItems = [];
  String accessToken = '';
  String? empolyeid;
  TextEditingController _fromdateController = TextEditingController();
  TextEditingController _todateController = TextEditingController();
  TextEditingController _leavetext = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool isButtonEnabled = true;
  bool isTodayHoliday = false;
  bool _isTodayHoliday = false;
  List<HolidayResponse> holidayList = [];
  // TextEditingController _emailController3 = TextEditingController();
  @override
  void initState() {
    loadAccessToken();
    loademployeid();
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      fetchHolidayList(2023);
    });
    print("accestokeninapplyleave:$accessToken");
  }

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  Future<void> _selectDate(bool isTodayHoliday) async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime initialDate = selectedDate;

    // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2125),
      // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.

      selectableDayPredicate: (DateTime date) {
        final isPastDate =
            date.isBefore(DateTime.now().subtract(Duration(days: 1)));

        final saturday =
            date.weekday == DateTime.saturday; // Change to DateTime.sunday
        final sunday = date.weekday == DateTime.sunday;

        final isHoliday = holidayList.any((holiday) =>
            date.year == holiday.fromDate.year &&
            date.month == holiday.fromDate.month &&
            date.day == holiday.fromDate.day);

        // If today is a holiday and the selected date is a past date, allow selecting the holiday date
        if (_isTodayHoliday && isHoliday && isPastDate) {
          return true;
        }

        final isPreviousYear = date.year < DateTime.now().year;

        // Return false if any of the conditions are met
        return !isPastDate &&
            !saturday &&
            !sunday &&
            !isHoliday &&
            !isPreviousYear &&
            date.year >= DateTime.now().year;
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _fromdateController.text =
            DateFormat('dd-MM-yyyy').format(selectedDate);
        //  onDateSelected(pickedDate);
      });
    }
  }
  // Future<void> _selectDate() async {
  //   final DateTime? picked = await showDatePicker(
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     selectableDayPredicate: (DateTime date) {
  //       // Exclude weekends (Saturday and Sunday)
  //       return date.weekday != DateTime.saturday &&
  //           date.weekday != DateTime.sunday;
  //     },
  //   );
  //
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //       print('fromdate$selectedDate');
  //       _fromdateController.text =
  //           DateFormat('dd-MM-yyyy').format(selectedDate);
  //     });
  //   }
  // }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: selectedToDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        // Exclude weekends (Saturday and Sunday)
        return date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != selectedToDate) {
      setState(() {
        selectedToDate = picked;
        print('todate$selectedToDate');
        _todateController.text =
            DateFormat('dd-MM-yyyy').format(selectedToDate);
      });
    }
  }

  void disableButton() {
    setState(() {
      isButtonEnabled = false;
    });
  }

  Future<void> applyleave() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String todate = DateFormat('yyyy-MM-dd').format(selectedToDate);
    // if (isValid && selectedTypeCdId == -1) {
    //   Commonutils.showCustomToastMessageLong(
    //       'Please Select Leave Type', context, 1, 4);
    //   isValid = false;
    //   hasValidationFailed = true;
    // }

    print('tosendfromdate:$fromdate');
    print('tosendtodate:$todate');
    if (isValid && _fromdateController.text.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Select From Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }

    if (isValid && _todateController.text.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Select to Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (todate.compareTo(fromdate) < 0) {
      Commonutils.showCustomToastMessageLong(
          "To Date is less than From Date", context, 1, 5);
    }
    if (isValid && _leavetext.text.isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter the Reason to Apply Leave', context, 1, 6);
      isValid = false;
      hasValidationFailed = true;
    }
    // if (fromdate == null || todate == null) {
    //   Commonutils.showCustomToastMessageLong(
    //       "Please select both FromDate and ToDate", context, 1, 5);
    // } else
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }

    if (isValid) {
      disableButton();
      try {
        final url = Uri.parse(baseUrl + applyleaveapi);
        print('ApplyLeaveUrl: $url');
        final request = {
          "employeeId": empolyeid,
          "fromDate": fromdate,
          "toDate": todate,
          "leaveTypeId": '${widget.lookupDetailId}',
          "note": _leavetext.text,
          "acceptedBy": null,
          "acceptedAt": null,
          "approvedBy": null,
          "approvedAt": null,
          "rejected": null,
          "comments": null,
          "isApprovalEscalated": null,
          "url": null,
          "employeeName": null,
          "getLeaveType": null
        };
        // final headers = {
        //   'Authorization': '$accessToken',
        // };
        // Map<String, String> _header = {
        //   'Authorization': '$accessToken',
        // };
        // String at = accessToken;
        // print('Request Headers: $_header');
        print('Request Body: ${json.encode(request)}');

        final response = await http.post(
          url,
          body: json.encode(request),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$accessToken',
          },
        );
        //  print('access: $at');
        // if (response.body == "Server errorNullable object must have a value.") {
        //   Commonutils.showCustomToastMessageLong(
        //       'Leave Applied', context, 0, 3);
        // }
        print('Applyresponse: ${response.body}');

        if (response.statusCode == 200) {
          print('response is success');
          Commonutils.showCustomToastMessageLong(
              'SuccessFully Leave has Applied', context, 0, 3);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => home_screen()),
          );
        } else {
          print('response is not success');
          // Commonutils.showCustomToastMessageLong(
          //     '${response.body}', context, 0, 3);
          print(
              'Failed to send the request. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => home_screen()),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/background_layer_2.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content inside a SingleChildScrollView
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                      width: MediaQuery.of(context).size.width,
                      // height: MediaQuery.of(context).size.height,
                      child: Text(
                        'Leave Request',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFFf15f22),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Calibri',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Color(0xFFf15f22),
                            width: 1.5,
                          ),
                          color: Colors.white, // Add white background color
                        ),
                        child: DropdownButtonHideUnderline(
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButton<int>(
                              value: selectedTypeCdId,
                              iconSize: 30,
                              icon: null,
                              style: TextStyle(
                                color: Colors.black26,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Calibri',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedTypeCdId = value!;
                                });
                              },
                              items: [
                                DropdownMenuItem<int>(
                                  value: -1,
                                  child: Text(
                                      ' ${widget.buttonName}'), // Static text
                                ),
                                // DropdownMenuItem<int>(
                                //   value: -1,
                                //   child: Text('Select Leave Type'), // Static text
                                // ),
                                // if (dropdownItems.length > 2)
                                //   ...dropdownItems.sublist(2).map((item) {
                                //     return DropdownMenuItem<int>(
                                //       value: item['lookupDetailId'],
                                //       child: Text(item['name']),
                                //     );
                                //   }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 20.0, right: 0),
                      child: GestureDetector(
                        onTap: () async {
                          _selectDate(isTodayHoliday);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFf15f22), width: 1.5),
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white, // Add white background color
                          ),
                          child: AbsorbPointer(
                            child: SizedBox(
                              child: TextFormField(
                                controller: _fromdateController,
                                style: TextStyle(
                                  fontFamily: 'Calibri',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'From Date',
                                  hintStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  // Adjust padding as needed
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.calendar_today,
                                      // Replace with your desired icon
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 20.0, right: 0),
                      child: GestureDetector(
                        onTap: () async {
                          _selectToDate();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFf15f22), width: 1.5),
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white, // Add white background color
                          ),
                          child: AbsorbPointer(
                            child: SizedBox(
                              child: TextFormField(
                                controller: _todateController,
                                style: TextStyle(
                                  fontFamily: 'Calibri',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'To Date',
                                  hintStyle: TextStyle(
                                    color: Colors.black26,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  // Adjust padding as needed
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.calendar_today,
                                      // Replace with your desired icon
                                      color: Colors.grey,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 0, top: 20.0, right: 0),
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          height: 180,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFf15f22), width: 1.5),
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white, // Add white background color
                          ),
                          // child: SizedBox(
                          child: TextFormField(
                            controller: _leavetext,
                            style: TextStyle(
                              fontFamily: 'Calibri',
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Reason For Leave',
                              hintStyle: TextStyle(
                                color: Colors.black26,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Calibri',
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ), // Adjust padding as needed

                              border: InputBorder.none,
                            ),
                          ),
                          // ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFf15f22),
                          borderRadius: BorderRadius.circular(6.0),
                          // Adjust the border radius as needed
                        ),
                        child: ElevatedButton(
                          onPressed: isButtonEnabled
                              ? () async {
                                  print('clickedonaddleave');
                                  applyleave();
                                }
                              : null,
                          child: Text(
                            'Add Leave',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'hind_semibold',
                            ),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchHolidayList(int year) async {
    // final url = Uri.parse(
    //     'http://182.18.157.215/SaloonApp/API/GetHolidayListByBranchId/$branchId');
    final url = Uri.parse(baseUrl + GetHolidayList + '$year');
    print('url========>: $url');
    print('API headers:1 $accessToken');
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': '$accessToken',
      };
      print('API headers:2 $accessToken');

      final response = await http.get(url, headers: headers);
      print('response body : ${response.body}');
      //  final response = await http.get(Uri.parse(url), headers: headers);
      print("responsecode ${response.statusCode}");
      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          holidayList =
              data.map((json) => HolidayResponse.fromJson(json)).toList();
        });

        print('Today is a holiday: $holidayList');
        DateTime now = DateTime.now();
        DateTime currentDate = DateTime(now.year, now.month, now.day);
        String formattedDate =
            DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);

        for (final holiday in holidayList) {
          DateTime holidayDate = holiday.fromDate;
          String holidaydate =
              DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(holidayDate);

          if (formattedDate == holidaydate) {
            isTodayHoliday = true;
            print('Today is a holiday: $formattedDate');
            break; // If a match is found, exit the loop
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
}
