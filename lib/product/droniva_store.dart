import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DronivaStore extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<dynamic> _history = [];

  List<dynamic> get history => _history;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs?.getString('droniva_data');
    if (data != null) {
      _history = jsonDecode(data);
    }
    notifyListeners();
  }

  void addHistory(String item) {
    _history.add(item);
    _prefs?.setString('droniva_data', jsonEncode(_history));
    notifyListeners();
  }
}
