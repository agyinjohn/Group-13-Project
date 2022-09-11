// ignore_for_file: avoid_print, must_be_immutable

import 'package:attendancex/screens/attendance_check.dart';
import 'package:attendancex/screens/downloads_page.dart';
import 'package:attendancex/screens/lecture_homepage.dart';

import 'package:flutter/material.dart';

class TabsController extends StatefulWidget {
  String password;
  static String receipass = '';
  TabsController(
    this.password, {
    Key? key,
  }) : super(key: key);
  static const routeName = '/tabsScreen';

  @override
  State<TabsController> createState() => TabsControllerState();
}

class TabsControllerState extends State<TabsController> {
  DateTime? lastpressed;
  int currentIndexSelected = 0;

  late List<Widget> _pageList;

  void pageSelector(int index) {
    setState(() {
      currentIndexSelected = index;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _pageList = [
      LectureHompage(widget.password),
      AttendanceCheckPage(widget.password),
      const DownloadPage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      TabsController.receipass = widget.password;
      print('recieved password ${TabsController.receipass}');
    });
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final iswarning =
              lastpressed == null || now.difference(lastpressed!) > maxDuration;

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
        child: IndexedStack(
          index: currentIndexSelected,
          children: _pageList,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndexSelected,
        onTap: pageSelector,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.stream), label: 'Start Class'),
          BottomNavigationBarItem(
              icon: Icon(Icons.download_done_outlined), label: 'Downloads')
        ],
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.pink,
      ),
    );
  }
}
