import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'local_storage_service.dart';
import 'firebase_service.dart';
import '../add_pills_form.dart';

class SyncService {
  final LocalStorageService _localStorage = LocalStorageService();
  final FirebaseService _firebaseService = FirebaseService();
  final Connectivity _connectivity = Connectivity();
  
  bool _isSyncing = false;

  // Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
  }

  // Sync local changes to Firebase
  Future<void> syncToFirebase() async {
    if (_isSyncing) return;
    if (!await isOnline()) return;
    if (_firebaseService.currentUserId == null) return;

    _isSyncing = true;

    try {
      final unsyncedMedications = await _localStorage.getUnsyncedMedications();

      for (var medMap in unsyncedMedications) {
        final pill = _mapToPillData(medMap);
        
        // Check if this medication exists on server
        final serverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_firebaseService.currentUserId)
            .collection('medications')
            .doc(pill.id)
            .get();

        if (!serverDoc.exists) {
          // New medication - add to Firebase
          await _firebaseService.addMedicationWithId(pill);
          await _localStorage.markAsSynced(pill.id!);
        } else {
          // Existing medication - always update if it has syncStatus=0 (local changes)
          final syncStatus = medMap['syncStatus'] as int;
          
          if (syncStatus == 0) {
            // Has unsynced local changes - push to server
            if (medMap['isActive'] == 0) {
              await _firebaseService.deleteMedication(pill.id!);
            } else {
              await _firebaseService.updateMedication(pill);
            }
            await _localStorage.markAsSynced(pill.id!);
          }
        }
      }
    } catch (e) {
      print('Sync to Firebase failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Sync Firebase data to local storage
  Future<void> syncFromFirebase() async {
    if (!await isOnline()) return;
    if (_firebaseService.currentUserId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseService.currentUserId)
          .collection('medications')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Get local version if exists
        final localDb = await _localStorage.database;
        final localResult = await localDb.query(
          'medications',
          where: 'id = ?',
          whereArgs: [doc.id],
        );

        final serverUpdatedAt = (data['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch 
            ?? (data['createdAt'] as Timestamp?)?.millisecondsSinceEpoch 
            ?? DateTime.now().millisecondsSinceEpoch;

        if (localResult.isEmpty) {
          // Doesn't exist locally - add it
          final pill = PillData(
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
          
          await _localStorage.saveMedication(pill, syncStatus: 1);
        } else {
          // Exists locally - compare timestamps and update if server is newer
          final localData = localResult.first;
          final localUpdatedAt = localData['updatedAt'] as int;
          final localSyncStatus = localData['syncStatus'] as int;

          // Only update if server is newer AND local doesn't have unsynced changes
          if (serverUpdatedAt > localUpdatedAt && localSyncStatus == 1) {
            // Server is newer - update local
            final pill = PillData(
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
            
            await _localStorage.saveMedication(pill, syncStatus: 1);
          }
          // If local has unsynced changes (syncStatus=0), preserve them
        }
      }
    } catch (e) {
      print('Sync from Firebase failed: $e');
    }
  }

  // Perform full bidirectional sync
  Future<void> performFullSync() async {
    if (!await isOnline()) return;

    // First sync local changes to Firebase
    await syncToFirebase();
    
    // Then sync Firebase changes to local (won't overwrite unsynced local data)
    await syncFromFirebase();
  }

  // Mark medication as synced
  Future<void> markAsSynced(String medicationId) async {
    final db = await _localStorage.database;
    await db.update(
      'medications',
      {'syncStatus': 1},
      where: 'id = ?',
      whereArgs: [medicationId],
    );
  }

  // Listen to connectivity changes
  void listenToConnectivity() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final isOnlineNow = results.isNotEmpty && 
                          results.any((result) => 
                            result != ConnectivityResult.none);
      
      // If we just came back online, trigger a sync
      if (isOnlineNow) {
        await performFullSync();
      }
    });
  }

  // Helper to convert map to PillData
  PillData _mapToPillData(Map<String, dynamic> map) {
    return PillData(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      amount: map['amount'] as int,
      duration: map['duration'] as int,
      time: TimeOfDay(
        hour: map['timeHour'] as int,
        minute: map['timeMinute'] as int,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      frequency: map['frequency'] as String,
      frequencyValue: map['frequencyValue'] as int,
    );
  }
}
