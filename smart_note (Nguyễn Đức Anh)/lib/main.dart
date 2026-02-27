import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'note_model.dart';
import 'editor_screen.dart';

void main() => runApp(const SmartNoteApp());

class SmartNoteApp extends StatelessWidget {
  const SmartNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.amber),
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
  List<Note> allNotes = [];
  List<Note> filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes_data');
    if (notesString != null) {
      setState(() {
        allNotes = Note.decode(notesString);
        filteredNotes = allNotes;
      });
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes_data', Note.encode(allNotes));
  }

  void _filterNotes(String query) {
    setState(() {
      filteredNotes = allNotes
          .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<bool?> _confirmDelete(int index) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc chắn muốn xóa ghi chú này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              setState(() {
                allNotes.removeWhere((element) => element.id == filteredNotes[index].id);
                _filterNotes(_searchController.text);
              });
              _saveNotes();
              Navigator.pop(context, true);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[200],
        title: const Text("Smart Note - [Tên SV] - [Mã SV]"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterNotes,
              decoration: InputDecoration(
                hintText: "Tìm kiếm...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? const Center(child: Text("Chưa có ghi chú nào!"))
                : MasonryGridView.count(
                    padding: const EdgeInsets.all(10),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Dismissible(
                        key: Key(note.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) => _confirmDelete(index),
                        background: Container(
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          child: InkWell(
                            onTap: () => _goToDetail(note),
                            onLongPress: () => _confirmDelete(index), // Xóa cho bản Web
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 10),
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(note.dateTime), style: const TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToDetail(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _goToDetail(Note? note) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => EditorScreen(note: note)));
    _loadNotes();
  }
}