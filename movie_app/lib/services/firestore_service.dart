import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/movie.dart';

class FirestoreService {
  late final FirebaseFirestore _db;

  FirestoreService() {
    _db = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'movies',
    );
    
    // Tắt tính năng lưu dữ liệu ngoại tuyến (Persistence)
    // Điều này buộc app luôn phải lấy dữ liệu từ server
    _db.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Fetch movies trực tiếp từ server. Nếu mất mạng sẽ throw Exception ngay lập tức.
  Future<List<Movie>> fetchMovies() async {
    try {
      final snapshot = await _db
          .collection('movies')
          .orderBy('title')
          .get(const GetOptions(source: Source.server)); // Buộc lấy từ server
      
      return snapshot.docs.map((d) => Movie.fromMap(d.id, d.data())).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw Exception('Không thể kết nối với máy chủ. Vui lòng kiểm tra kết nối mạng.');
      }
      throw Exception('Lỗi Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Stream movies trực tiếp. Khi mất mạng, Stream sẽ trả về lỗi.
  Stream<List<Movie>> streamMovies() {
    // Với stream, khi persistenceEnabled = false, nó sẽ báo lỗi nếu không kết nối được
    return _db
        .collection('movies')
        .orderBy('title')
        .snapshots()
        .map((snap) {
          // Kiểm tra xem dữ liệu có phải từ cache không (trong trường hợp hiếm gặp)
          if (snap.metadata.isFromCache) {
            throw Exception('Dữ liệu đang được lấy từ bộ nhớ tạm. Đang đợi kết nối mạng...');
          }
          return snap.docs.map((d) => Movie.fromMap(d.id, d.data())).toList();
        });
  }

  Future<Movie> addMovie(Movie movie) async {
    try {
      final docRef = await _db.collection('movies').add(movie.toMap());
      final snapshot = await docRef.get(const GetOptions(source: Source.server));
      return Movie.fromMap(snapshot.id, snapshot.data()!);
    } catch (e) {
      throw Exception('Không thể thêm phim. Kiểm tra kết nối mạng.');
    }
  }

  Future<void> updateMovie(Movie movie) async {
    try {
      await _db.collection('movies').doc(movie.id).update(movie.toMap());
    } catch (e) {
      throw Exception('Không thể cập nhật. Kiểm tra kết nối mạng.');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await _db.collection('movies').doc(id).delete();
    } catch (e) {
      throw Exception('Không thể xóa. Kiểm tra kết nối mạng.');
    }
  }

  Future<void> ensureSeeded(List<Movie> samples) async {
    try {
      final snapshot = await _db.collection('movies').limit(1).get(
        const GetOptions(source: Source.server)
      );
      if (snapshot.docs.isEmpty) {
        for (final m in samples) {
          await _db.collection('movies').add(m.toMap());
        }
      }
    } catch (_) {}
  }
}
