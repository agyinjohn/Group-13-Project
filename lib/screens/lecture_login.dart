// ignore_for_file: deprecated_member_use, constant_identifier_names, avoid_print

import 'dart:convert';

import 'package:attendancex/screens/student_login.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/tabs_controller.dart';

class LectureLogin extends StatefulWidget {
  static const routeName = '/lecture';
  static dynamic email = '';
  static dynamic pasword;
  const LectureLogin({Key? key}) : super(key: key);
  // ignore: prefer_final_fields

  @override
  State<LectureLogin> createState() => _LectureLoginState();
}

class _LectureLoginState extends State<LectureLogin> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 100),
                  const Text(
                    'Lecturer Login',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 25,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
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
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController emailTextcontroller = TextEditingController();
  TextEditingController passwordTextcontroller = TextEditingController();
  bool isPasswordVissible = true;
  late Map<String, dynamic> extractedData = {};
  final url =
      'https://attendance-app-5b53b-default-rtdb.firebaseio.com/lecturer.json';

  Future<void> lectureDetails() async {
    try {
      final response = await http.get(Uri.parse(url));
      extractedData = json.decode(response.body);
      print(extractedData);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  void initState() {
    emailTextcontroller.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void didChangeDependencies() {
    lectureDetails();
    super.didChangeDependencies();
  }

  void showDialogBox(String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text(
              'Error',
              textAlign: TextAlign.center,
            ),
            content: Text(message),
            actions: [
              FlatButton(
                  onPressed: Navigator.of(ctx).pop, child: const Text('OK'))
            ],
          );
        });
  }

  var _isLoading = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    var errmessage = "Login Failed";
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save;
    setState(() {
      _isLoading = true;
    });
    const url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyChgU_LVacm77ddKmas_5uluW98z8p2zMg";
    FocusScope.of(context).unfocus();

    if (extractedData.containsKey(passwordTextcontroller.text.trim())) {
      try {
        final response = await http.post(
          Uri.parse(url),
          body: json.encode({
            'email': emailTextcontroller.text.trim(),
            'password': passwordTextcontroller.text.trim(),
            'returnSecureToken': true
          }),
        );
        setState(() {
          _isLoading = false;
        });

        print('Email: $emailTextcontroller');
        print('Password: $passwordTextcontroller');
        print(json.decode(response.body));
        final errorResponse = json.decode(response.body);
        if (errorResponse['error'] != null) {
          errmessage = errorResponse['error']['message'];
          if (errmessage.contains('INVALID_EMAIL')) {
            errmessage = 'Please  Invalid Email Address';
          }
          errmessage = 'Please Invalid Password or Email Address';
          showDialogBox(errmessage);
        } else {
          Fluttertoast.showToast(
            msg: 'Successful Login',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            fontSize: 15,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
          );

          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();

          sharedPreferences.setBool('ShowHome', true);
          sharedPreferences.setBool('isStudent', false);
          sharedPreferences.setString('email', emailTextcontroller.text.trim());
          sharedPreferences.setString(
              'password', passwordTextcontroller.text.trim());

          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (_) =>
                  TabsController(passwordTextcontroller.text.trim())));

          LectureLogin.email = emailTextcontroller;
          setState(() {
            LectureLogin.pasword = passwordTextcontroller.text.trim();
          });
        }
      } catch (err) {
        print('Main Error $err');
        var message = "Couldn't Sign In, Try Again Later";
        showDialogBox(message);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      showDialogBox('Check your credentials and try again or contact admin');
      setState(() {
        _isLoading = false;
      });
    }
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
              controller: emailTextcontroller,
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'example@domain.com',
                  fillColor: Colors.white,
                  suffixIcon: emailTextcontroller.text.isEmpty
                      ? Container(
                          width: 0,
                        )
                      : IconButton(
                          onPressed: () {
                            emailTextcontroller.clear();
                          },
                          icon: const Icon(Icons.close)),
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == '') {
                  return 'Please Provide an Email';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.perm_identity),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        isPasswordVissible = !isPasswordVissible;
                      });
                    },
                    icon: !isPasswordVissible
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                  ),
                  labelText: 'Staff ID'),
              obscureText: isPasswordVissible,
              textInputAction: TextInputAction.done,
              controller: passwordTextcontroller,
              validator: (value) {
                if (value == '') {
                  return 'Please Provide a Staff ID';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _submit,
                child: const Text('LOGIN'),
              ),
            const SizedBox(
              height: 30,
            ),
            FlatButton(
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(StudentLogin.routeName),
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              child: const Text(
                'LOGIN AS STUDENT INSTEAD',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
