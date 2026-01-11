import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing favorite video likes in Firebase
/// Collection: "favourite videos"
/// Fields: id, title, numberFavourite (like count)
class ReelsLikesService {
  static final ReelsLikesService _instance = ReelsLikesService._internal();
  factory ReelsLikesService() => _instance;
  ReelsLikesService._internal();

  static ReelsLikesService get instance => _instance;

  final CollectionReference _favouriteVideosCollection = FirebaseFirestore
      .instance
      .collection('favourite videos');

  /// Test Firebase connection
  Future<bool> testConnection() async {
    try {
      await _favouriteVideosCollection.limit(1).get();
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection test failed: $e');
      return false;
    }
  }

  /// Initialize a video in Firebase if it doesn't exist
  /// Creates document with id, title, and numberFavourite = 0
  Future<void> initializeVideoLike({
    required String videoId,
    required String title,
  }) async {
    try {
      final docRef = _favouriteVideosCollection.doc(videoId);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({'id': videoId, 'title': title, 'numberFavourite': 0});
        debugPrint('✅ Initialized video like: $videoId');
      }
    } catch (e) {
      debugPrint('❌ Error initializing video like: $e');
      rethrow;
    }
  }

  /// Increment the favorite count for a video
  Future<void> incrementLike({
    required String videoId,
    required String title,
  }) async {
    try {
      final docRef = _favouriteVideosCollection.doc(videoId);

      // Use transaction to ensure atomic increment
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          final currentCount = data?['numberFavourite'] as int? ?? 0;
          transaction.update(docRef, {
            'numberFavourite': currentCount + 1,
            'title': title, // Update title in case it changed
          });
        } else {
          // Create new document if it doesn't exist
          transaction.set(docRef, {
            'id': videoId,
            'title': title,
            'numberFavourite': 1,
          });
        }
      });

      debugPrint('✅ Incremented like for video: $videoId');
    } catch (e) {
      debugPrint('❌ Error incrementing like: $e');
      rethrow;
    }
  }

  /// Decrement the favorite count for a video
  Future<void> decrementLike({required String videoId}) async {
    try {
      final docRef = _favouriteVideosCollection.doc(videoId);

      // Use transaction to ensure atomic decrement
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          final currentCount = data?['numberFavourite'] as int? ?? 0;
          final newCount = (currentCount > 0) ? currentCount - 1 : 0;

          transaction.update(docRef, {'numberFavourite': newCount});
        }
        // If document doesn't exist, do nothing
      });

      debugPrint('✅ Decremented like for video: $videoId');
    } catch (e) {
      debugPrint('❌ Error decrementing like: $e');
      rethrow;
    }
  }

  /// Get the current favorite count for a video
  Future<int> getLikeCount(String videoId) async {
    try {
      final doc = await _favouriteVideosCollection.doc(videoId).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['numberFavourite'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      debugPrint('❌ Error getting like count: $e');
      return 0;
    }
  }

  /// Watch like count changes in real-time
  /// Returns a stream of like counts for the video
  Stream<int> watchLikeCount(String videoId) {
    try {
      return _favouriteVideosCollection.doc(videoId).snapshots().map((
        snapshot,
      ) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          return data?['numberFavourite'] as int? ?? 0;
        }
        return 0;
      });
    } catch (e) {
      debugPrint('❌ Error watching like count: $e');
      return Stream.value(0);
    }
  }
}
