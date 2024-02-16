import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hrms/Model%20Class/login%20model%20class.dart';
import 'package:hrms/questions_model.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'Commonutils.dart';
import 'api config.dart';
import 'main.dart';

class security_questionsscreen extends StatefulWidget {
  final String userid;
  security_questionsscreen({required this.userid});
  @override
  _securityscreenscreenState createState() => _securityscreenscreenState();
}

class _securityscreenscreenState extends State<security_questionsscreen> {
  List<Map<String, dynamic>> questions = [];
  List<Map<String, String>> selectedQuestionsAndAnswers = [];
  int? question_id;
  int selectedTypeCdId = -1;
  String? answerinlistview;
  int selectedValue = 0;
  late String selectedName;
  List<dynamic> responseData = [];

  List<int> answeredQuestionIds = [];
  List<int> deletedQuestionIndices = [];

  // String selectedQuestion =
  //     'Select a question'; // Initially, no question is selected
  List<questionmodel> questionlist = [];
  String? selectedQuestion;
  questionmodel? selectedquestionmodel;
  int? selectedQuestionId; // Initialize selectedQuestionId with null
  TextEditingController answercontroller = new TextEditingController();
  Future<void> fetchQuestions() async {
    String apiUrl =
        'http://182.18.157.215/HRMS/API/hrmsapi/Security/SecureQuestions';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // setState(() {
      //   questions = (jsonDecode(response.body) as List<dynamic>)
      //       .cast<Map<String, dynamic>>();
      // });
      responseData = json.decode(response.body);

      setState(() {
        questionlist =
            (responseData).map((item) => questionmodel.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('useridinsecurityquestionscree:${widget.userid}');
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginPage()),
          ); // Navigate to the previous screen
          return true; // Prevent default back navigation behavior
        },
        child: MaterialApp(
            // color: Color(0xFFF05F22),
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              // appBar: AppBar(
              //   elevation: 0,
              //   title: Column(
              //     children: [
              //       Align(
              //           alignment: Alignment.topLeft,
              //           child: Container(
              //             padding: EdgeInsets.only(left: 10.0, top: 5.0),
              //             child: GestureDetector(
              //               onTap: () {
              //                 // Handle the back button press here
              //                 Navigator.pop(context);
              //               },
              //               child: Container(
              //                 width: 40.0,
              //                 height: 40.0,
              //                 decoration: BoxDecoration(
              //                   shape: BoxShape.circle,
              //                   color:
              //                       Colors.white, // Change the color as needed
              //                 ),
              //                 child: Icon(
              //                   Icons.arrow_back,
              //                   color: Color(
              //                       0xFFF44614), // Change the color as needed
              //                 ),
              //               ),
              //             ),
              //           )),
              //     ],
              //   ),
              // ),
              body: SingleChildScrollView(
                child: Container(
                  height: screenHeight,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/background_layer_2.png',
                      ), // Replace with your image path
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 35.0),
                          child: SvgPicture.asset(
                            'assets/cislogo-new.svg',
                            height: 120.0,
                            width: 55.0,
                            //  color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'HRMS',
                            style: TextStyle(
                                color: Color(0xFFf15f22),
                                fontSize: 18,
                                fontFamily: 'Calibri'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Container(
                          width: double.infinity,
                          child: Text(
                            'Security Questions',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Calibri'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Note:',
                                  style: TextStyle(
                                      color: Color(0xFFf15f22),
                                      fontSize: 18,
                                      fontFamily: 'Calibri'),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Minimum two Questions need to be answered out of 15 questions for recovering the password when you lost it.',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Calibri'),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'When you selected more questions while recovering a password system randomly request 2 questions only. ',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Calibri'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 35.0, left: 0.0, right: 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf15f22),
                                      borderRadius: BorderRadius.circular(6.0),
                                      // Adjust the border radius as needed
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        _showAddQuestionDialog(context);
                                        fetchQuestions();
                                      },
                                      child: Text(
                                        'Add Question',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Calibri'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0),
                              ],
                            )),
                        SizedBox(height: 10.0),
                        FutureBuilder(
                          future: Future.value(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (selectedQuestionsAndAnswers.isEmpty) {
                                return Center(
                                  child: Text(
                                      'Answered Questions Will Be Displayed Here'),
                                );
                              } else {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: selectedQuestionsAndAnswers.length,
                                  physics: PageScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Handle tap on item if needed
                                        //  setState(() {
                                        question_id = int.tryParse(
                                            selectedQuestionsAndAnswers[index]
                                                ['id']!);
                                        answerinlistview =
                                            selectedQuestionsAndAnswers[index]
                                                ['answer'];
                                        //  });
                                        print(
                                            'answerinlistview:${answerinlistview}');
                                        print(
                                            'questionidclicked:${question_id}');
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.orange,
                                            width: 1.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        margin: EdgeInsets.only(bottom: 15.0),
                                        padding: EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${selectedQuestionsAndAnswers[index]['question']}',
                                                  style: TextStyle(
                                                    color: Color(0xFFf15f22),
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Calibri',
                                                  ),
                                                ),
                                                Spacer(),
                                                GestureDetector(
                                                  onTap: () {
                                                    _removeQuestion(index);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${selectedQuestionsAndAnswers[index]['answer']}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontFamily: 'Calibri',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              return Text('Error: Unable to fetch data');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
                //        decoration: BoxDecoration(color: Colors.transparent),
                color: Color(0xFFf0ab91),
                padding: EdgeInsets.only(
                    top: 12.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Container(
                  width: double.infinity,
                  //color: Color(0x00ffffff),
                  decoration: BoxDecoration(
                    color: Color(0xFFf15f22),
                    borderRadius: BorderRadius.circular(5.0),
                    // Adjust the border radius as needed
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      sendingQuestion();
                    },
                    child: Text(
                      'Submit Security Questions',
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
            )));
  }

  void _showAddQuestionDialog(BuildContext context) {
    answercontroller.text = '';
    selectedTypeCdId = -1;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Security Questions",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Calibri',
                      color: Color(0xFFf15f22),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
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
                        Container(
                          // width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFFf15f22),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButton<int>(
                                value: selectedTypeCdId,
                                iconSize: 30,
                                icon: null,
                                isExpanded: true,
                                style: TextStyle(
                                    color: Color(0xFFFB4110),
                                    fontFamily: 'Calibri'),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeCdId = value!;
                                    print('selectedTypeCdId$selectedTypeCdId');
                                  });
                                },
                                items: [
                                  DropdownMenuItem<int>(
                                    value: -1,
                                    child: Text(
                                      'Choose Your Question',
                                      style: TextStyle(
                                        color:
                                            Colors.black26, // Label text color
                                      ),
                                    ),
                                  ),
                                  // Assuming responseData is your list of questions
                                  ...responseData
                                      .asMap()
                                      .entries
                                      .where((entry) =>
                                          !answeredQuestionIds.contains(entry
                                              .key)) // Filter out answered questions
                                      .map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;
                                    return DropdownMenuItem<int>(
                                      value: index,
                                      child: Text(
                                        item['question'],
                                        style: TextStyle(fontFamily: 'Calibri'),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // TextFormField(
                        //   controller: answercontroller,
                        //   decoration: InputDecoration(
                        //     hintText: 'Enter your Answer here',
                        //   ),
                        // ),
                        TextFormField(
                          ///     keyboardType: TextInputType.name,

                          controller: answercontroller,
                          onTap: () {
                            // requestPhonePermission();
                          },
                          decoration: InputDecoration(
                            hintText: 'Please Enter Your Answer',
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
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _addQuestion();
                  },
                  child: Text(
                    'Add Question',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Calibri'), // Set text color to white
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(
                        0xFFf15f22), // Change to your desired background color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(5), // Set border radius
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addQuestion() {
    if (selectedTypeCdId == -1) {
      // Show toast or error message
      Commonutils.showCustomToastMessageLong(
          'Please Select Question', context, 1, 4);
      return;
    }

    if (answercontroller.text.trim().isEmpty) {
      // Show toast or error message
      Commonutils.showCustomToastMessageLong(
          'Please Enter Answer', context, 1, 4);
      return;
    }

    setState(() {
      selectedQuestionsAndAnswers.add({
        'question': responseData[selectedTypeCdId]['question'],
        'answer': answercontroller.text.trim(),
        'questionid': responseData[selectedTypeCdId]['questionid'].toString(),
        'id': selectedTypeCdId.toString()
      });

      // Add the ID of the answered question to the list of answered question IDs
      answeredQuestionIds.add(selectedTypeCdId);

      // Remove deleted question indices from the list
      deletedQuestionIndices.remove(selectedTypeCdId);

      Navigator.of(context).pop();
    });
  }

  void _removeQuestion(int index) {
    if (selectedQuestionsAndAnswers.isNotEmpty &&
        index >= 0 &&
        index < selectedQuestionsAndAnswers.length) {
      setState(() {
        selectedQuestionsAndAnswers.removeAt(index);
        if (!deletedQuestionIndices.contains(index)) {
          deletedQuestionIndices.add(index);
          answeredQuestionIds.removeAt(index);
        }
      });
    }
  }

  Future<void> sendingQuestion() async {
    try {
      final url = Uri.parse(baseUrl + sendingquestionapi);
      print('Sending questions API: $url');
      if (selectedQuestionsAndAnswers.length < 2) {
        // Show an error message or handle the case where the size is less than 2
        print('Error: At least 2 questions and answers are required.');
        Commonutils.showCustomToastMessageLong(
            'Please Answer atleast Two Questions', context, 1, 4);
        return;
      }
      // List to store request bodies for each question and answer
      List<Map<String, dynamic>> requestBodies = [];

      // Iterate over each question and answer in the ListView
      for (int index = 0; index < selectedQuestionsAndAnswers.length; index++) {
        // Extract question ID and answer
        int? questionId =
            int.tryParse(selectedQuestionsAndAnswers[index]['id'].toString());
        String answer = selectedQuestionsAndAnswers[index]['answer']!;

        // Define request body for the current question and answer
        Map<String, dynamic> requestBody = {
          "userQuestionId": 0, // Assuming this value needs to be set
          "userId": "${widget.userid}",
          "questionId": questionId,
          "answer": answer,
        };

        // Add the request body to the list
        requestBodies.add(requestBody);
      }

      // Encode the list of request bodies as JSON
      String requestBodyJson = jsonEncode(requestBodies);
      print('requestBodyJson$requestBodyJson');
      // Send the POST request with the JSON body
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBodyJson,
      );

      print('Response: ${response.body}');

      // Check the response status code
      if (response.statusCode == 200) {
        // Handle successful response
        Commonutils.showCustomToastMessageLong(
            'Questions Added Successfully', context, 0, 4);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        // Handle error scenarios
        Commonutils.showCustomToastMessageLong(
            'Error ${response.statusCode}', context, 1, 4);
        print(
            'Failed to send the request. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error: $e');
      Commonutils.showCustomToastMessageLong('Error: $e', context, 1, 4);
    }
  }

  // Future<void> sendingquestion() async {
  //   try {
  //     final url = Uri.parse(baseUrl + sendingquestionapi);
  //     print('sendingquestionsapi: $url');
  //
  //     // Define your request body as a Map or a JSON String
  //     Map<String, dynamic> requestBody = {
  //       "userQuestionId": 0,
  //       "userId": "${widget.userid}",
  //       "questionId": question_id,
  //       "answer": "$answerinlistview"
  //     };
  //
  //     // Encode the request body as JSON
  //     String requestBodyJson = jsonEncode(requestBody);
  //
  //     final response = await http.post(
  //       url,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: requestBodyJson,
  //     );
  //     print('login response: ${response.body}');
  //
  //     // Check the response status code
  //     if (response.statusCode == 200) {
  //       Commonutils.showCustomToastMessageLong(
  //           'Api is Successfully', context, 1, 4);
  //       // Handle successful response
  //     } else {
  //       Commonutils.showCustomToastMessageLong(
  //           'Error ${response.statusCode}', context, 1, 4);
  //       print('response is not success');
  //       print(
  //           'Failed to send the request. Status code: ${response.statusCode}');
  //       // Handle error scenarios
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
}

// void _showAddQuestionDialog(BuildContext context) {
//   answercontroller.text = '';
//   selectedQuestion = null;
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return StatefulBuilder(
//         builder: (context, setState) {
//           return Container(
//             width: MediaQuery.of(context).size.width,
//             child: AlertDialog(
//               backgroundColor: Colors.white,
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Select Security Questions",
//                     style: TextStyle(
//                       color: Color(0xFFf15f22),
//                     ),
//                   ),
//                   //  SizedBox(width: 8), // Adjust spacing between text and icon
//                   InkWell(
//                     onTap: () {
//                       // Handle icon click event here
//                       print("Icon clicked!");
//                       Navigator.of(context).pop();
//                     },
//                     child: Icon(
//                       CupertinoIcons.multiply,
//                       color: Colors.grey,
//                     ), // Add your icon here
//                   ),
//                 ],
//               ),
//               //  icon: Icon(CupertinoIcons.multiply_circle),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Change the type to String?
//                   Container(
//                     width: MediaQuery.of(context).size.width,
//                     // decoration: BoxDecoration(
//                     //   color: Colors.white,
//                     // ),
//                     child: Column(
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: Color(
//                                   0xFFf15f22), // You can change the color here
//                               width: 1.0, // You can adjust the width here
//                             ),
//                             borderRadius: BorderRadius.circular(
//                                 5.0), // You can adjust the border radius here
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: ButtonTheme(
//                               alignedDropdown: true,
//                               child: DropdownButton<int>(
//                                   value: selectedTypeCdId,
//                                   iconSize: 30,
//                                   icon: null,
//                                   style: TextStyle(
//                                     color: Color(0xFFFB4110),
//                                   ),
//                                   onChanged: (value) {
//                                     setState(() {
//                                       selectedTypeCdId = value!;
//                                       if (selectedTypeCdId != -1) {
//                                         selectedValue =
//                                             responseData[selectedTypeCdId]
//                                                 ['questionId'];
//                                         selectedName =
//                                             responseData[selectedTypeCdId]
//                                                 ['question'];
//
//                                         print("selectedValue:$selectedValue");
//                                         print(
//                                             "selectedquestion:$selectedName");
//                                       } else {
//                                         print("==========");
//                                         print(selectedValue);
//                                         print(selectedName);
//                                       }
//                                       // isDropdownValid = selectedTypeCdId != -1;
//                                     });
//                                   },
//                                   items: [
//                                     DropdownMenuItem<int>(
//                                       value: -1,
//                                       child: Text(
//                                           'Choose Your Question'), // Static text
//                                     ),
//                                     ...responseData
//                                         .asMap()
//                                         .entries
//                                         .map((entry) {
//                                       final index = entry.key;
//                                       final item = entry.value;
//                                       return DropdownMenuItem<int>(
//                                         value: index,
//                                         child: Text(item['question']),
//                                       );
//                                     }).toList(),
//                                   ]),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Padding(
//                           padding: EdgeInsets.only(
//                               top: 0.0, left: 0.0, right: 0.0),
//                           child: TextFormField(
//                             ///     keyboardType: TextInputType.name,
//
//                             controller: answercontroller,
//                             onTap: () {
//                               // requestPhonePermission();
//                             },
//                             decoration: InputDecoration(
//                               hintText: 'Enter your Answer here',
//                               filled: true,
//                               fillColor: Colors.white,
//                               focusedBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFFf15f22),
//                                 ),
//                                 borderRadius: BorderRadius.circular(6.0),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide: BorderSide(
//                                   color: Color(0xFFf15f22),
//                                 ),
//                                 borderRadius: BorderRadius.circular(6.0),
//                               ),
//                               hintStyle: TextStyle(
//                                 color: Colors.black26, // Label text color
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(
//                                   vertical: 15, horizontal: 15),
//                               alignLabelWithHint: true,
//                             ),
//                             textAlign: TextAlign.start,
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontFamily: 'Calibri',
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//               actions: [
//                 ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                         Colors.deepOrangeAccent),
//                     shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                       RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(
//                             5.0), // Adjust the value as needed
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     bool isValid = true;
//                     bool hasValidationFailed = false;
//
//                     // Check if a question type is selected
//                     if (selectedTypeCdId == -1) {
//                       Commonutils.showCustomToastMessageLong(
//                         'Please Select Question',
//                         context,
//                         1,
//                         4,
//                       );
//                       isValid = false;
//                       hasValidationFailed = true;
//                     }
//
//                     // Check if an answer is provided
//                     if (isValid && answercontroller.text.trim().isEmpty) {
//                       Commonutils.showCustomToastMessageLong(
//                         'Please Enter Answer',
//                         context,
//                         1,
//                         4,
//                       );
//                       isValid = false;
//                       hasValidationFailed = true;
//                       FocusScope.of(context).unfocus();
//                     }
//
//                     // Check if the selected question is already in the list
//                     // bool questionAlreadySelected =
//                     //     listViewQuestionIds.contains(selectedTypeCdId);
//                     // if (questionAlreadySelected) {
//                     //   // Show a toast message indicating that the question is already selected
//                     //   Commonutils.showCustomToastMessageLong(
//                     //     'Please select another questons',
//                     //     context,
//                     //     1,
//                     //     4,
//                     //   );
//                     // }
//                     // If all validations pass, add the selected question and answer to the list
//                     if (isValid) {
//                       setState(() {
//                         selectedQuestionsAndAnswers.add({
//                           'question': selectedName,
//                           'answer': answercontroller.text.trim(),
//                           'questionid': selectedQuestionId.toString(),
//                         });
//                         Navigator.of(context).pop();
//                       });
//                     }
//                   },
//                   child: Text(
//                     'Add Question',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
// actions: [
// ElevatedButton(
// onPressed: () {
// Navigator.of(context).pop();
// },
// child: Text('Add Question'),
// ),
// ],
// DropdownButton(
//   hint: Text('Select a question'),
//   value: null, // Initially, no value is selected
//   onChanged: (newValue) {
//     // Find the question ID corresponding to the selected question
//     final selectedQuestion = questions.firstWhere(
//         (question) => question['question'] == newValue);
//     final questionId = selectedQuestion['questionId'];
//     print('Question: $newValue, Question ID: $questionId');
//   },
//   items: questions.map<DropdownMenuItem<String>>((question) {
//     return DropdownMenuItem<String>(
//       value: question['question'],
//       child: Text(question['question']),
//     );
//   }).toList(),
// ),
// DropdownButton(
//   hint: Text(selectedQuestion),
//   value: null, // Initially, no value is selected
//   onChanged: (newValue) {
//     // Find the question ID corresponding to the selected question
//     final selectedQuestionData = questions.firstWhere(
//         (question) => question['question'] == newValue);
//     final questionId = selectedQuestionData['questionId'];
//     setState(() {
//       selectedQuestion = newValue!;
//     });
//     print('Question: $newValue, Question ID: $questionId');
//   },
//   items: questions.map<DropdownMenuItem<String>>((question) {
//     return DropdownMenuItem<String>(
//       value: question['question'],
//       child: Text(question['question']),
//     );
//   }).toList(),
// ),
// DropdownButtonHideUnderline(
//   child: ButtonTheme(
//     alignedDropdown: true,
//     child: DropdownButton<String>(
//       hint: Text(selectedQuestion),
//       value: null, // Initially, no value is selected
//       onChanged: (newValue) {
//         // Find the question ID corresponding to the selected question
//         final selectedQuestionData = questions.firstWhere(
//             (question) => question['question'] == newValue);
//         final questionId = selectedQuestionData['questionId'];
//         setState(() {
//           selectedQuestion = newValue!;
//         });
//         print('Question: $newValue, Question ID: $questionId');
//       },
//       items: [
//         DropdownMenuItem<String>(
//           value: null,
//           child: Text('Select a question'), // Static text
//         ),
//         ...questions.map<DropdownMenuItem<String>>((question) {
//           return DropdownMenuItem<String>(
//             value: question['question'],
//             child: Text(question['question']),
//           );
//         }).toList(),
//       ],
//     ),
//   ),
// ),

// questionlist.isEmpty
//     ? LoadingAnimationWidget.newtonCradle(
//         color: Colors.blue, // Set the color as needed
//         size: 40.0,
//       ) // S // Show a loading indicator
//     :
