import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'note_model.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  const EditorScreen({super.key, this.note});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? "");
    _contentController = TextEditingController(text: widget.note?.content ?? "");
  }

  Future<void> _handleAutoSave() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String? notesString = prefs.getString('notes_data');
    List<Note> notes = notesString != null ? Note.decode(notesString) : [];

    if (widget.note == null) {
      notes.add(Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        dateTime: DateTime.now(),
      ));
    } else {
      int index = notes.indexWhere((n) => n.id == widget.note!.id);
      if (index != -1) {
        notes[index] = Note(
          id: widget.note!.id,
          title: _titleController.text,
          content: _contentController.text,
          dateTime: DateTime.now(),
        );
      }
    }
    await prefs.setString('notes_data', Note.encode(notes));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) await _handleAutoSave();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Soạn thảo")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(hintText: "Tiêu đề", border: InputBorder.none),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: const InputDecoration(hintText: "Nội dung...", border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}