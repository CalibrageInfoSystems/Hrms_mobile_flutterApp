import 'dart:typed_data';

class projectmodel {
  final Uint8List projectlogo;
  final String projectname;
  final String projectfromdate;

  projectmodel(
      {required this.projectlogo,
      required this.projectname,
      required this.projectfromdate});

  factory projectmodel.fromJson(Map<String, dynamic> json) {
    return projectmodel(
        projectlogo: json['projectLogo'],
        projectname: json['projectName'],
        projectfromdate: json['refreshToken']);
  }
}
