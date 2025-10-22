// /lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update user data in Firestore
  Future<void> saveUser({
    required User user,
    String? fullName,
  }) async {
    final userRef = _db.collection('users').doc(user.uid);

    return _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        // Create new user document
        transaction.set(userRef, {
          'uid': user.uid,
          'emailAddress': user.email,
          'fullName': fullName ?? user.displayName ?? 'N/A',
          'role': null,
          'isVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Update the user's role after selection
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _db.collection('users').doc(uid).update({
        'role': role,
      });
      print('User role updated successfully to: $role');
    } catch (e) {
      print('Error updating user role: $e');
      throw 'Failed to update user role. Please try again.';
    }
  }

  // Update verification status after ID verification
  Future<void> updateVerificationStatus(String uid, bool isVerified) async {
    try {
      await _db.collection('users').doc(uid).update({
        'isVerified': isVerified,
      });
      print('User verification status updated to: $isVerified');
    } catch (e) {
      print('Error updating verification status: $e');
      throw 'Failed to update verification status. Please try again.';
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}