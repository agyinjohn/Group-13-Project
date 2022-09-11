// ignore_for_file: avoid_print, use_key_in_widget_constructors, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceCheckPage extends StatefulWidget {
  const AttendanceCheckPage(this.password);
  static String idAttendance = '';
  static String listId = '';
  final String password;

  @override
  State<AttendanceCheckPage> createState() => _AttendanceCheckPageState();
}

class _AttendanceCheckPageState extends State<AttendanceCheckPage> {
  bool classInsession = false;
  // ignore: prefer_typing_uninitialized_variables
  var extractedResult;
  late double longitude;
  late double latitude;
  late Position position;
  bool isMe = false;
  bool attendanceSubmitted = false;
  String firstName = '';
  String lastName = '';
  bool startingClass = false;
  bool hasEndedClass = false;
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  List<String> courses = [];
  List<String> coursesCodes = [];
  List<String> classes = ['Computer Science 2', 'Computer Science 3'];

  String? selectedCourse;
  String? selectedCourseCode;
  String? selectedClass;

  bool isLoading = false;

  final url =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/lecturer.json';
  final url1 =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/course.json';

  final url2 =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/classinsection.json';
  final me =
      'https://attendancex-8f0dc-default-rtdb.firebaseio.com/classinsection.json';

  late var url3 = '';
  late var url4 = '';
  Future<void> lectureDetails(String pass) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      final response2 = await http.get(Uri.parse(url1));

      var extractedDataCourses =
          json.decode(response2.body) as Map<String, dynamic>;
      print(extractedDataCourses['course code'].keys.toList());
      print(extractedDataCourses['coursetitle'].keys.toList());

      courses = extractedDataCourses['coursetitle'].keys.toList();
      coursesCodes = extractedDataCourses['course code'].keys.toList();

      setState(() {
        isLoading = false;
        firstName = extractedData[pass]['firstname'];
        lastName = extractedData[pass]['lastname'];
      });
      print(firstName);
      print(lastName);
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> checkIsMe() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    isMe = sharedPreferences.getBool('isMe') as bool;
  }

  Future<void> deleteEndedClass() async {
    url3 =
        'https://attendancex-8f0dc-default-rtdb.firebaseio.com/classinsection/${AttendanceCheckPage.idAttendance}.json';

    final result = await http.get(Uri.parse(me));
    setState(() {
      extractedResult = json.decode(result.body);
      startingClass = true;
    });

    try {
      final result = await http.delete(Uri.parse(url3));
      print('Successful deletion');
      print(json.decode(result.body));
      setState(() {
        startingClass = false;
      });
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setBool('isMe', false);
    } catch (err) {
      print('could not delete');
      setState(() {
        startingClass = false;
      });
      print('could\'t delete');
    }
  }

  @override
  void didChangeDependencies() {
    lectureDetails(widget.password);
    checkIsMe();
    super.didChangeDependencies();
  }

  Future<void> patchAttendance() async {
    var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final postAttendanclist =
        'https://attendancex-8f0dc-default-rtdb.firebaseio.com/lecturers/attendance/${widget.password}/$date.json';
    try {
      final result = await http.post(Uri.parse(postAttendanclist),
          body: json.encode({
            'Name': 'index',
          }));

      print(json.decode(result.body));
      setState(() {
        AttendanceCheckPage.listId = json.decode(result.body)['name'];
      });
    } catch (err) {
      print(err);
    }
  }

  void showDialogBox(String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(ctx).pop, child: const Text('OK'))
            ],
          );
        });
  }

  Future<void> attendanceTaking(double lat, double longi) async {
    var date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      startingClass = true;
    });

    final result = await http.get(Uri.parse(me));
    setState(() {
      extractedResult = json.decode(result.body);
    });

    // print('me $extractedResult');
    if (extractedResult == null &&
        selectedClass != null &&
        selectedCourse != null &&
        selectedCourseCode != null) {
      try {
        final result = await http.post(Uri.parse(me),
            body: json.encode({
              'course': selectedCourse,
              'FirstName': firstName,
              'courseCode': selectedCourseCode,
              'LastName': lastName,
              'id': widget.password,
              'DateTime': date,
              'latitude': lat.toString(),
              'listId': AttendanceCheckPage.listId,
              'longitude': longi.toString(),
            }));
        setState(() {
          attendanceSubmitted = true;
          classInsession = true;
          startingClass = false;
          hasEndedClass = false;
          AttendanceCheckPage.idAttendance = json.decode(result.body)['name'];
          print(AttendanceCheckPage.idAttendance);
        });
        Fluttertoast.showToast(msg: 'Class Started Successfully');
        final sharedPreferences1 = await SharedPreferences.getInstance();
        sharedPreferences1.setBool('isMe', true);
      } catch (err) {
        setState(() {
          startingClass = false;
        });
        print(err);
      }
    } else if (extractedResult != null ||
        selectedClass == null ||
        selectedCourse == null ||
        selectedCourseCode == null) {
      setState(() {
        startingClass = false;
      });
      Fluttertoast.showToast(
          msg: 'Couldn\'t start class',
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: startingClass
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        const Center(
                          child: Text(
                            "Start A Class",
                            softWrap: true,
                            style: TextStyle(fontSize: 25, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Select your Course',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: 400,
                                height: 50,
                                child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                width: 3, color: Colors.blue))),
                                    value: selectedCourse,
                                    items: courses
                                        .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            )))
                                        .toList(),
                                    onChanged: (value) => setState(() {
                                          selectedCourse = value;
                                        })),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Select your Class',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: 400,
                                height: 50,
                                child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                width: 3, color: Colors.blue))),
                                    value: selectedClass,
                                    items: classes
                                        .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            )))
                                        .toList(),
                                    onChanged: (value) => setState(() {
                                          selectedClass = value;
                                        })),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Select Course Code',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              SizedBox(
                                width: 400,
                                height: 50,
                                child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                width: 3, color: Colors.blue))),
                                    value: selectedCourseCode,
                                    items: coursesCodes
                                        .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            )))
                                        .toList(),
                                    onChanged: (value) => setState(() {
                                          selectedCourseCode = value;
                                        })),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  (!hasEndedClass || isMe)
                                      ? showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                                content: const Text(
                                                    'Are sure want to end the class'),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(ctx);
                                                      },
                                                      child: const Text('NO')),
                                                  FlatButton(
                                                      onPressed: () {
                                                        deleteEndedClass();
                                                        Navigator.of(context)
                                                            .pop(ctx);
                                                        setState(() {
                                                          attendanceSubmitted =
                                                              false;
                                                          hasEndedClass = true;
                                                        });
                                                      },
                                                      child: const Text('YES'))
                                                ],
                                              ))
                                      : Fluttertoast.showToast(
                                          msg: 'You have ended class already',
                                          backgroundColor: Colors.grey,
                                          textColor: Colors.white);
                                },
                                child: const Text('End Attendance')),
                            ElevatedButton(
                                onPressed: () async {
                                  position = await _determinePosition();
                                  setState(() {
                                    longitude = position.longitude;
                                    latitude = position.latitude;
                                  });
                                  patchAttendance().then((value) =>
                                      attendanceTaking(latitude, longitude));
                                  //patchAttendance();
                                  print(AttendanceCheckPage.idAttendance);
                                  print(
                                      'Lecture latitude: ${position.latitude}');
                                },
                                child: const Text('Start Class')),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
