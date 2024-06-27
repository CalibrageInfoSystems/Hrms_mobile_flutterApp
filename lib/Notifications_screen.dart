import 'dart:convert';
import 'package:hrms/NotificationReply.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/Commonutils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'Notification_Model.dart';
import 'UpComingbdays.dart';
import 'api config.dart';
import 'home_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

// const CURVE_HEIGHT = 320.0;
// const AVATAR_RADIUS = CURVE_HEIGHT * 0.23;
// const AVATAR_DIAMETER = AVATAR_RADIUS * 2.5;

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  _Notifications_screenState createState() => _Notifications_screenState();
}

class _Notifications_screenState extends State<Notifications> {
  String? accessToken;
  String empolyeid = '';
  List<Notification_model> NotificationData = [];
  List<Notification_model> birthdayNotifications = [];
  List<UpComingbirthdays> upcoming_model = [];
  List<bool> isExpanded = [false, false, false, false];
  Notification_model? empData;
  List<NotificationReply> notificationreplylist = [];
  String? userid;
  bool isWishesSent = false;
  bool isLoginUserBirthDay = false;
  TextEditingController messagecontroller = TextEditingController();
  int? emplyeidfromapi;
  int? loggedInEmployeeId;
  bool shouldHideSendWishesButton = false;
  // Set<int> wishedEmployeeIds = {}; // Define this in your widget's state or as a global variable
  Set<int> repliedNotificationIds =
      {}; // Define this in your widget's state or as a global variable

