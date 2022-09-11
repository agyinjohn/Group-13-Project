import 'package:attendancex/screens/lecture_login.dart';
import 'package:attendancex/screens/student_login.dart';
import 'package:flutter/material.dart';

class CategoryLoginScreen extends StatefulWidget {
  const CategoryLoginScreen({Key? key}) : super(key: key);
  static const routeName = '/CategoryScreen';

  @override
  State<CategoryLoginScreen> createState() => _CategoryLoginScreenState();
}

class _CategoryLoginScreenState extends State<CategoryLoginScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.purple])),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
            height: 20,
          ),
          const Text('Please Select Your Category',
              style: TextStyle(fontSize: 20, color: Colors.white)),
          const SizedBox(height: 40),
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Card(
              color: Colors.white,
              child: CircleAvatar(
                maxRadius: 60,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(LectureLogin.routeName),
                  child: Image.asset('lib/assets/images/lecture.jpg'),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(LectureLogin.routeName),
            child: Card(
                elevation: 10,
                color: Colors.black87,
                child: Container(
                  height: 20,
                  width: 100,
                  color: Colors.black87,
                  child: const Text(
                    'Lecturer',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                )),
          ),
          const SizedBox(
            height: 50,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Card(
              child: CircleAvatar(
                maxRadius: 60,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(StudentLogin.routeName),
                  child: Image.asset(
                    'lib/assets/images/student.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(StudentLogin.routeName),
            child: Card(
                elevation: 10,
                color: Colors.black87,
                child: Container(
                  height: 20,
                  width: 100,
                  color: Colors.black87,
                  child: const Text(
                    'Student',
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}
