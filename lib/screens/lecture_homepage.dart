// ignore_for_file: avoid_print, must_be_immutable, use_key_in_widget_constructors, deprecated_member_use

import 'dart:convert';

import 'package:attendancex/screens/category_login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LectureHompage extends StatefulWidget {
  static const routeName = '/lectureHomePage';
  LectureHompage(this.password);
  late String password;

  @override
  State<LectureHompage> createState() => _LectureHompageState();
}

class _LectureHompageState extends State<LectureHompage> {
  String timeOfDay = '';
  String firstName = '';
  String lastName = '';

  String email = '';
  String profile = '';

  bool isMorning = true;
  bool isLoading = false;

  final url =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/lecturer.json';

  Future<void> lectureDetails(String pass) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(url));
      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      print(extractedData);
      print(extractedData[pass]['firstname']);
      print(extractedData.containsKey(pass));

      if (timeOfDay == 'PM') {
        setState(() {
          isMorning = false;
        });
      }

      setState(() {
        firstName = extractedData[pass]['firstname'];
        lastName = extractedData[pass]['lastname'];

        email = extractedData[pass]['email'];
        profile = extractedData[pass]['profile'];
      });
      print('FirstName: $firstName');
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  void didChangeDependencies() {
    timeOfDay = DateFormat('a').format(DateTime.now());
    lectureDetails(widget.password);
    super.didChangeDependencies();
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
        elevation: 0,
        actions: [
          PopupMenuButton(
              itemBuilder: (context) => [
                    PopupMenuItem(
                        value: 'logout',
                        enabled: true,
                        onTap: logout,
                        child: const Text('Logout')),
                  ]),
          // IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert))
        ],
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //       gradient: LinearGradient(colors: [Colors.red, Colors.green])),
        // ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.white10, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.5,
                    width: size.width,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple]),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(150))),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(profile),
                              radius: 60,
                              child: Text(
                                firstName.characters.first.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 30, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            '$firstName $lastName',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.orangeAccent),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Text(email,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.orangeAccent)),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size.width,
                    height: size.height * 0.30,
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                            child: isMorning
                                ? const Text(
                                    'Good Morning ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.orangeAccent),
                                  )
                                : const Text(
                                    'Good Afternoon ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.orangeAccent),
                                  )),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(
                            child: Text(
                          'Welcome To E-RollCall',
                          style: TextStyle(fontSize: 26),
                        )),
                      ],
                    ),
                  ),
                ],
              )),
    );
  }
}
