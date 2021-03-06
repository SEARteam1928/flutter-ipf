import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:ipf/colors.dart';

class Admin extends StatefulWidget {
  Admin({Key key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

var underLineColor = blue;

List<String> groups = [''];
var myGroup = 'АТ 17-09';
var day = 'Понедельник';
Lesson lessonForAdding = Lesson('', '', '', '', '', '', '', '');

class _AdminState extends State<Admin> {
  TextEditingController groupController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController lessonController = TextEditingController();
  TextEditingController teacherController = TextEditingController();
  TextEditingController numLessonController = TextEditingController();
  TextEditingController subGroupController = TextEditingController();
  TextEditingController roomController = TextEditingController();

  Future _lessons =
      Future.delayed(Duration(seconds: 2), () => getTimetable(myGroup, day));
  Future _groups = Future.delayed(Duration(seconds: 2), () => allGroups());
  var lessons;
  var lessonsTexts = [];

  @override
  void initState() {
    super.initState();
  }

  int _groupDropDownValue = 1;
  int _dayDropDownValue = 1;
  int _loadInt = 1;
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

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: newBackgroundWhite,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: mstroyBlue,
        centerTitle: true,
        title: Text("IPF Admin"),
      ),
      body: SingleChildScrollView(
        child: Container(
            color: newBackgroundWhite,
            alignment: Alignment.center,
            child: Center(
                child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              _textField(
                                  groupController,
                                  Icon(Icons.assignment),
                                  false,
                                  "Группа",
                                  20),
                              _textField(
                                  dayController,
                                  Icon(Icons.assignment),
                                  false,
                                  "День недели",
                                  20),
                              _textField(
                                  lessonController,
                                  Icon(Icons.assignment),
                                  false,
                                  "Название занятия",
                                  20),
                              _textField(
                                  teacherController,
                                  Icon(Icons.assignment),
                                  false,
                                  "Преподаватель",
                                  20),
                              _textField(
                                  numLessonController,
                                  Icon(Icons.assignment),
                                  false,
                                  "Номер урока",
                                  20),
                              _textField(
                                  subGroupController,
                                  Icon(Icons.assignment),
                                  false,
                                  "Подгруппа",
                                  20),
                              _textField(roomController, Icon(Icons.assignment),
                                  false, "Кабинет", 20),
                            ],
                          ),
                          Column()
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 50, bottom: 20),
                  child: CupertinoButton(
                    child: Text("Добавить урок"),
                    onPressed: () async {
                      var toastString = lessonController.text +
                          teacherController.text +
                          numLessonController.text +
                          roomController.text +
                          subGroupController.text;
                      Fluttertoast.showToast(msg: toastString);
                      await createLesson(groupController.text, dayController.text, subGroupController.text, teacherController.text, lessonController.text, numLessonController.text, roomController.text);
                    },
                    color: mstroyLightBlue,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: FutureBuilder(
                        future: _groups,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          List<Widget> children;
                          if (snapshot.hasData) {
                            children = <Widget>[
                              DropdownButton(
                                value: _groupDropDownValue,
                                items: snapshot.data
                                    as List<DropdownMenuItem<int>>,
                                onChanged: (value) {
                                  setState(() {
                                    _groupDropDownValue = value;
                                    myGroup = groups[value];
                                    _groups = Future.delayed(
                                        Duration(seconds: 2),
                                        () => allGroups());
                                    _lessons = Future.delayed(
                                        Duration(seconds: 2),
                                        () => getTimetable(myGroup, day));
                                  });
                                },
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
                                child: Container(
                                  width: 200,
                                  child: Text('Error: ${snapshot.error}'),
                                ),
                              )
                            ];
                          } else {
                            children = <Widget>[
                              DropdownButton(
                                value: _loadInt,
                                items: [
                                  DropdownMenuItem(
                                    child: Text('Загрузка групп'),
                                    value: 1,
                                  )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _loadInt = value;
                                  });
                                },
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
                    ),
                    Container(
                      child: Center(
                        child: Column(
                          children: [
                            DropdownButton(
                              value: _dayDropDownValue,
                              items: [
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[1]),
                                  value: 1,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[2]),
                                  value: 2,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[3]),
                                  value: 3,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[4]),
                                  value: 4,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[5]),
                                  value: 5,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[6]),
                                  value: 6,
                                ),
                                DropdownMenuItem(
                                  child: Text(weekdaysOpt[7]),
                                  value: 7,
                                )
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _dayDropDownValue = value;
                                  day = weekdaysOpt[value];
                                  _lessons = Future.delayed(
                                      Duration(seconds: 2),
                                      () => getTimetable(myGroup, day));
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: FutureBuilder(
                    future: _lessons,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        children = <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 120,
                                  child: ListView.builder(
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      var lesson = snapshot.data[index];
                                      return ConstrainedBox(
                                        constraints:
                                            BoxConstraints(minHeight: 80),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: white,
                                          ),
                                          margin: EdgeInsets.all(7),
                                          // общий
                                          child: Row(
                                            // разделение на три колонки
                                            children: [
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minHeight: 80),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          newButtonMstroyBlue),
                                                  width: screenWidth / 13,
                                                  child: Text(
                                                    lesson.numlesson,
                                                    style: TextStyle(
                                                        color: white,
                                                        fontFamily:
                                                            'Montserrat-Bold'),
                                                  ),
                                                  padding: EdgeInsets.all(5),
                                                ),
                                              ), // номер урока
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minHeight: 80),
                                                child: Container(
                                                  width: screenWidth * 0.75,
                                                  //данные об уроке
                                                  child: Column(
                                                    children: [
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                                minHeight: 50,
                                                                minWidth:
                                                                    screenWidth -
                                                                        100),
                                                        child: Container(
                                                          child: Text(
                                                              lesson.lesson),
                                                        ),
                                                      ), // название урока
                                                      Container(
                                                        child: Row(
                                                          // строка препода и кабинета
                                                          children: [
                                                            ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minHeight:
                                                                          30,
                                                                      minWidth:
                                                                          screenWidth -
                                                                              200),
                                                              child: Container(
                                                                child: Text(lesson
                                                                    .teacher),
                                                              ),
                                                            ),
                                                            //препод
                                                            ConstrainedBox(
                                                                constraints: BoxConstraints(
                                                                    minHeight:
                                                                        30,
                                                                    minWidth:
                                                                        screenWidth -
                                                                            330),
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                      lesson
                                                                          .room),
                                                                ) //кабинет,
                                                                ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    minWidth: screenWidth - 380,
                                                    minHeight: 80),
                                                child: Container(
                                                  child: Text('00:00'),
                                                ),
                                              )
                                              //время начала и конца урока
                                            ],
                                          ),
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
                ),

                /*                 */
              ],
            ))),
      ),
    );
  }
}

