import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/error_retry.dart';
import '../widgets/movie_form.dart';
import '../constants.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FirestoreService _service = FirestoreService();
  late Stream<List<Movie>> _moviesStream;

  @override
  void initState() {
    super.initState();
    _moviesStream = _service.streamMovies();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _moviesStream = _service.streamMovies();
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showMovieDetails(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: EdgeInsets.zero,
        title: movie.posterUrl != null
            ? ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                child: Image.network(
                  movie.posterUrl!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 150,
                    color: Colors.black12,
                    child: const Icon(Icons.broken_image, size: 64),
                  ),
                ),
              )
            : Container(
                height: 150,
                color: Colors.black12,
                child: const Icon(Icons.movie, size: 64, color: Colors.grey),
              ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (movie.year != null)
                Text(
                  'Năm sản xuất: ${movie.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              const Text(
                'Mô tả:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                movie.description ?? 'Không có mô tả cho bộ phim này.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TH3 - $STUDENT_NAME - $STUDENT_ID'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Thêm phim mới',
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog<Movie>(
                context: context,
                builder: (_) => const AlertDialog(content: MovieForm()),
              );
              if (result != null) {
                try {
                  await _service.addMovie(result);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: StreamBuilder<List<Movie>>(
          stream: _moviesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: ErrorRetry(
                    message: snapshot.error.toString(),
                    onRetry: _onRefresh,
                  ),
                ),
              );
            }

            final movies = snapshot.data ?? [];
            if (movies.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.movie, size: 64, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No movies found'),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            final width = MediaQuery.of(context).size.width;
            final crossAxisCount = width > 900 ? 3 : 2;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    movie: movie,
                    onTap: () => _showMovieDetails(context, movie),
                    onEdit: () async {
                      final result = await showDialog<Movie>(
                        context: context,
                        builder: (_) => AlertDialog(content: MovieForm(movie: movie)),
                      );
                      if (result != null) {
                        try {
                          await _service.updateMovie(result);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      }
                    },
                    onDelete: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text('Bạn có muốn xóa mục này không?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Hủy')),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Xóa')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        try {
                          await _service.deleteMovie(movie.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
