import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
/*
  var lessonss = getTimetable(lessons);
*/
/*  getTimetable("ССА 18-11-2", weekdaysOpt[1], lessons);
  createLesson("ССА 18-11-2", weekdaysOpt[1], 'subgroup','teacher','lesson','numlesson','room');
  deleteLesson('');*/
  createLesson("АТ 17-09", 'Понедельник', '1', 'Говоров В.О.',
      'Танководство', '12', '999');

  allGroups();
}

Future<List> getTimetable(group, weekday, lessonsArr) async {
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
    print(id.toString());
    print(group.toString());
    print(subgroup.toString());
    print(teacher.toString());
    print(lesson.toString());
    print(numlesson.toString());
    print(room.toString());
    print(weekday.toString());
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

  lessons = await getTimetable(group, weekday, lessons);

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
Future<List<String>> allGroups() async {

  List<String> groupsOpt = [];
  var url = 'http://api.timetable-ipf.com/api/timetable/options';
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var group = decoded['group'];
  for (int i = 0; i < group.length; i++) {
    groupsOpt.add(group[i].toString());
    print(group[i]);
  }
print(jsonDecode(response.body)['group'][0].toString());
  print(groupsOpt);

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

  var url = 'http://api.timetable-ipf.com/api/timetable/options';
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var group = decoded['group'];
  for (int i = 0; i < group.length; i++) {
    groupsOpt.add(group[i]);
    print(group[i]);
  }
/*  var subgroup = decoded['subgroup'];
  for (int i = 0; i < subgroup.length; i++) {
    subGroupsOpt.add(subgroup[i]);
  }*/
  var teacher = decoded['teacher'];
  for (int i = 0; i < teacher.length; i++) {
    teachersOpt.add(teacher[i]);
    print(teacher[i]);
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