Widget _textField(TextEditingController controller, Widget ico, bool obscure,
    String hintText, double containerMargin) {
  return Container(
    width: 300,
    margin: EdgeInsets.only(top: containerMargin, bottom: containerMargin),
    decoration: BoxDecoration(
      color: backgroundWhite,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(1),
          bottomLeft: Radius.circular(1)),
    ),
    child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          suffixIcon: Container(
            child: ico,
            padding: EdgeInsets.all(14),
          ),
          border: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: underLineColor),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding:
              EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
          hintText: hintText,
        )),
  );
}

Future<List> getTimetable(group, weekday) async {
  var lessonsArr = [];
  var url =
      'https://api.timetable-ipf.com/api/timetable?group=$group&weekday=$weekday';
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
    var url = 'https://api.timetable-ipf.com/api/timetable/create';
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

Future<List<DropdownMenuItem<int>>> allGroups() async {
  groups = [''];
  List<DropdownMenuItem<int>> groupsOpt = [];
  var url = 'https://api.timetable-ipf.com/api/timetable/options';
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var group = decoded['group'];
  for (int i = 0; i < group.length; i++) {
    groups.add(group[i].toString());
    groupsOpt.add(DropdownMenuItem(
      child: Text(group[i].toString()),
      value: i + 1,
    ));
  }

  return groupsOpt;
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

  var url = 'https://api.timetable-ipf.com/api/timetable/options';
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
  var url = 'https://api.timetable-ipf.com/api/timetable/delete';
  var response = await http.post(url, body: {'id': id});
  return response.statusCode;
}
