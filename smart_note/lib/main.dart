import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/note.dart';
import 'storage.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Note',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  String _query = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notes = await Storage.loadNotes();
    setState(() => _notes = notes);
  }

  List<Note> get _filtered {
    if (_query.isEmpty) return _notes;
    final q = _query.toLowerCase();
    return _notes.where((n) => n.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _onAdd() async {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      content: '',
      modifiedAt: DateTime.now(),
    );
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => EditScreen(note: newNote),
    ));
    await _load();
  }

  Future<bool> _confirmDelete(Note note) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
        ],
      ),
    );
    return r == true;
  }

  @override
  Widget build(BuildContext context) {
    final notes = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Note - Vũ Tuấn Hiệp - 2351160517'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tiêu đề...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_alt, size: 120, color: Colors.grey.withOpacity(0.3)),
                        const SizedBox(height: 12),
                        const Text('Bạn chưa có ghi chú nào, hãy tạo mới nhé!', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: MasonryGridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Dismissible(
                          key: Key(note.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmDelete(note),
                          onDismissed: (_) async {
                            await Storage.deleteNoteById(note.id);
                            await _load();
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditScreen(note: note)));
                              await _load();
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(note.title.isEmpty ? '(Không có tiêu đề)' : note.title,
                                        maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black.withOpacity(0.7))),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(DateFormat('dd/MM/yyyy HH:mm').format(note.modifiedAt), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  final Note note;
  const EditScreen({super.key, required this.note});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _note;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _titleController = TextEditingController(text: _note.title);
    _contentController = TextEditingController(text: _note.content);
  }

  Future<void> _autoSave() async {
    _note = Note(
      id: _note.id,
      title: _titleController.text,
      content: _contentController.text,
      modifiedAt: DateTime.now(),
    );
    await Storage.addOrUpdateNote(_note);
  }

  Future<bool> _onWillPop() async {
    await _autoSave();
    return true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Soạn ghi chú'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(border: InputBorder.none, hintText: 'Tiêu đề'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'Nội dung...'),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

