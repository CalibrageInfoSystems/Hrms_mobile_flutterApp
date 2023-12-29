import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrms/Model%20Class/projectmodel.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'Commonutils.dart';
import 'SharedPreferencesHelper.dart';

class projects_screen extends StatefulWidget {
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<projects_screen> {
  List<Widget> projectCardWidgets = [];
  String EmployeName = '';
  String projectnamedetails = '';
  late Uint8List bytes;
  List<projectmodel> projectlist = [];

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    bytes = Uint8List(0);
    Commonutils.checkInternetConnectivity().then((isConnected) {
      if (isConnected) {
        print('The Internet Is Connected');
        _loadProjectDetails();
        // _loadProjectDetails();
      } else {
        print('The Internet Is not Connected');
      }
    });
  }

  void _loadProjectDetails() async {
    // Specify the API endpoint
    final loadedData = await SharedPreferencesHelper.getCategories();

    if (loadedData != null) {
      final employeeName = loadedData['employeeName'];
      final workingProjects = loadedData['workingProjects'];
      print("workingProjects ===>96 ${workingProjects}");
      print('workingProjects ====>97: $workingProjects');
      List<dynamic> projects = json.decode(workingProjects);

      if (projects != null && projects is List) {
        List<projectmodel> projectList = [];
        for (var project in projects) {
          print("Project ID: ${project["projectId"]}");
          print("Project Name: ${project["projectName"]}");
          print("Project Description: ${project["projectDescription"]}");
          print("Project Logo: ${project["projectLogo"]}");
          print("\n");
          String pm = project["projectName"];
          String base64Image = project["projectLogo"].split(',')[1];
          print("Project Logo:108===? $base64Image");
          bytes = Uint8List.fromList(base64.decode(base64Image));
          print("bytes:108===? $bytes");

          projectList.add(projectmodel(
              projectlogo: bytes,
              projectname: project["projectName"],
              projectfromdate: project["sinceFrom"]));

          setState(() {
            EmployeName = employeeName;
            projectlist = projectList;
            projectnamedetails = pm;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Image.asset(
              'assets/background_layer_2.png', // Replace with your image path
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),

            // SingleChildScrollView for scrollable content
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello!",
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontFamily: 'Calibri'),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(
                      "$EmployeName",
                      style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFFf15f22),
                          fontFamily: 'Calibri'),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        mainAxisExtent: 175,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: projectlist.length,
                      itemBuilder: (BuildContext context, int index) {
                        projectmodel projects = projectlist[index];

                        return Container(
                          padding: EdgeInsets.only(
                            top: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Circular image
                              CircleAvatar(
                                radius: 40.0,
                                backgroundImage:
                                    MemoryImage(projects.projectlogo),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              // Text below the image
                              Text(
                                "${projects.projectname}",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 0, 0),
                                          child: Text(
                                            "From Date",
                                            style: TextStyle(
                                                color: Color(0xFFf15f22),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 5, 0, 0),
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                              color: Colors.black26,
                                              fontSize: 16,
                                              fontFamily: 'Calibri',
                                              fontWeight: FontWeight.bold,
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 5, 0, 0),
                                          child: Text(
                                            "${projects.projectfromdate}",
                                            style: TextStyle(
                                              color: Colors.black26,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 2, 0, 0),
                                          child: Text(
                                            "To Date",
                                            style: TextStyle(
                                                color: Color(0xFFf15f22),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 2, 0, 0),
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                              color: Colors.black26,
                                              fontSize: 16,
                                              fontFamily: 'Calibri',
                                              fontWeight: FontWeight.bold,
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
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(4, 2, 0, 0),
                                          child: Text(
                                            "Present",
                                            style: TextStyle(
                                              color: Colors.black26,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Calibri',
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
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget _buildProjectCard(
//     {required Uint8List bytes, required String projectName}) {
//   return Card(
//     elevation: 5.0,
//     margin: EdgeInsets.symmetric(vertical: 5.0),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(16.0),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Circular image at the top of the card
//         Container(
//           width: 120,
//           height: 120.0, // Overall size of the Container
//           // Overall size of the Container
//           child: ClipOval(
//             child: Image.memory(
//               bytes,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//
//         // Project Name below the circular image
//         Padding(
//           padding: EdgeInsets.all(2.0),
//           child: Text(
//             projectName,
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
}
