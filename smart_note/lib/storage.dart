import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'models/note.dart';

class Storage {
  static const _kNotesKey = 'smart_notes_v1';

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => Note.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(notes.map((e) => e.toMap()).toList());
    await prefs.setString(_kNotesKey, encoded);
  }

  static Future<void> addOrUpdateNote(Note n) async {
    final notes = await loadNotes();
    final idx = notes.indexWhere((e) => e.id == n.id);
    if (idx >= 0) {
      notes[idx] = n;
    } else {
      notes.insert(0, n);
    }
    await saveNotes(notes);
  }

  static Future<void> deleteNoteById(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((e) => e.id == id);
    await saveNotes(notes);
  }
}
