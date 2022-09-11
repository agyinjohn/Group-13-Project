// ignore_for_file: avoid_print, unnecessary_null_comparison

import 'package:attendancex/screens/category_login.dart';

import 'package:attendancex/screens/lecture_login.dart';
import 'package:attendancex/screens/onboarding_screen.dart';
import 'package:attendancex/screens/student_home_page.dart';
import 'package:attendancex/screens/student_login.dart';

import 'package:attendancex/widgets/tabs_controller.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(seconds: 2));

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isStudent;
  late String password;
  late bool showHome = false;
  late String email;
  Future<void> loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        email = prefs.getString('email') as String;
        showHome = prefs.getBool('ShowHome') as bool;
        password = prefs.getString('password') as String;
        isStudent = prefs.getBool('isStudent') as bool;
      });
      print('preData $isStudent');
      print(email);
      print(password);
    } catch (err) {
      print(err);
    }
  }

  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: showHome
          ? isStudent
              ? StudentHomepage(password)
              : TabsController(password)
          : const OnboardingScreen(),
      routes: {
        CategoryLoginScreen.routeName: (context) => const CategoryLoginScreen(),
        StudentLogin.routeName: (context) => const StudentLogin(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LectureLogin.routeName: (context) => const LectureLogin(),
        StudentHomepage.routeName: (context) =>
            StudentHomepage(StudentLogin.pasword),
        TabsController.routeName: (context) =>
            TabsController(showHome ? password : LectureLogin.pasword),
      },
    );
  }
}
