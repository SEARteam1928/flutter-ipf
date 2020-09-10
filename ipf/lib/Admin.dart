import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectList extends StatefulWidget {
  ProjectList({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ProjectList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        centerTitle: true,
      ),
    );
  }

}