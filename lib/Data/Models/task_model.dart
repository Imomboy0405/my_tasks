import 'dart:convert';
enum TaskStatus {completed, inProcess, notCompleted}

// List<TaskModel> tasksFromJson(String str) => jsonDecode(str).map((item) => TaskModel.fromJson(item)).toList<TaskModel>();
List<TaskModel> tasksFromJson(String encodedData) {
  List<dynamic> decodedList = jsonDecode(encodedData);
  return decodedList.map((item) => TaskModel.fromJson(item)).toList();
}
String tasksToJson(List<TaskModel> data) => jsonEncode(data.map((e) => e.toJson()).toList());

class TaskModel {
  TaskModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdTime,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  TaskModel.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    createdTime = DateTime.parse(json['createdTime']);
    startDate = DateTime.parse(json['startTime']);
    endDate = DateTime.parse(json['endTime']);
    status = switch (json['status']) {
      'completed' => TaskStatus.completed,
      'notCompleted' => TaskStatus.notCompleted,
      Object() => TaskStatus.inProcess,
      null => TaskStatus.inProcess,
    };
  }
  String? id;
  String? title;
  String? content;
  DateTime? createdTime;
  DateTime? startDate;
  DateTime? endDate;
  TaskStatus? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['content'] = content;
    map['createdTime'] = createdTime!.toIso8601String();
    map['startTime'] = startDate!.toIso8601String();
    map['endTime'] = endDate!.toIso8601String();
    map['status'] = status!.name;
    return map;
  }
}
