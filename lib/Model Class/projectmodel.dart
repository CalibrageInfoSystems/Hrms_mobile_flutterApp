import 'dart:typed_data';

class projectmodel {
  Uint8List projectlogo;
  String projectname;
  List<ProjectInstance> instances;

  projectmodel({
    required this.projectlogo,
    required this.projectname,
    required this.instances,
  });
}

class ProjectInstance {
  String projectfromdate;
  String projecttodate;

  ProjectInstance({
    required this.projectfromdate,
    required this.projecttodate,
  });
}