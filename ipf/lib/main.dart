import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(
        title: 'IPF',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

var myGroup = 'ССА 18-11-2';

class _MyHomePageState extends State<MyHomePage> {
  Future _calculation = Future.delayed(
      Duration(seconds: 2), () => getTimetable(myGroup, 'Понедельник'));
  var lessons;
  var lessonsTexts = [];

  @override
  void initState() {
    super.initState();
    /*  setState(() async {
      lessons = await getTimetable('ССА 18-11-2', 'Понедельник');
      for (int i = 0; i < lessons.length; i++) {
        lessonsTexts.add(lessons[i].lesson);
      }
    });*/
  }

  int _groupDropDownValue = 1;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: mstroyBlue,
          centerTitle: true,
          title: Text(widget.title),
        ),
        backgroundColor: newBackgroundWhite,
        body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.center,
              child: Center(
                  child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Column(
                        children: [
                          DropdownButton(
                            value: _groupDropDownValue,
                            items: [
                              DropdownMenuItem(
                                child: Text('ССА 18-11-1'),
                                value: 1,
                              ),
                              DropdownMenuItem(
                                child: Text('ССА 18-11-2'),
                                value: 2,
                              )
                            ],
                            onChanged: (value){
                              setState(() {
                                _groupDropDownValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder(
                    future: _calculation,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        children = <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 100,
                                  child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      var lesson = snapshot.data[index];
                                      return Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                300,
                                        margin: EdgeInsets.all(10),
                                        // общий
                                        child: Row(
                                          // разделение на три колонки
                                          children: [
                                            Container(
                                              child: Text(lesson.numlesson),
                                              padding: EdgeInsets.all(5),
                                            ),
                                            // номер урока
                                            Container(
                                              //данные об уроке
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Text(lesson.lesson),
                                                  ), // название урока
                                                  Container(
                                                    child: Row(
                                                      // строка препода и кабинета
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                              lesson.teacher),
                                                        ), //препод
                                                        Container(
                                                          child:
                                                              Text(lesson.room),
                                                        ) //кабинет
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Text('00:00'),
                                            )
                                            //время начала и конца урока
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          )
                        ];
                      } else if (snapshot.hasError) {
                        children = <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ];
                      } else {
                        children = <Widget>[
                          SizedBox(
                            child: CircularProgressIndicator(),
                            width: 60,
                            height: 60,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Awaiting results'),
                          )
                        ];
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: children,
                        ),
                      );
                    },
                  ),
                  /*                 */
                ],
              ))),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => this.build(context)));
          },
          child: Icon(Icons.add),
          backgroundColor: mstroyBlue,
        ));
  }
}

Future<List> getTimetable(group, weekday) async {
  var lessonsArr = [];
  var url =
      'http://api.timetable-ipf.com/api/timetable?group=$group&weekday=$weekday';
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  for (int i = 0; i < decoded.length; i++) {
    var id = decoded[i]['id'];
    var group = decoded[i]['group'];
    var subgroup = decoded[i]['subgroup'];
    var teacher = decoded[i]['teacher'];
    var lesson = decoded[i]['lesson'];
    var numlesson = decoded[i]['numlesson'];
    var room = decoded[i]['room'];
    var weekday = decoded[i]['weekday'];
    lessonsArr.add(Lesson(
      id.toString(),
      group.toString(),
      subgroup.toString(),
      teacher.toString(),
      lesson.toString(),
      numlesson.toString(),
      room.toString(),
      weekday.toString(),
    ));
  }
  return lessonsArr;
}

Future<String> createLesson(
    group, weekday, subgroup, teacher, lesson, numlesson, room) async {
  var createdLesson =
      Lesson('', group, subgroup, teacher, lesson, numlesson, room, weekday);

  var lessons = [];

  lessons = await getTimetable(group, weekday);

  var switcher = 0;
  for (int i = 0; i < lessons.length; i++) {
    if (createdLesson.weekday == lessons[i].weekday) {
      if (createdLesson.numlesson == lessons[i].numlesson) {
        if (createdLesson.group == lessons[i].group) {
          switcher++;
        }
      }
    }
  }

  if (switcher == 0) {
    var url = 'http://api.timetable-ipf.com/api/timetable/create';
    var response = await http.post(url, body: {
      'group': createdLesson.group,
      'subgroup': createdLesson.subgroup,
      'teacher': createdLesson.teacher,
      'lesson': createdLesson.lesson,
      'numlesson': createdLesson.numlesson,
      'room': createdLesson.room,
      'weekday': createdLesson.weekday
    });
    return "create success";
  } else {
    return 'create failed';
  }
}

class Lesson {
  var id = "id";
  var group = "group";
  var subgroup = "subgroup";
  var teacher = "teacher";
  var lesson = "lesson";
  var numlesson = "numlesson";
  var room = "room";
  var weekday = "weekday";

  Lesson(id, group, subgroup, teacher, lesson, numlesson, room, weekday) {
    this.id = id;
    this.group = group;
    this.subgroup = subgroup;
    this.teacher = teacher;
    this.lesson = lesson;
    this.numlesson = numlesson;
    this.room = room;
    this.weekday = weekday;
  }
}

Future<Options> allOptions() async {
  var weekdaysOpt = [
    '0',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
    'Воскресенье'
  ];
  var numLessonsOpt = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];
  var subGroupsOpt = ['0', '1', '2'];
  var groupsOpt = [];
  var teachersOpt = [];
  var roomsOpt = [];
  var lessonsOpt = [];

  var url = 'http://api.timetable-ipf.com/api/timetable/options';
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var group = decoded['group'];
  for (int i = 0; i < group.length; i++) {
    groupsOpt.add(group[i]);
  }
/*  var subgroup = decoded['subgroup'];
  for (int i = 0; i < subgroup.length; i++) {
    subGroupsOpt.add(subgroup[i]);
  }*/
  var teacher = decoded['teacher'];
  for (int i = 0; i < teacher.length; i++) {
    teachersOpt.add(teacher[i]);
  }
  var lesson = decoded['lesson'];
  for (int i = 0; i < lesson.length; i++) {
    lessonsOpt.add(lesson[i]);
  }
  var room = decoded['room'];
  for (int i = 0; i < room.length; i++) {
    roomsOpt.add(room[i]);
  }

  var options = Options(url, response, decoded, groupsOpt, teachersOpt,
      lessonsOpt, roomsOpt, weekdaysOpt, numLessonsOpt, subGroupsOpt);
  return options;
}

class Options {
  var url;
  var response;
  var decoded;
  var groupsOpt = [];
  var teachersOpt = [];
  var lessonsOpt = [];
  var roomsOpt = [];
  var weekdaysOpt = [];
  var numLessonsOpt = [];
  var subGroupsOpt = [];

  Options(url, response, decoded, groupsOpt, teachersOpt, lessonsOpt, roomsOpt,
      weekdaysOpt, numLessonsOpt, subGroupsOpt) {
    this.url = url;
    this.response = response;
    this.decoded = decoded;
    this.groupsOpt = groupsOpt;
    this.teachersOpt = teachersOpt;
    this.lessonsOpt = lessonsOpt;
    this.roomsOpt = roomsOpt;
    this.weekdaysOpt = weekdaysOpt;
    this.numLessonsOpt = numLessonsOpt;
    this.subGroupsOpt = subGroupsOpt;
  }
}

Future<int> deleteLesson(id) async {
  var url = 'http://api.timetable-ipf.com/api/timetable/delete';
  var response = await http.post(url, body: {'id': id});
  return response.statusCode;
}
