// ignore_for_file: avoid_print, use_key_in_widget_constructors, must_be_immutable,, prefer_typing_uninitialized_variables, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'category_login.dart';

//import 'dart:math' show sin, cos, sqrt, atan2;
// ignore: depend_on_referenced_packages
//import 'package:vector_math/vector_math.dart' show radians;

class StudentHomepage extends StatefulWidget {
  StudentHomepage(this.password);
  static const routeName = '/Studenthomepage';
  String password;

  @override
  State<StudentHomepage> createState() => _StudentHomepageState();
}

class _StudentHomepageState extends State<StudentHomepage> {
  DateTime? lastpressed;
  late Position position;
  late double latitude;
  bool hasCkedIn = false;
  late double longitude;
  double distance = 0;
  double? lectureLatitude = 0;
  bool hasClass = false;
  double? lectureLogitude = 0;
  String lectureFirstName = '';
  String lecturerLastName = '';
  String courseCodeIn = '';
  String courseNameIn = '';
  var date = '';
  String timeOfDay = '';
  String firstName = '';
  String lastName = '';
  int classAttended = 0;
  int classAbsented = 0;
  String email = '';
  String profile = '';
  String lecturerId = '';
  bool isMorning = true;
  bool isLoading = false;
  String classInSecId = '';
  bool isAfternoon = false;
  bool isEvening = false;
  int? timeOfDay2 = 0;
  bool hasCheckedIn = false;
  final url =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/student.json';
  final url2 =
      'https://attendancex-8f0dc-default-rtdb.firebaseio.com/classinsection.json';

  var url3 = '';

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

  checkClassInsection() async {
    final result = await http.get(Uri.parse(url2));
    var extract = json.decode(result.body);
    var extract2 = json.decode(result.body) as Map<String, dynamic>;

    print(extract);
    print(result);

    if (extract == null) {
      setState(() {
        setState(() {
          hasClass = false;
        });
        lectureFirstName = '';
        lecturerLastName = '';
        lectureLatitude = 0;
        lectureLogitude = 0;
        courseNameIn = '';
        courseCodeIn = '';
      });
    } else {
      setState(() {
        hasClass = true;
      });

      extract2.forEach(
        (key, value) {
          lectureFirstName = value['FirstName'];
          lecturerLastName = value['LastName'];
          courseCodeIn = value['courseCode'];
          courseNameIn = value['course'];
          lectureLatitude = double.tryParse(value['latitude']);
          lectureLogitude = double.tryParse(value['longitude']);
          lecturerId = value['id'];
          classInSecId = value['listId'];
          date = value['DateTime'];
        },
      );

      setState(() {});
    }
  }

  distanceCalculator(double studentLat, double studentLongitude,
      double lectureLongitude, double lecturerLat) {
    // double earthRadius = 6371000;

    double circumference = 111100.00;

    double latitudeDiffs = lecturerLat - studentLat;

    distance = latitudeDiffs * circumference;

    // var dLat = radians(lecturerLat - studentLat);
    // var dLng = radians(lectureLongitude - studentLongitude);
    // var a = sin(dLat / 2) * sin(dLat / 2) +
    //     cos(radians(studentLat)) *
    //         cos(radians(lecturerLat)) *
    //         sin(dLng / 2) *
    //         sin(dLng / 2);
    // var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    // distance = earthRadius * c;
    print(distance); //d is the distance in kilometres

//Calculating the distance between two points with Geolocator plugin
  }

  Future<void> submitCredentials(double distance) async {
    url3 =
        'https://attendancex-8f0dc-default-rtdb.firebaseio.com/lecturers/$lecturerId/$date/$classInSecId.json';

    //   final SharedPreferences sharedPreferences =
    //       await SharedPreferences.getInstance();

    if (distance < 0.02 && !hasCheckedIn) {
      try {
        final attendListPatch = await http.patch(Uri.parse(url3),
            body: json.encode({widget.password: '$firstName $lastName'}));
        setState(() {
          classAttended += 1;
          hasCheckedIn = true;
        });
        print(json.decode(attendListPatch.body));

        Fluttertoast.showToast(
          msg: 'You have checked in Succesfully',
          backgroundColor: Colors.grey,
          fontSize: 15,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
        );
      } catch (err) {
        print(err);
      }
    } else if (!hasCheckedIn) {
      setState(() {
        classAbsented += 1;
        hasCheckedIn = true;
      });

      showDialogBox('Out of range you are not permitted');
    }
  }

  Future<void> studentDetails(String pass) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      // final SharedPreferences sharedPreferences =
      //     await SharedPreferences.getInstance();
      // classAttended = sharedPreferences.getInt('classAttended')!;
      // classAbsented = sharedPreferences.getInt('classAbsented ')!;

      //print(extractedData);
      //print(extractedData[pass]['firstname']);
      //  print(extractedData.containsKey(pass));
      if (timeOfDay == 'PM') {
        setState(() {
          isAfternoon = true;
          isMorning = false;
        });
      } else {
        setState(() {
          isAfternoon = false;
          isMorning = true;
        });
      }

      setState(() {
        firstName = extractedData[pass]['firstname'];
        lastName = extractedData[pass]['lastname'];

        email = extractedData[pass]['email'];
        profile = extractedData[pass]['profile'];
      });
      //  print('FirstName: $firstName');
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  void initState() {
    timeOfDay = DateFormat('a').format(DateTime.now());
    timeOfDay2 = int.tryParse(DateFormat('KK').format(DateTime.now()));
    print(timeOfDay2);
    print(timeOfDay);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    studentDetails(widget.password);
    checkClassInsection();
    super.didChangeDependencies();
  }

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

