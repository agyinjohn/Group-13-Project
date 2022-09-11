// import 'dart:async';
// import 'dart:io';

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// import 'package:path_provider/path_provider.dart';

// class DBHelper {
//   DBHelper._privateContructor();
//   static final DBHelper instance = DBHelper._privateContructor();
//   static Database? _database;
//   Future<Database> get database async => _database ??= await _initDatabse();

//   Future<Database> _initDatabse() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path, 'userData.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

// ignore_for_file: avoid_print, use_build_context_synchronously

//   FutureOr<void> _onCreate(Database db, int version) async {
//     await db.execute(
//         '''CREATE TABLE user (id INTEGER PRIMARY KEY, email TEXT)''');
//   }
// }
// import 'package:attendancex/screens/lecture_homepage.dart';
// import 'package:attendancex/screens/student_home_page.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class AutoLogin {
//   static Future signInWithEmailAndPassword(bool isStudent, String password,
//       String email, BuildContext context) async {
//     const url =
//         "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyChgU_LVacm77ddKmas_5uluW98z8p2zMg";

//     FocusScope.of(context).unfocus();

//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: json.encode(
//             {'email': email, 'password': password, 'returnSecureToken': true}),
//       );
//       Navigator.of(context).pushReplacementNamed(
//           isStudent ? StudentHomepage.routeName : LectureHompage.routeName,
//           arguments: password);
//     } catch (err) {
//       showDialog(
//           context: context,
//           builder: (ctx) {
//             return const AlertDialog(
//               title: Text(
//                 'NetWork Error',
//                 textAlign: TextAlign.center,
//               ),
//               content: Text('Please Try Again Later'),
//             );
//           });
//     }
//   }
// }
