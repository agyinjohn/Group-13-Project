import 'package:flutter/material.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool hasAttendance = false;
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('You have no attendance yet'),
    ));
  }
}
