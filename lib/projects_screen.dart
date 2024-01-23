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
    String pm = "";
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
           pm = project["projectName"];
          String base64Image = project["projectLogo"].split(',')[1];
          print("Project Logo:108===? $base64Image");
          bytes = Uint8List.fromList(base64.decode(base64Image));
          print("bytes:108===? $bytes");
          print("Project endAt: ${project["endAt"]}");

          var existingProjectIndex = projectList.indexWhere(
                (existingProject) => existingProject.projectname == project["projectName"],
          );

          if (existingProjectIndex != -1) {
            // If the project exists, add only the instance
            projectList[existingProjectIndex].instances.add(ProjectInstance(
              projectfromdate: project["sinceFrom"],
              projecttodate: project["endAt"] ?? "Progress",
            ));
          } else {
            // If the project doesn't exist, create a new project and add it to projectList
            List<ProjectInstance> instances = [];
            instances.add(ProjectInstance(
              projectfromdate: project["sinceFrom"],
              projecttodate: project["endAt"] ?? "Progress",
            ));

            projectList.add(projectmodel(
              projectlogo: bytes,
              projectname: project["projectName"],
              instances: instances,
            ));
          }


        }
        setState(() {
          EmployeName = employeeName;
          projectlist = projectList;
          projectnamedetails = pm;
        });
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
                    mainAxisExtent: 190,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: projectlist.length,
                  itemBuilder: (BuildContext context, int index) {
                    projectmodel project = projectlist[index];

                    return Container(
                      padding: EdgeInsets.only(top: 10.0),
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
                          // Display project name and logo only once
                          CircleAvatar(
                            radius: 40.0,
                            backgroundImage: MemoryImage(project.projectlogo),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            "${project.projectname}",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          // Display from date and to date multiple times
                          Column(
                            children: [
                              for (var instance in project.instances)
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(4, 5, 0, 0),
                                            child: Text(
                                              "${instance.projectfromdate}",
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Calibri',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 0,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                                            child: Text(
                                              "-",
                                              style: TextStyle(
                                                color: Colors.black54,
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(4, 5, 0, 0),
                                            child: Text(
                                              "${instance.projecttodate}",
                                              style: TextStyle(
                                                color: Colors.black54,
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
                        ],
                      ),
                    );
                  },)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
