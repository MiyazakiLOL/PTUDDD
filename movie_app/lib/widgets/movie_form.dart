import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieForm extends StatefulWidget {
  final Movie? movie;

  const MovieForm({super.key, this.movie});

  @override
  State<MovieForm> createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _posterController;
  late TextEditingController _yearController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _descController = TextEditingController(text: widget.movie?.description ?? '');
    _posterController = TextEditingController(text: widget.movie?.posterUrl ?? '');
    _yearController = TextEditingController(text: widget.movie?.year?.toString() ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _posterController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final movie = Movie(
      id: widget.movie?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      posterUrl: _posterController.text.trim().isEmpty ? null : _posterController.text.trim(),
      year: int.tryParse(_yearController.text.trim()),
    );
    Navigator.of(context).pop(movie);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _posterController,
                decoration: const InputDecoration(labelText: 'Poster URL'),
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Năm'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submit, child: const Text('Lưu')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
