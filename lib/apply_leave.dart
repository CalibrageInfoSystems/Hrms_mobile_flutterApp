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
import 'Model Class/LookupDetail.dart';
import 'SharedPreferencesHelper.dart';
import 'api config.dart';

class apply_leave extends StatefulWidget {
  final String buttonName;
  final int lookupDetailId;
  final String employename;

  apply_leave({required this.buttonName, required this.lookupDetailId, required this.employename});

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

  DateTime? selectedToDate;
  bool isButtonEnabled = true;
  bool isTodayHoliday = false;
  bool _isTodayHoliday = false;
  bool isChecked = false;
  List<HolidayResponse> holidayList = [];
  int selectedValue = 0;
  int selectedleaveValue = 0;
  String selectedName = "";
  String selectedleaveName = "";
  int Leavereasonlookupid = 0;
  bool isLoading = false;
  int DayWorkStatus = 0;
  List<LookupDetail> lookupDetails = [];
  int selectedleaveTypeId = -1;
  int defaultLookupDetailId = -1; // Replace with the actual default ID
  String defaultButtonName = 'Select Leave Type'; // Replace with the actual default name
  double availablepls = 0.0;
  double availablecls = 0.0;
  double usedPrivilegeLeavesInYear = 0.0;
  double allottedPrivilegeLeaves = 0.0;
  double usedCasualLeavesInYear = 0.0;
  double allotcausalleaves = 0.0;
  String hintText = 'Reason For Leave';

  // TextEditingController _emailController3 = TextEditingController();
  @override
  void initState() {
    loadAccessToken();
    loademployeid();
    getleavereasonlookupid();
    _loademployeleaves();
    getDayWorkStatus();
    print('buttonName===${widget.buttonName}');
  }

