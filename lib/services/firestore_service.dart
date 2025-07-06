import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user or throw exception
  User _getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user;
  }

  // Fetch all notes for current user
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    try {
      final user = _getCurrentUser();

      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: user.uid)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'text': data['text'] ?? '',
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
          'userId': data['userId'],
        };
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Permission denied. Please check your authentication and Firestore rules.',
        );
      }
      throw Exception('Failed to fetch notes: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch notes: $e');
    }
  }

  // Add a new note
  Future<void> addNote(String text) async {
    try {
      final user = _getCurrentUser();

      await _firestore.collection('notes').add({
        'text': text,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Unable to add note.');
      }
      throw Exception('Failed to add note: ${e.message}');
    } catch (e) {
      throw Exception('Failed to add note: $e');
    }
  }

  // Update a note
  Future<void> updateNote(String id, String text) async {
    try {
      final user = _getCurrentUser();

      // First check if the note exists and belongs to the user
      final doc = await _firestore.collection('notes').doc(id).get();
      if (!doc.exists) {
        throw Exception('Note not found');
      }

      final data = doc.data();
      if (data?['userId'] != user.uid) {
        throw Exception(
          'Permission denied. You can only update your own notes.',
        );
      }

      await _firestore.collection('notes').doc(id).update({
        'text': text,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Unable to update note.');
      }
      throw Exception('Failed to update note: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    try {
      final user = _getCurrentUser();

      // First check if the note exists and belongs to the user
      final doc = await _firestore.collection('notes').doc(id).get();
      if (!doc.exists) {
        throw Exception('Note not found');
      }

      final data = doc.data();
      if (data?['userId'] != user.uid) {
        throw Exception(
          'Permission denied. You can only delete your own notes.',
        );
      }

      await _firestore.collection('notes').doc(id).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('Permission denied. Unable to delete note.');
      }
      throw Exception('Failed to delete note: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Listen to notes in real-time (optional enhancement)
  Stream<List<Map<String, dynamic>>> notesStream() {
    final user = _getCurrentUser();

    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'text': data['text'] ?? '',
              'createdAt': data['createdAt'],
              'updatedAt': data['updatedAt'],
              'userId': data['userId'],
            };
          }).toList();
        });
  }
}
