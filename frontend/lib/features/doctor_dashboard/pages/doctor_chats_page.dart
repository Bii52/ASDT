import 'package:flutter/material.dart';

class DoctorChatsPage extends StatefulWidget {
  const DoctorChatsPage({super.key});

  @override
  State<DoctorChatsPage> createState() => _DoctorChatsPageState();
}

class _DoctorChatsPageState extends State<DoctorChatsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Doctor Chats Page'),
      ),
    );
  }
}
