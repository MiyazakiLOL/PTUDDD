import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime dateTime;

  Note({required this.id, required this.title, required this.content, required this.dateTime});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        dateTime: DateTime.parse(json['dateTime']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'dateTime': dateTime.toIso8601String(),
      };

  static String encode(List<Note> notes) =>
      json.encode(notes.map<Map<String, dynamic>>((note) => note.toJson()).toList());

  static List<Note> decode(String notes) =>
      (json.decode(notes) as List<dynamic>).map<Note>((item) => Note.fromJson(item)).toList();
}