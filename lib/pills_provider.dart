import 'package:flutter/material.dart';
import 'add_pills_form.dart';
import 'services/firebase_service.dart';

class PillsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<PillData> _pills = [];
  bool _isLoading = false;

  List<PillData> get pills => List.unmodifiable(_pills);
  bool get isLoading => _isLoading;

  void listenToMedications() {
    _firebaseService.getMedications().listen((medications) {
      _pills = medications;
      notifyListeners();
    });
  }

  Future<void> addPill(PillData pill) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.addMedication(pill);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Update existing pill
  Future<void> updatePill(PillData pill) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.updateMedication(pill);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePill(PillData pill) async {
    if (pill.id == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteMedication(pill.id!);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllPills() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.deleteAllMedications();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