  @override
  void initState() {
    super.initState();
    // loadAccessToken();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');

        loadAccessToken();
        loademployeid();
        loadUserid();
      } else {
        print('The Internet Is not  Connected');
      }
    });
  }

  void updateIsExpandedList(int index) {
    setState(() {
      isExpanded = List.generate(isExpanded.length, (i) => i == index);
    });
  }

  Future<void> loademployeid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empolyeid = prefs.getString("employeeId") ?? "";
      loggedInEmployeeId = int.tryParse(empolyeid); // Store as integer
      print('empId: $empolyeid');
      print('empId loggedInEmployeeId: $loggedInEmployeeId');
      GetNotificationsRepliesByEmployes(accessToken!, loggedInEmployeeId!);
      GetUpcomingbdays(accessToken!);
    });
    print("empolyeidinapplyleave:$empolyeid");
  }

  Future<void> loadAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accessToken = prefs.getString("accessToken") ?? "";
      GetNotifications(accessToken!);
    });
    print("accestoken:$accessToken");
  }

  Future<void> loadUserid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userid = prefs.getString("UserId") ?? "";
    });
    print("UserId:$userid");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // AbcdNavigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (context) => personal_details()),
          // ); // Navigate to the previous screen
          // Prevent default back navigation behavior
          return true;
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                  backgroundColor: const Color(0xFFf15f22),
                  title: const Text(
                    'Notifications',
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
                  )),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          CustomExpansionTile(
                            title: const Text(
                              "HR Notifications",
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                  right: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                  bottom: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ), //MARK: Hr notifications
                                child: NotificationData.isEmpty
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                            top: 5, bottom: 2.5),
                                        color: const Color(0xFFf15f22)
                                            .withOpacity(0.1),
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'There are no hr notifications',
                                                style: TextStyle(
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: NotificationData.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final notification =
                                              NotificationData[index];
                                          print(
                                              'messagefromapi:${notification.message}');

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            1.9,
                                                    child: Text(
                                                      notification.message,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  Text(
                                                    formatTimeAgo(
                                                        notification.createdAt),
                                                    style: const TextStyle(
                                                        color: Colors.grey),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            initiallyExpanded: isExpanded[0],
                            onTap: () {
                              setState(() {
                                isExpanded[0] = !isExpanded[0];
                                isExpanded[1] = false;
                                isExpanded[2] = false;
                                isExpanded[3] = false;
                              });
                            },
                          ),
                          CustomExpansionTile(
                            title: const Text(
                              "Today Birthdays",
                              style: TextStyle(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFFf15f22)
                                        .withOpacity(0.8)),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: birthdayNotifications.isEmpty
                                    ? Container(
                                        margin: const EdgeInsets.all(5),
                                        color: const Color(0xFFf15f22)
                                            .withOpacity(0.1),
                                        padding: const EdgeInsets.all(8.0),
                                        child: const Text(
                                          'There are no Birthdays',
                                          style: TextStyle(color: Colors.black),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: birthdayNotifications.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          final notification =
                                              birthdayNotifications[index];
                                          bool hideButton =
                                              shouldHideSendWishesButton ||
                                                  repliedNotificationIds
                                                      .contains(notification
                                                          .notificationId);
                                          print(
                                              'empData2: ${notification.code}');
                                          print(
                                              'empData2: ${notification.employeeName}');
                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Text(
                                                  notification.code!,
                                                  style: const TextStyle(
                                                      color: Colors
                                                          .lightBlueAccent),
                                                ),
                                                const SizedBox(width: 7.0),
                                                Expanded(
                                                  child: Text(
                                                    notification.employeeName,
                                                    style: const TextStyle(
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: !hideButton,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      showdialogmethod(
                                                          notification
                                                              .notificationId,
                                                          notification
                                                              .employeeName);
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                                0xFFf15f22)
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      child: empData!.code ==
                                                              notification.code
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                Image.asset(
                                                                  'assets/cakedecoration.png',
                                                                  width: 15,
                                                                  height: 21,
                                                                  color: const Color(
                                                                      0xFFf15f22),
                                                                ),
                                                                const SizedBox(
                                                                    width: 5),
                                                                const Icon(
                                                                  Icons
                                                                      .send_outlined,
                                                                  size: 18,
                                                                  color: Color(
                                                                      0xFFf15f22),
                                                                ),
                                                              ],
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            initiallyExpanded: isExpanded[1],
                            onTap: () {
                              setState(() {
                                isExpanded[1] = !isExpanded[1];
                                isExpanded[0] = false;
                                isExpanded[2] = false;
                                isExpanded[3] = false;
                              });
                              // updateIsExpandedList(1);
                            },
                            // initiallyExpanded:
                            //     getNotificationResult == birthdayNotification,
                          ),
                          CustomExpansionTile(
                            title: const Text(
                              "Up Coming Birthdays",
                              maxLines: 2,
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                            content: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  left: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                  right: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                  bottom: BorderSide(
                                    color: const Color(0xFFf15f22).withOpacity(
                                        0.8), // Adjust the color as needed
                                    width: 1.0, // Adjust the width as needed
                                  ),
                                ),
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: upcoming_model.isEmpty
                                    ? Container(
                                        margin: const EdgeInsets.only(
                                            top: 5, bottom: 2.5),
                                        color: const Color(0xFFf15f22)
                                            .withOpacity(0.1),
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'There are no Up Coming Birthdays',
                                                style: TextStyle(
                                                    color: Colors.black),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: upcoming_model.length,
                                        shrinkWrap: true,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final notification =
                                              upcoming_model[index];
                                          print(
                                              'employeeNamefromapi${notification.employeeName}');

                                          String formattedDate =
                                              DateFormat('dd MMM').format(
                                                  notification.originalDOB);

                                          return Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, bottom: 2.5),
                                            color: const Color(0xFFf15f22)
                                                .withOpacity(0.1),
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Image.asset(
                                                  //   'assets/cake.png',
                                                  //   width: 20,
                                                  //   height: 20,
                                                  //   color: Color(0xFFf15f22),
                                                  // ),
                                                  // SizedBox(
                                                  //   width: 10.0,
                                                  // ),
                                                  Container(
                                                    //  padding: EdgeInsets.all(3.0),
                                                    // decoration: BoxDecoration(
                                                    //     color: Colors.lightBlueAccent, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                                    child: Text(
                                                      notification.employeeCode,
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .lightBlueAccent),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 7.0,
                                                  ),
                                                  // Container(
                                                  //   width: MediaQuery.of(context).size.width / 2,
                                                  //   child: Text(
                                                  //     notification.employeeName,
                                                  //     style: TextStyle(color: Colors.black),
                                                  //     maxLines: 1,
                                                  //     overflow: TextOverflow.ellipsis,
                                                  //     textAlign: TextAlign.start,
                                                  //   ),
                                                  // ),
                                                  Expanded(
                                                    child: Text(
                                                      notification.employeeName,
                                                      style: const TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),

                                                  // SizedBox(
                                                  //   width: 10.0,
                                                  // ),
                                                  Container(
                                                    //width: MediaQuery.of(context).size.width / 1.9,
                                                    child: Text(
                                                      formattedDate,
                                                      style: const TextStyle(
                                                          color: Colors.grey),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.end,
                                                    ),
                                                  ),
                                                  // if (emplyeidfromapi == empolyeid)
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            initiallyExpanded: isExpanded[2],
                            onTap: () {
                              setState(() {
                                isExpanded[2] = !isExpanded[2];
                                isExpanded[0] = false;
                                isExpanded[1] = false;
                                isExpanded[3] = false;
                              });
                              // updateIsExpandedList(2);
                            },
                            // initiallyExpanded:
                            //     getNotificationResult == upComingNotifications,
                          ),
                          notificationreplylist.isNotEmpty
                              ? CustomExpansionTile(
                                  title: const Text(
                                    "Greetings",
                                    maxLines: 2,
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  content: Container(
                                    // decoration: BoxDecoration(
                                    //   color: Colors.white,
                                    // ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        left: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                        right: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                        bottom: BorderSide(
                                          color: const Color(0xFFf15f22)
                                              .withOpacity(
                                                  0.8), // Adjust the color as needed
                                          width:
                                              1.0, // Adjust the width as needed
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.only(
                                          left: 5.0, right: 5.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: notificationreplylist.isEmpty
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, bottom: 2.5),
                                              color: const Color(0xFFf15f22)
                                                  .withOpacity(0.1),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListView.builder(
                                              itemCount:
                                                  notificationreplylist.length,
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                final notification =
                                                    notificationreplylist[
                                                        index];
                                                print(
                                                    'messagefromapi:${notification.message}');

                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 5, bottom: 2.5),
                                                  color: const Color(0xFFf15f22)
                                                      .withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    // padding: EdgeInsets.only(left: 0, top: 0, bottom: 0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                'Birthday Wishes from ${notification.employeeName}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 7.0,
                                                            ),
                                                            Container(
                                                              child: Text(
                                                                notification
                                                                    .code,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .lightBlueAccent),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 7.0,
                                                        ),
                                                        Container(
                                                          child: Text(
                                                            notification
                                                                .message,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ),
                                  initiallyExpanded: isExpanded[3],
                                  onTap: () {
                                    setState(() {
                                      isExpanded[3] = !isExpanded[3];
                                      isExpanded[0] = false;
                                      isExpanded[1] = false;
                                      isExpanded[2] = false;
                                    });
                                  },
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    )
                  ],
                ),
                //  ),
              ),
            )));
  }

  String formatTimeAgo(String createdAt) {
    DateTime createdTime = DateTime.parse(createdAt);
    return timeago.format(createdTime);
  }

  Future<void> sendgreetings(int notificationid, String empname) async {
    print('notificationid$notificationid');
    if (messagecontroller.text.trim().isEmpty) {
      Commonutils.showCustomToastMessageLong(
          'Please Enter Wishes', context, 1, 4);
      return;
    }

    bool isConnected = await Commonutils.checkInternetConnectivity();
    if (!isConnected) {
      Commonutils.showCustomToastMessageLong(
          'Please Check the Internet Connection', context, 1, 4);
      FocusScope.of(context).unfocus();
      return;
    }

    DateTime currentTime = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentTime);
    String message = messagecontroller.text.trim().toString();

    try {
      final url = Uri.parse(baseUrl + sendgreeting);
      final request = {
        "createdAt": formattedDate,
        "updatedAt": formattedDate,
        "createdBy": "$userid",
        "updatedBy": "$userid",
        "notificationReplyId": 0,
        "notificationId": notificationid,
        "message": message,
        "employeeId": empolyeid,
        "isActive": true
      };

      final response = await http.post(
        url,
        body: json.encode(request),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$accessToken',
        },
      );
      print('requestobject ${json.encode(request)}');
      if (response.statusCode == 200) {
        Map<String, dynamic> responseMap = json.decode(response.body);
        if (responseMap['isSuccess'] == true) {
          // Commonutils.showCustomToastMessageLong('${responseMap['message']}', context, 1, 4);
          Commonutils.showCustomToastMessageLong(
              'Wishes Sent to $empname Successfully', context, 0, 4);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Notifications()),
          );
        } else {
          Commonutils.showCustomToastMessageLong(
              '${responseMap['message']}', context, 1, 4);
        }
      } else if (response.statusCode == 520) {
        Commonutils.showCustomToastMessageLong(response.body, context, 1, 3);
      } else {
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> GetNotifications(String accessToken) async {
    final url = Uri.parse(baseUrl + getnotification);
    print('GetNotifications: $url');
    try {
      print('API headers: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('response body: ${response.body}');
      print('response code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed response: $jsonData');

        List<Notification_model> notifimodel =
            jsonData.map((json) => Notification_model.fromJson(json)).toList();
        print('Notification models: $notifimodel');

        setState(() {
          NotificationData = notifimodel
              .where((notification) =>
                  notification.messageType.toLowerCase() != 'birthday')
              .toList();

          birthdayNotifications = notifimodel
              .where((notification) =>
                  notification.messageType.toLowerCase() == 'birthday')
              .toList();

          checkNotificationsAndOpenExpandedView(
              NotificationData, birthdayNotifications);
        });

        for (var notification in birthdayNotifications) {
          print('EmployeeIDinBirthday${notification.employeeId}');
          GetNotificationsReplies(accessToken, notification.employeeId);
        }
      } else {
        // Handle error if the request was not successful
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
    }
  }

/* 
  Future<void> GetNotifications(String accessToken) async {
    final url = Uri.parse(baseUrl + getnotification);
    print('GetNotifications: $url');
    try {
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Authorization': '$accessToken',
      // };
      print('API headers: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('response body: ${response.body}');
      print('response code: ${response.statusCode}');

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print('Parsed response: $jsonData');

        List<Notification_model> notifimodel =
            jsonData.map((json) => Notification_model.fromJson(json)).toList();
        print('Notification models: $notifimodel');

        NotificationData = notifimodel
            .where((notification) =>
                notification.messageType.toLowerCase() != 'birthday')
            .toList();

        birthdayNotifications = notifimodel
            .where((notification) =>
                notification.messageType.toLowerCase() == 'birthday')
            .toList();
        getNotificationResult = checkNotificationsAndOpenExpandedView(
            NotificationData, birthdayNotifications);
        print('getNotificationResult: $getNotificationResult');
        /*   print('xxx getNotificationResult: $getNotificationResult');
        print(
            'xxx getNotificationResult hr: ${getNotificationResult == hrNotification}');
        print(
            'xxx getNotificationResult birthday: ${getNotificationResult == birthdayNotification}');
        print(
            'xxx getNotificationResult upcoming: ${getNotificationResult == upComingNotifications}'); */
        for (var notification in birthdayNotifications) {
          print('EmployeeIDinBirthday${notification.employeeId}');
          GetNotificationsReplies(accessToken, notification.employeeId);
        }
        setState(() {});
      } else {
        // Handle error if the request was not successful
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the reque
    }
  }
 */
  Future<void> GetNotificationsReplies(
      String accessToken, int employeeId) async {
    final url = Uri.parse('$baseUrl$getnotificationreplies$employeeId');
    print('GetNotificationsReplies: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );

      print('response body for replies: ${response.body}');
      print('response code for replies: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        setState(() {
          // Check if any employeeId from jsonData matches loggedInEmployeeId
          bool isMatchingEmployeeId = jsonData
              .any((reply) => reply['employeeId'] == loggedInEmployeeId);

          if (isMatchingEmployeeId) {
            // If any employeeId matches, add notification IDs to repliedNotificationIds
            for (var reply in jsonData) {
              repliedNotificationIds.add(reply['notificationId']);
            }
          }
        });
      } else {
        // Handle error if the request was not successful
        print(
            'Error in replies API: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
    }
  }

  Future<void> GetNotificationsRepliesByEmployes(
      String accessToken, int employeeId) async {
    final url = Uri.parse('$baseUrl$getnotificationreplies$employeeId');
    print('GetNotificationsRepliesByEmployee: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );

      print('response body for replies: ${response.body}');
      print('response code for replies: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        List<NotificationReply> notifiReply =
            jsonData.map((json) => NotificationReply.fromJson(json)).toList();
        print('notifiReply: $notifiReply');
        setState(() {
          notificationreplylist = notifiReply;
          // Check if any employeeId from jsonData matches loggedInEmployeeId
        });
      } else {
        // Handle error if the request was not successful
        print(
            'Error in replies API: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      // Handle any exceptions that occurred during the request
    }
  }

  Future<void> GetUpcomingbdays(String accessToken) async {
    final url = Uri.parse(baseUrl + getupcomingbirthdays);
    print('getupcomingbirthdays: $url');
    try {
      // Map<String, String> headers = {
      //   'Content-Type': 'application/json',
      //   'Authorization': '$accessToken',
      // };
      print('API headers: $accessToken');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': accessToken,
        },
      );
      print('response body: ${response.body}');
      print('response code: ${response.statusCode}');

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        print('xxx: ${response.body}');
        final List<dynamic> jsonData = json.decode(response.body);
        print('getupcomingbirthdaysResponse: $jsonData');

        List<UpComingbirthdays> bdaymodel =
            jsonData.map((json) => UpComingbirthdays.fromJson(json)).toList();
        //   print('Notification models: $bdaymodel');

        setState(() {
          upcoming_model = bdaymodel;
        });
      } else {
        // Handle error if the request was not successful
        Commonutils.showCustomToastMessageLong(
            'Error: ${response.body}', context, 1, 4);
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('ErrorGetnotificationreplies: $error');

      // Handle any exceptions that occurred during the reque
    }
  }

  void showdialogmethod(int notificationid, String emoplye) {
    messagecontroller.clear();
    showDialog(
      // barrierDismissible: false,
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Send Wishes",
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
                  Container(
                    //width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.name,
                          controller: messagecontroller,
                          onTap: () {},
                          decoration: InputDecoration(
                            hintText: 'Enter Wishes',
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
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            alignLabelWithHint: true,
                          ),
                          maxLength: 256,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: 'Calibri',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    sendgreetings(notificationid, emoplye);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFf15f22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Send Wishes',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Calibri'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void checkNotificationsAndOpenExpandedView(
      List<Notification_model> notificationData,
      List<Notification_model> birthdayNotifications) {
    if (notificationData.isNotEmpty) {
      isExpanded[0] = true;
    } else if (birthdayNotifications.isNotEmpty) {
      empData = birthdayNotifications
          .firstWhere((e) => e.employeeId.toString() == empolyeid);
      // bool result = birthdayNotifications.map((e) => e.employeeId.toString() == empolyeid,);
      print('empData1: ${empData!.code}');
      isExpanded[1] = true;
    } else {
      isExpanded[2] = true;
    }
  }
}

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool initiallyExpanded;
  final Function()? onTap;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.content,
    required this.initiallyExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      color: Colors.white,
      //elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: const BoxDecoration(
                //  borderRadius: BorderRadius.circular(10.0),
                color: Color(0xFFf15f22),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(child: title),
                  Icon(
                    initiallyExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (initiallyExpanded) content,
        ],
      ),
    );
  }
}