  void _loademployeleaves() async {
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final emplyeid = loadedData["employeeId"];
      final usedprivilegeleavesinyear = loadedData['usedPrivilegeLeavesInYear'];
      final allotedprivilegeleaves = loadedData['allottedPrivilegeLeaves'];
      final usedcausalleavesinmonth = loadedData['usedCasualLeavesInMonth'];
      final usedPrivilegeLeavesInMonth = loadedData['usedPrivilegeLeavesInMonth'];
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
        allotcausalleaves = usdl.toDouble();
        usedPrivilegeLeavesInYear = usedprivilegeleavesinyear.toDouble();
        allottedPrivilegeLeaves = allotedprivilegeleaves.toDouble();
        usedCasualLeavesInYear = usedcasualleavesinyear.toDouble();
        availablepls = allottedPrivilegeLeaves.toDouble() - usedPrivilegeLeavesInYear.toDouble();

        print("Available Privilege Leaves: $availablepls");
        print("availablepls:$availablepls");
        availablecls = allotcausalleaves.toDouble() - usedCasualLeavesInYear.toDouble();

        print('availablecls:$availablecls');
        DateTime now = DateTime.now();
        // Extract the current month from the DateTime object
        int currentMonth = now.month;
        // Print the current month
        print('Current month: $currentMonth');
        //  print('availablecls: $availablecls');
      });
    }
    // availablepls = allottedPrivilegeLeaves - usedPrivilegeLeavesInYear;
    // availablecls = allotcausalleaves - usedCasualLeavesInYear;
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
      firstDate: DateTime(2023),
      lastDate: DateTime(2125),
      // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.

      selectableDayPredicate: (DateTime date) {
        print('Checking date: $date');
        //  final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));

        final saturday = date.weekday == DateTime.saturday; // Change to DateTime.sunday
        final sunday = date.weekday == DateTime.sunday;

        final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);

        // If today is a holiday and the selected date is a past date, allow selecting the holiday date
        if (_isTodayHoliday && isHoliday) {
          return true;
        }

        final isPreviousYear = date.year < DateTime.now().year;

        // Return false if any of the conditions are met
        return !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _fromdateController.text = DateFormat('dd-MM-yyyy').format(selectedDate);
        //  onDateSelected(pickedDate);
      });
    }
  }

  Future<void> _selectToDate() async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    // DateTime initialDate = selectedToDate!;
    DateTime initialDate = selectedToDate ?? DateTime.now();
    // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    // Calculate the minimum selectable date based on the selected "from date"
    DateTime minSelectableDate = selectedDate.add(const Duration(days: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: DateTime(2125),
      // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.
      selectableDayPredicate: (DateTime date) {
        final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));

        final saturday = date.weekday == DateTime.saturday;
        final sunday = date.weekday == DateTime.sunday;

        final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);

        if (_isTodayHoliday && isHoliday && isPastDate) {
          return true;
        }

        final isPreviousYear = date.year < DateTime.now().year;

        // Return false if any of the conditions are met
        return !isPastDate && !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedToDate = pickedDate;
        _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
        //  onDateSelected(pickedDate);
      });
    }
  }

  // Future<void> _selectToDate() async {
  //   DateTime initialDate = selectedToDate ?? DateTime.now();
  //
  //   final DateTime? picked = await showDatePicker(
  //     initialEntryMode: DatePickerEntryMode.calendarOnly,
  //     context: context,
  //     initialDate: initialDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     selectableDayPredicate: (DateTime date) {
  //       // Exclude weekends (Saturday and Sunday)
  //       if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
  //         return false;
  //       }
  //
  //       // Enable only the selected "From" date and the next date
  //       if (selectedDate != null && (date.isAtSameMomentAs(selectedDate) || date.isAfter(selectedDate))) {
  //         return true;
  //       }
  //
  //       return false;
  //     },
  //   );
  //
  //   if (picked != null && picked != selectedToDate) {
  //     setState(() {
  //       selectedToDate = picked;
  //       print('todate$selectedToDate');
  //       _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate);
  //     });
  //   }
  // }0

  void disableButton() {
    setState(() {
      isButtonEnabled = false;
    });
  }

  Future<void> applyleave() async {
    bool isValid = true;
    bool hasValidationFailed = false;
    String fromdate = DateFormat('yyyy-MM-dd').format(selectedDate);
    String? todate = null;
    print('tosendtodate:$selectedToDate');
    if (isChecked)
      todate = DateFormat('yyyy-MM-dd').format(selectedDate);
    else if (selectedToDate != null) todate = DateFormat('yyyy-MM-dd').format(selectedToDate!);

    print('tosendfromdate:$fromdate');
    print('tosendfromdate:$todate');
    if (widget.buttonName == "test") if (isValid && selectedleaveValue == 0) {
      Commonutils.showCustomToastMessageLong('Please Select Leave Type', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (widget.buttonName == "test") if (isValid && selectedleaveValue == 0) {
      Commonutils.showCustomToastMessageLong('Please Select Leave Reason', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL") if (isValid && selectedValue == 0) {
      Commonutils.showCustomToastMessageLong('Please Select Leave Reason', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && _fromdateController.text.isEmpty) {
      Commonutils.showCustomToastMessageLong('Please Select From Date', context, 1, 4);
      isValid = false;
      hasValidationFailed = true;
    }
    if (!isChecked) {
      // if (isValid && _todateController.text.isEmpty) {
      //   Commonutils.showCustomToastMessageLong('Please Select To Date', context, 1, 4);
      //   isValid = false;
      //   hasValidationFailed = true;
      // }
      if (todate != null) {
        if (isValid && todate!.compareTo(fromdate) < 0) {
          Commonutils.showCustomToastMessageLong("To Date is less than From Date", context, 1, 5);
          isValid = false;
          hasValidationFailed = true;
        }
      }
    }
    if (isValid && _leavetext.text.isEmpty) {
      Commonutils.showCustomToastMessageLong('Please Enter the Reason For Leave', context, 1, 6);

      isValid = false;
      hasValidationFailed = true;
    }
    if (selectedleaveName == 'PL' && availablepls <= 0.0) {
      Commonutils.showCustomToastMessageLong('No PLs Available ', context, 1, 6);
      isValid = false;
      hasValidationFailed = true;
    }

    if (selectedleaveName == 'CL' && availablecls <= 0.0) {
      Commonutils.showCustomToastMessageLong('No CLs Available ', context, 1, 6);
      isValid = false;
      hasValidationFailed = true;
    }
    if (isValid && isChecked) {
      // Calculate the difference in days between fromDate and toDate
      //int daysDifference = toDate.difference(fromDate).inDays;
      // if (daysDifference > 2) {
      //   Commonutils.showCustomToastMessageLong(
      //       'You cannot select more than 2 days when the checkbox is checked',
      //       context,
      //       1,
      //       7);
      //   isValid = false;
      //   hasValidationFailed = true;
      // }
    }
    // if (fromdate == null || todate == null) {
    //   Commonutils.showCustomToastMessageLong(
    //       "Please select both FromDate and ToDate", context, 1, 5);
    // } else
    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (isConnected) {
      print('Connected to the internet');
    } else {
      Commonutils.showCustomToastMessageLong('Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      print('Not connected to the internet');
    }
    print('====>$selectedleaveName');
    if (isValid) {
      isLoading = true;
      try {
        final url = Uri.parse(baseUrl + applyleaveapi);
        print('ApplyLeaveUrl: $url');
        final request = {
          "EmployeeId": empolyeid,
          "FromDate": fromdate,
          "ToDate": todate,
          "LeaveTypeId": '${widget.lookupDetailId}',
          "Note": _leavetext.text,
          "AcceptedBy": null,
          "AcceptedAt": null,
          "ApprovedBy": null,
          "ApprovedAt": null,
          "Rejected": null,
          "Comments": null,
          "IsApprovalEscalated": null,
          "URL": "http://182.18.157.215:/",
          "EmployeeName": "${widget.employename}",
          // "getLeaveType": null,
          if (widget.buttonName == "test") ...{
            "GetLeaveType": "$selectedleaveName",
          } else ...{
            "GetLeaveType": "${widget.buttonName}",
          },
          "IsHalfDayLeave": isChecked,
          "LeaveReasonId": selectedValue,
          "IsFromAttendance": false,
          if (widget.buttonName == "test") ...{
            "LeaveTypeId": selectedleaveValue, "LeaveReasonId": selectedleaveValue,
            //   if (selectedleaveName == "WFH")
            //     "leaveReasonId": selectedValue
          }
          // },
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

        // Parse the JSON response

        // // Access the value of isSuccess
        // bool isSuccess = responseMap['isSuccess'];
        // dynamic message = responseMap['message'];
        // String messageresponse = message != null ? message.toString() : "No message provided";

        // Access the value of isSuccess

        if (response.statusCode == 200) {
          Map<String, dynamic> responseMap = json.decode(response.body);

          if (responseMap.containsKey('isSuccess')) {
            bool isSuccess = responseMap['isSuccess'];
            if (isSuccess == true) {
              isLoading = false;
              print('response is success');

              disableButton();
              if (selectedleaveName == "WFH") {
                Commonutils.showCustomToastMessageLong('Successfully WFH has Applied', context, 0, 3);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => home_screen()),
                );
              } else {
                Commonutils.showCustomToastMessageLong('Successfully Leave has Applied', context, 0, 3);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => home_screen()),
                );
              }
            } else {
              print('Apply Leave Failed: ${response.body}');
            }
          } else {
            if (response.body.toLowerCase().contains('invalid token')) {
              // Invalid token scenario
              Commonutils.showCustomToastMessageLong('Invalid Token. Please Login Again.', context, 1, 4);
            } else {
              // Other scenarios with success status code
              // Handle as needed, for example, showing the response message
              String message = responseMap['message'] ?? 'No message provided';
              Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 3);
            }
          }
        } else if (response.statusCode == 520) {
          // Scenario with status code 520
          // Show the response body as a toast
          Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 3);
        } else {
          // Handle other status codes if needed
          print('Failed to send the request. Status code: ${response.statusCode}');
        }

        // if (isSuccess == true) {
        //   isLoading = false;
        //   print('response is success');
        //
        //   disableButton();
        //   if (selectedleaveName == "WFH") {
        //     Commonutils.showCustomToastMessageLong('Successfully WFH has Applied', context, 0, 3);
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => home_screen()),
        //     );
        //   } else {
        //     Commonutils.showCustomToastMessageLong('Successfully Leave has Applied', context, 0, 3);
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => home_screen()),
        //     );
        //   }
        // } else {
        //   // Commonutils.showCustomToastMessageLong(' ${messageresponse}', context, 1, 5);
        //
        //   print('response is not success');
        //   Commonutils.showCustomToastMessageLong('${response.body}', context, 0, 3);
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => home_screen()),
        //   );
        //   print('Failed to send the request. Status code: ${response.statusCode}');
        // }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Color(0xFFf15f22),
              title: Text(
                'HRMS',
                style: TextStyle(color: Colors.white, fontFamily: 'Calibri'),
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
                        if (widget.buttonName == "CL" || widget.buttonName == "PL")
                          Padding(
                            padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                            child: Container(
                              padding: EdgeInsets.all(15.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  color: Color(0xFFf15f22),
                                  width: 1.5,
                                ),
                                color: Colors.white,
                              ),
                              child: Text(
                                "${widget.buttonName}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Calibri',
                                ),
                              ),
                            ),
                          ),
                        if (widget.buttonName == "test")
                          Padding(
                            padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white, // Add white background color
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<int>(
                                    value: selectedleaveTypeId != -1 ? selectedleaveTypeId : defaultLookupDetailId,
                                    iconSize: 30,
                                    icon: null,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedleaveTypeId = value!;
                                        print('selectedTypeCdId==$selectedleaveTypeId');
                                        if (selectedleaveTypeId != -1) {
                                          LookupDetail selectedDetail = lookupDetails.firstWhere((item) => item.lookupDetailId == selectedleaveTypeId);
                                          print("selectedDetail$selectedDetail");
                                          selectedleaveValue = selectedDetail.lookupDetailId;
                                          selectedleaveName = selectedDetail.name;

                                          print("selectedleaveValue==========>$selectedleaveValue");
                                          print("selectedleaveName: $selectedleaveName");
                                          if (selectedleaveName == 'WFH') {
                                            setState(() {
                                              hintText = 'Reason For WFH';
                                            });
                                          } else {
                                            setState(() {
                                              hintText;
                                            });
                                          }

                                          getleavereasontype(Leavereasonlookupid, selectedleaveValue);
                                        } else {
                                          print("==========$selectedleaveValue");
                                          print(selectedleaveValue);
                                          print(selectedleaveName);
                                        }
                                      });
                                    },
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: -1,
                                        child: Text(defaultButtonName),
                                      ),
                                      for (LookupDetail item in lookupDetails)
                                        // if (!(item.name == 'CL' && availablecls == 0.0) && !(item.name == 'PL' && availablepls == 0.0))
                                        // if (item.lookupDetailId != 102 || availablecls != 0.0)
                                        //   if (item.lookupDetailId != 103 || availablepls != 0.0)
                                        if (['CL', 'PL', 'WFH', 'LWP'].contains(item.name))
                                          DropdownMenuItem<int>(
                                            value: item.lookupDetailId,
                                            child: Text(item.name),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL")
                          Padding(
                            padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButton<int>(
                                    value: selectedTypeCdId,
                                    iconSize: 30,
                                    icon: null,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Calibri',
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTypeCdId = value!;
                                        print('selectedTypeCdId==$selectedTypeCdId');
                                        if (selectedTypeCdId != -1) {
                                          selectedValue = dropdownItems[selectedTypeCdId]['lookupDetailId'];
                                          selectedName = dropdownItems[selectedTypeCdId]['name'];

                                          print("selectedValue$selectedValue");
                                          print(selectedName);
                                        } else {
                                          print("==========");
                                          print(selectedValue);
                                          print(selectedName);
                                        }
                                        if (selectedleaveName == 'WFH') {
                                          hintText = 'Reason For WFH';
                                        } else {
                                          hintText;
                                        }
                                      });
                                    },
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: -1,
                                        child: Text('Select Leave Reason'),
                                      ),
                                      ...dropdownItems.asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final item = entry.value;
                                        return DropdownMenuItem<int>(
                                          value: index,
                                          child: Text(
                                            item['name'],
                                            style: TextStyle(fontFamily: 'Calibri'),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (widget.buttonName == "CL" || widget.buttonName == "PL" || selectedleaveName == "CL" || selectedleaveName == "PL")
                          Padding(
                            padding: EdgeInsets.only(left: 10, top: 10.0, right: 0),
                            child: Row(
                              children: [
                                Text(
                                  'Is Halfday Leave?',
                                  style: TextStyle(fontSize: 14, color: Color(0xFFf15f22), fontFamily: 'Calibri', fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 6),
                                Checkbox(
                                  value: isChecked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isChecked = value ?? false; // Use the null-aware operator to handle null values
                                      print('isChecked=== ${isChecked}');
                                    });
                                  },
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: GestureDetector(
                            onTap: () async {
                              _selectDate(isTodayHoliday);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFf15f22), width: 1.5),
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
                                        color: Colors.black54,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Calibri',
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                      // Adjust padding as needed
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.calendar_today,
                                          // Replace with your desired icon
                                          color: Colors.black54,
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
                          padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: Visibility(
                            visible: !isChecked && (widget.buttonName != "CL" && selectedleaveName != "CL"),
                            child: GestureDetector(
                              onTap: () async {
                                if (widget.buttonName == "CL" || selectedleaveName == "CL") {
                                  _selectToCLDate();
                                } else {
                                  _selectToDate();
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFf15f22), width: 1.5),
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.white, // Add white background color
                                ),
                                child: AbsorbPointer(
                                  child: SizedBox(
                                    child: TextFormField(
                                      controller: _todateController,
                                      enabled: !isChecked,
                                      style: TextStyle(
                                        fontFamily: 'Calibri',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'To Date',
                                        hintStyle: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Calibri',
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                        // Adjust padding as needed
                                        suffixIcon: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.calendar_today,
                                            // Replace with your desired icon
                                            color: Colors.black54,
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
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 0, top: 10.0, right: 0),
                          child: GestureDetector(
                            onTap: () async {},
                            child: Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFf15f22), width: 1.5),
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.white,
                              ),
                              child: TextFormField(
                                controller: _leavetext,
                                style: TextStyle(
                                  fontFamily: 'Calibri',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                                maxLines: null,
                                // Set maxLines to null for multiline input
                                decoration: InputDecoration(
                                  hintText: hintText,
                                  hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Calibri',
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0, left: 0.0, right: 0.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFf15f22),
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      print('clickedonaddleave');
                                      setState(() {
                                        isLoading = true;
                                      });
                                      await applyleave();
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                              child: Text(
                                'Add Leave',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Calibri'),
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
        ));
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
          holidayList = data.map((json) => HolidayResponse.fromJson(json)).toList();
        });

        print('Today is a holiday: $holidayList');
        DateTime now = DateTime.now();
        DateTime currentDate = DateTime(now.year, now.month, now.day);
        String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(currentDate);

        for (final holiday in holidayList) {
          DateTime holidayDate = holiday.fromDate;
          String holidaydate = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(holidayDate);

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

  Future<void> _selectToCLDate() async {
    setState(() {
      _isTodayHoliday = isTodayHoliday;
    });

    DateTime initialDate = selectedToDate ?? DateTime.now();

    // Adjust the initial date if it doesn't satisfy the selectableDayPredicate
    if (_isTodayHoliday && initialDate.isBefore(DateTime.now())) {
      initialDate = DateTime.now().add(const Duration(days: 1));
    }

    // Calculate the minimum selectable date based on the selected "from date"
    DateTime minSelectableDate = selectedDate;

    // Find the next available date that is not a holiday or a weekend
    while (_isHolidayOrWeekend(minSelectableDate)) {
      minSelectableDate = minSelectableDate.add(const Duration(days: 1));
    }
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(Duration(days: 0)),
      lastDate: minSelectableDate,
      // Assuming you have a variable '_isTodayHoliday' indicating whether today is a holiday or not.
      selectableDayPredicate: (DateTime date) {
        final isPastDate = date.isBefore(DateTime.now().subtract(Duration(days: 1)));

        final saturday = date.weekday == DateTime.saturday;
        final sunday = date.weekday == DateTime.sunday;

        final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);

        if (_isTodayHoliday && isHoliday && isPastDate) {
          return true;
        }

        final isPreviousYear = date.year < DateTime.now().year;

        // Return false if any of the conditions are met
        return !isPastDate && !saturday && !sunday && !isHoliday && !isPreviousYear && date.year >= DateTime.now().year;
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedToDate = pickedDate;
        _todateController.text = DateFormat('dd-MM-yyyy').format(selectedToDate!);
        //  onDateSelected(pickedDate);
      });
    }
  }

  Future<void> getleavereasontype(int leavereasonlookupid, int lookupDetailId) async {
    final url = Uri.parse(baseUrl + getdropdown + '$leavereasonlookupid' + '/$lookupDetailId');
    print('leave reson $url');
    final response = await http.get((url));
    // final url =  Uri.parse(baseUrl+GetHolidayListByBranchId+'$branchId');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dropdownItems = data;
      });
    } else {
      print('Failed to fetch data');
    }
  }

  Future<void> getleavereasonlookupid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      Leavereasonlookupid = prefs.getInt('leavereasons') ?? 0;
      getleavereasontype(Leavereasonlookupid, widget.lookupDetailId);
    });
    print("Leavereasonlookupid:$Leavereasonlookupid");
    // Provide a default value if not found
  }

  bool _isHolidayOrWeekend(DateTime date) {
    final isSaturday = date.weekday == DateTime.saturday;
    final isSunday = date.weekday == DateTime.sunday;

    final isHoliday = holidayList.any((holiday) => date.year == holiday.fromDate.year && date.month == holiday.fromDate.month && date.day == holiday.fromDate.day);

    return isSaturday || isSunday || isHoliday;
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
        lookupDetails = jsonData.map((data) => LookupDetail.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load data. Status Code: ${response.statusCode}');
    }
  }
}
