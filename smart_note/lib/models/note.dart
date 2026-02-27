import 'dart:convert';

class Note {
  String id;
  String title;
  String content;
  DateTime modifiedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      modifiedAt: DateTime.parse(map['modifiedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
