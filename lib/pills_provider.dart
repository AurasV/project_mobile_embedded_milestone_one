import 'package:flutter/material.dart';
import 'add_pills_form.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';

class PillsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final LocalStorageService _localStorage = LocalStorageService();
  final SyncService _syncService = SyncService();
  
  List<PillData> _pills = [];
  bool _isLoading = false;
  bool _isOnline = true;

  List<PillData> get pills => List.unmodifiable(_pills);
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  PillsProvider() {
    _syncService.listenToConnectivity();
  }

  // Load medications from local storage (works offline)
  Future<void> loadMedicationsFromLocal() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pills = await _localStorage.getMedications();
      notifyListeners();
    } catch (e) {
      print('Error loading from local storage: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Listen to Firebase (when online)
  void listenToMedications() {
    // First load from local storage immediately
    loadMedicationsFromLocal();

    // Then listen to Firebase stream
    _firebaseService.getMedications().listen((medications) async {
      _isOnline = true;
      
      // First, sync any local unsynced changes to Firebase
      await _syncService.syncToFirebase();
      
      // Get list of IDs that still need syncing (in case sync failed)
      final unsyncedMeds = await _localStorage.getUnsyncedMedications();
      final unsyncedIds = unsyncedMeds.map((m) => m['id'] as String).toSet();
      
      // Then sync Firebase data to local storage, but skip any that have unsynced changes
      for (var pill in medications) {
        // Only overwrite if this medication doesn't have pending local changes
        if (!unsyncedIds.contains(pill.id)) {
          await _localStorage.saveMedication(pill, syncStatus: 1);
        }
      }
      
      // After sync is complete, reload from local storage to show consistent data
      await loadMedicationsFromLocal();
    }, onError: (error) {
      // Firebase error - we're offline or have connection issues
      _isOnline = false;
      loadMedicationsFromLocal();
    });
  }

  Future<void> addPill(PillData pill) async {
    try {
      final isOnline = await _syncService.isOnline();
      
      if (isOnline) {
        // If online, add to Firebase directly - the listener will handle local storage
        await _firebaseService.addMedication(pill);
      } else {
        // If offline, save locally first
        await _localStorage.saveMedication(pill);
        // Immediately update local state
        _pills = await _localStorage.getMedications();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePill(PillData pill) async {
    try {
      final isOnline = await _syncService.isOnline();
      
      if (isOnline) {
        // If online, update Firebase directly - the listener will handle local storage
        await _firebaseService.updateMedication(pill);
      } else {
        // If offline, update locally
        await _localStorage.updateMedication(pill);
        // Immediately update local state
        _pills = await _localStorage.getMedications();
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePill(PillData pill) async {
    if (pill.id == null) return;
    
    try {
      // Delete locally first
      await _localStorage.deleteMedication(pill.id!);
      
      // Update local state immediately
      _pills = await _localStorage.getMedications();
      notifyListeners();
      
      // Try to delete from Firebase if online (don't wait for it)
      if (await _syncService.isOnline()) {
        _firebaseService.deleteMedication(pill.id!).catchError((e) {
          print('Failed to delete from Firebase: $e');
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllPills() async {
    try {
      // Clear locally first
      await _localStorage.clearAll();
      
      // Update local state immediately
      _pills = [];
      notifyListeners();
      
      // Try to clear from Firebase if online (don't wait for it)
      if (await _syncService.isOnline()) {
        _firebaseService.deleteAllMedications().catchError((e) {
          print('Failed to clear from Firebase: $e');
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // Manual sync trigger
  Future<void> syncData() async {
    if (await _syncService.isOnline()) {
      await _syncService.performFullSync();
      await loadMedicationsFromLocal();
    }
  }
}
