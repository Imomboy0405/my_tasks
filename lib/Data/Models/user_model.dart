import 'dart:convert';

UserModel userFromJson(String str) => UserModel.fromJson(json.decode(str));
String userToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? uId;
  String? createdTime;

  UserModel({
    required this.uId,
    required this.createdTime,
  });

  UserModel.fromJson(Map<dynamic, dynamic> json) {
    uId = json['uId'];
    createdTime = json['createdTime'];
  }

  Map<String, String?> toJson() {
    final map = <String, String?>{};
    map['uId'] = uId;
    map['createdTime'] = createdTime;
    return map;
  }
}