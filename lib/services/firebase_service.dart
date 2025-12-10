import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../add_pills_form.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  // Authentication
  Future<UserCredential> signUp(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Medication CRUD
  Future<void> addMedication(PillData pill) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .add({
      'name': pill.name,
      'type': pill.type,
      'amount': pill.amount,
      'duration': pill.duration,
      'timeHour': pill.time.hour,
      'timeMinute': pill.time.minute,
      'startDate': Timestamp.fromDate(pill.startDate),
      'frequency': pill.frequency,
      'frequencyValue': pill.frequencyValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // Add medication with specific ID (for syncing)
  Future<void> addMedicationWithId(PillData pill) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    if (pill.id == null) throw Exception('Medication ID required');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .doc(pill.id)
        .set({
      'name': pill.name,
      'type': pill.type,
      'amount': pill.amount,
      'duration': pill.duration,
      'timeHour': pill.time.hour,
      'timeMinute': pill.time.minute,
      'startDate': Timestamp.fromDate(pill.startDate),
      'frequency': pill.frequency,
      'frequencyValue': pill.frequencyValue,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  // Update medication without deleting history
  Future<void> updateMedication(PillData pill) async {
    if (currentUserId == null || pill.id == null) throw Exception('Invalid operation');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .doc(pill.id)
        .update({
      'name': pill.name,
      'type': pill.type,
      'amount': pill.amount,
      'duration': pill.duration,
      'timeHour': pill.time.hour,
      'timeMinute': pill.time.minute,
      'startDate': Timestamp.fromDate(pill.startDate),
      'frequency': pill.frequency,
      'frequencyValue': pill.frequencyValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<PillData>> getMedications() {
    if (currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      // Sort in Dart instead of Firestore to avoid index issues
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final aTime = a.data()['createdAt'] as Timestamp?;
        final bTime = b.data()['createdAt'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime); // Descending order
      });

      return docs.map((doc) {
        final data = doc.data();
        return PillData(
          id: doc.id,
          name: data['name'] ?? '',
          type: data['type'] ?? '',
          amount: data['amount'] ?? 1,
          duration: data['duration'] ?? 1,
          time: TimeOfDay(
            hour: data['timeHour'] ?? 0,
            minute: data['timeMinute'] ?? 0,
          ),
          startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          frequency: data['frequency'] ?? 'daily',
          frequencyValue: data['frequencyValue'] ?? 1,
        );
      }).toList();
    });
  }

  // Get medications that need alarms scheduled
  Future<List<PillData>> getActiveMedications() async {
    if (currentUserId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PillData(
        id: doc.id,
        name: data['name'] ?? '',
        type: data['type'] ?? '',
        amount: data['amount'] ?? 1,
        duration: data['duration'] ?? 1,
        time: TimeOfDay(
          hour: data['timeHour'] ?? 0,
          minute: data['timeMinute'] ?? 0,
        ),
        startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        frequency: data['frequency'] ?? 'daily',
        frequencyValue: data['frequencyValue'] ?? 1,
      );
    }).toList();
  }

  Future<void> deleteMedication(String medicationId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .doc(medicationId)
        .update({'isActive': false});
  }

  Future<void> deleteAllMedications() async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final medications = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .get();

    for (var doc in medications.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    await batch.commit();
  }

  // Mark medication dose as taken
  Future<void> markDoseTaken(String medicationId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('medications')
        .doc(medicationId)
        .collection('doses')
        .add({
      'takenAt': FieldValue.serverTimestamp(),
      'scheduledTime': Timestamp.now(),
    });
  }

  // USER PROFILE METHODS

  // Get user profile stream
  Stream<DocumentSnapshot> getUserProfile() {
    if (currentUserId == null) return Stream.empty();
    return _firestore.collection('users').doc(currentUserId).snapshots();
  }

  // Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    await _firestore.collection('users').doc(currentUserId).set(
      data,
      SetOptions(merge: true),
    );
  }
}
