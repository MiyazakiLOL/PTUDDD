import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/movie.dart';

class FirestoreService {
  // Cần cung cấp 'app' khi sử dụng databaseId khác mặc định
  final FirebaseFirestore _db = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'movies',
  );

  /// Fetch movies from 'movies' collection. Uses try-catch to surface errors.
  Future<List<Movie>> fetchMovies() async {
    try {
      final snapshot = await _db.collection('movies').orderBy('title').get();
      return snapshot.docs.map((d) => Movie.fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      // Surface Firestore-specific errors
      throw Exception('FirebaseException: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while fetching movies: $e');
    }
  }

  /// Real-time stream of movies ordered by title.
  Stream<List<Movie>> streamMovies() {
    try {
      return _db.collection('movies').orderBy('title').snapshots().map(
            (snap) => snap.docs.map((d) => Movie.fromMap(d.id, d.data())).toList(),
          );
    } catch (e) {
      // Convert sync exceptions into a stream that emits an error.
      return Stream.error('Error creating movies stream: $e');
    }
  }

  Future<Movie> addMovie(Movie movie) async {
    try {
      final docRef = await _db.collection('movies').add(movie.toMap());
      final snapshot = await docRef.get();
      return Movie.fromMap(snapshot.id, snapshot.data()!);
    } on FirebaseException catch (e) {
      throw Exception('FirebaseException: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while adding movie: $e');
    }
  }

  Future<void> updateMovie(Movie movie) async {
    try {
      await _db.collection('movies').doc(movie.id).update(movie.toMap());
    } on FirebaseException catch (e) {
      throw Exception('FirebaseException: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while updating movie: $e');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await _db.collection('movies').doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('FirebaseException: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error while deleting movie: $e');
    }
  }

  /// If the `movies` collection is empty, add the provided sample movies.
  Future<void> ensureSeeded(List<Movie> samples) async {
    try {
      final snapshot = await _db.collection('movies').limit(1).get();
      if (snapshot.docs.isEmpty) {
        for (final m in samples) {
          await _db.collection('movies').add(m.toMap());
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('FirebaseException during seeding: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error during seeding: $e');
    }
  }
}
