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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet cao hơn
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo ở đầu
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Ảnh Poster lớn
              if (movie.posterUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.posterUrl!,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 200,
                        color: Colors.black12,
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.movie, size: 64, color: Colors.grey)),
                ),
              // Nội dung văn bản
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            movie.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                          ),
                        ),
                        if (movie.year != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${movie.year}',
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mô tả nội dung',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.description ?? 'Không có thông tin mô tả cho bộ phim này.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Nút đóng
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Đóng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
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
