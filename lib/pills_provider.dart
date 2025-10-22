import 'package:flutter/material.dart';
import 'add_pills_form.dart';

class PillsProvider extends ChangeNotifier {
  final List<PillData> _pills = [];

  List<PillData> get pills => List.unmodifiable(_pills);

  void addPill(PillData pill) {
    _pills.add(pill);
    notifyListeners();
  }

  void removePill(PillData pill) {
    _pills.remove(pill);
    notifyListeners();
  }

  void clearAllPills() {
    _pills.clear();
    notifyListeners();
  }
}
