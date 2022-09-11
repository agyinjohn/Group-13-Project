// ignore_for_file: deprecated_member_use, constant_identifier_names, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:attendancex/screens/lecture_login.dart';
import 'package:attendancex/screens/student_home_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class StudentLogin extends StatefulWidget {
  static const routeName = '/auth';
  static dynamic pasword;
  const StudentLogin({Key? key}) : super(key: key);
  // ignore: prefer_final_fields

  @override
  State<StudentLogin> createState() => _StudentLoginState();
}

class _StudentLoginState extends State<StudentLogin> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0, 1],
                ),
              ),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      'Student Login',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Flexible(
                    child: AuthCard(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class AuthCard extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  late Map<String, dynamic> extractedData = {};
  final url =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/student.json';

  Future<void> studentDetails() async {
    try {
      final response = await http.get(Uri.parse(url));
      extractedData = json.decode(response.body);
      print(extractedData);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  void didChangeDependencies() {
    studentDetails();
    super.didChangeDependencies();
  }

  //final _auth = FirebaseAuth.instance;
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  bool isPasswordVisible = true;
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

  final GlobalKey<FormState> _formKey = GlobalKey();
  var isLoading = false;
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    var errmessage = "Login Failed";
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyChgU_LVacm77ddKmas_5uluW98z8p2zMg";

    FocusScope.of(context).unfocus();
    if (extractedData.containsKey(passwordTextController.text.trim())) {
      try {
        final response = await http.post(
          Uri.parse(url),
          body: json.encode({
            'email': emailTextController.text.trim(),
            'password': passwordTextController.text.trim(),
            'returnSecureToken': true
          }),
        );
        setState(() {
          isLoading = false;
        });

        //  print(json.decode(response.body));
        final errorResponse = json.decode(response.body);

        if (errorResponse['error'] != null) {
          errmessage = errorResponse['error']['message'];
          if (errmessage.contains('INVALID_EMAIL')) {
            errmessage = 'Please  Invalid Email Address';
          }
          errmessage = 'Please Invalid Password or Email Address';
          showDialogBox(errmessage);
        } else {
          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setBool('ShowHome', true);
          sharedPreferences.setBool('isStudent', true);
          sharedPreferences.setString('email', emailTextController.text.trim());
          sharedPreferences.setString(
              'password', passwordTextController.text.trim());

          Fluttertoast.showToast(
            msg: 'Seccessful Login',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
          );
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (ctx) =>
                  StudentHomepage(passwordTextController.text.trim())));
          setState(() {
            StudentLogin.pasword = passwordTextController.text.trim();
          });
        }
      } catch (err) {
        print('Main Error $err');
        var message = "$err";
        showDialogBox(message);
        setState(() {
          isLoading = false;
        });
      }
    } else if (!extractedData.containsKey(passwordTextController.text.trim())) {
      showDialogBox('Couldn\'t Login, Try again Later');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    emailTextController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                  hintText: 'example@domain.com',
                  suffixIcon: emailTextController.text.isEmpty
                      ? Container(
                          width: 0,
                        )
                      : IconButton(
                          onPressed: () {
                            emailTextController.clear();
                          },
                          icon: const Icon(Icons.close)),
                  labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
              controller: emailTextController,
              validator: (value) {
                if (value == '') {
                  return 'Please Email field is Empty.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.perm_identity),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    icon: !isPasswordVisible
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  ),
                  labelText: 'Password'),
              obscureText: isPasswordVisible,
              controller: passwordTextController,
              validator: (value) {
                if (value == '') {
                  return 'Please Password field is Empty.';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            isLoading
                ? const CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  )
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('LOGIN'),
                  ),
            const SizedBox(
              height: 30,
            ),
            FlatButton(
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(LectureLogin.routeName),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textColor: Theme.of(context).primaryColor,
              child: const Text('LOGIN AS LECTURE INSTEAD'),
            ),
          ],
        ),
      ),
    );
  }
}