  void logout() async {
    final pref = await SharedPreferences.getInstance();
    pref.remove('ShowHome');
    pref.remove('email');
    pref.remove('isStudent');
    // ignore: use_build_context_synchronously
    Navigator.popAndPushNamed(context, CategoryLoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white70,
            child: isLoading
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : Text(
                    '${firstName.characters.characterAt(0)}${lastName.characters.characterAt(0)}'),
          ),
        ],
      ),
      drawer: Drawer(
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        profile,
                      ),
                      radius: 50,
                      backgroundColor: Colors.orangeAccent,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        email,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(
                  height: 3,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('$firstName $lastName',
                          style: const TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
                const Divider(),
                const SizedBox(
                  height: 3,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: const [
                      Icon(Icons.book, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        'Computer Science',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Divider(),
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/images/icon1.png'),
                    radius: 20,
                  ),
                  Text(
                    'E-rollCall',
                    style: TextStyle(color: Colors.blueGrey),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => checkClassInsection(),
              child: Stack(children: [
                ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SingleChildScrollView(
                      child: WillPopScope(
                        onWillPop: () async {
                          final now = DateTime.now();
                          const maxDuration = Duration(seconds: 2);
                          final iswarning = lastpressed == null ||
                              now.difference(lastpressed!) > maxDuration;

                          if (iswarning) {
                            lastpressed = DateTime.now();
                            const snackBar = SnackBar(
                              content: Text('Double Tap to Close App'),
                              duration: maxDuration,
                            );

                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(snackBar);
                            return false;
                          }
                          {
                            return true;
                          }
                        },
                        child: Container(
                            height: size.height,
                            width: size.width,
                            decoration:
                                const BoxDecoration(color: Colors.white),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    height: size.height * 0.3,
                                    width: size.width,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(250),
                                        bottomRight: Radius.circular(1),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        isMorning
                                            ? const Center(
                                                child: Text(
                                                'Good Morning',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.orange),
                                              ))
                                            : timeOfDay2! >= 4
                                                ? const Text(
                                                    'Good Evening',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.orange),
                                                  )
                                                : const Text(
                                                    'Good Afternoon ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.orange),
                                                  ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text(
                                          'Welcome To E-rollCall',
                                          style: TextStyle(
                                              fontSize: 23,
                                              color: Colors.white30),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(25),
                                    child: !hasClass
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
//color: Colors.white30,
                                            ),
                                            width: size.width,
                                            height: size.height * 0.33,
                                            child: Card(
                                              color: Colors.white30,
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: const [
                                                    Center(
                                                      child: Text(
                                                          'Your class will appear here'),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                          'Pull down to refresh'),
                                                    ),
                                                    Center(
                                                      child: Icon(
                                                        Icons.refresh,
                                                        color: Colors.amber,
                                                        size: 30,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // color: Colors.white,
                                            ),
                                            width: size.width,
                                            height: size.height * 0.33,
                                            child: Card(
                                              color: Colors.white70,
                                              elevation: 10,
                                              child: Column(children: [
                                                const SizedBox(
                                                  height: 25,
                                                ),
                                                const Center(
                                                  child: Text(
                                                    'Class In Session',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Course:  $courseNameIn ',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Course Code:  $courseCodeIn',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Center(
                                                  child: Text(
                                                    'Lecturer:  $lectureFirstName $lecturerLastName',
                                                    style: const TextStyle(
                                                        fontSize: 18),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                              ]),
                                            ),
                                          ),
                                  ),
                                  hasClass
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15,
                                                left: 90,
                                                right: 90),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: !hasCheckedIn
                                                      ? Colors.purple
                                                      : Colors.grey,
                                                  side: const BorderSide(
                                                      width: 5,
                                                      color: Colors.purple),
                                                  minimumSize: const Size(
                                                      double.infinity, 40)),
                                              onPressed: !hasCheckedIn
                                                  ? () async {
                                                      try {
                                                        position =
                                                            await _determinePosition();
                                                        setState(() {
                                                          longitude = position
                                                              .longitude;
                                                          latitude =
                                                              position.latitude;
                                                        });

                                                        distanceCalculator(
                                                            latitude,
                                                            longitude,
                                                            lectureLogitude!,
                                                            lectureLatitude!);

                                                        submitCredentials(
                                                            distance);
                                                      } catch (error) {
                                                        showDialogBox(
                                                            'NetWork error or location access denied');
                                                      }
                                                    }
                                                  : () => Fluttertoast.showToast(
                                                      msg: 'Attempt Finished',
                                                      backgroundColor:
                                                          Colors.grey,
                                                      textColor: Colors.white),
                                              child: hasCheckedIn
                                                  ? const Text("Checked")
                                                  : const Text('Check In'),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text('Total  attendeded: $classAttended'),
                                      Text('Total Absents: $classAbsented'),
                                      CircleAvatar(
                                        backgroundColor: Colors.greenAccent,
                                        radius: 22,
                                        child: Text(
                                          '${(classAttended / (classAbsented + classAttended)) * 100}%',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                )
              ]),
            ),
    );
  }
}
