import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RunCadenceSession {
  final String id;
  final DateTime timestamp;
  final int durationSeconds;
  final int targetBpm;
  final int totalSteps;
  final String note;

  RunCadenceSession({
    required this.id,
    required this.timestamp,
    required this.durationSeconds,
    required this.targetBpm,
    required this.totalSteps,
    required this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'durationSeconds': durationSeconds,
        'targetBpm': targetBpm,
        'totalSteps': totalSteps,
        'note': note,
      };

  factory RunCadenceSession.fromJson(Map<String, dynamic> json) =>
      RunCadenceSession(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        durationSeconds: json['durationSeconds'] as int,
        targetBpm: json['targetBpm'] as int,
        totalSteps: json['totalSteps'] as int,
        note: (json['note'] as String?) ?? '',
      );
}

class CadenceManager extends ChangeNotifier {
  static const String _keyBpm = 'droniva_target_bpm';
  static const String _keyHeight = 'droniva_runner_height';
  static const String _keyPace = 'droniva_runner_pace';
  static const String _keySessions = 'droniva_run_sessions';

  int _targetBpm = 180;
  double _runnerHeightCm = 175.0;
  double _runnerPaceMinPerKm = 5.5; // 5:30 min/km
  List<RunCadenceSession> _sessions = [];
  bool _isLoaded = false;

  // Active workout state
  bool _isPlaying = false;
  int _activeSeconds = 0;
  int _activeSteps = 0;
  Timer? _sessionTimer;
  Timer? _beatTimer;
  int _currentBeat = 0;

  CadenceManager() {
    _loadPreferences();
  }

  int get targetBpm => _targetBpm;
  double get runnerHeightCm => _runnerHeightCm;
  double get runnerPaceMinPerKm => _runnerPaceMinPerKm;
  List<RunCadenceSession> get sessions => List.unmodifiable(_sessions);
  bool get isLoaded => _isLoaded;
  bool get isPlaying => _isPlaying;
  int get activeSeconds => _activeSeconds;
  int get activeSteps => _activeSteps;
  int get currentBeat => _currentBeat;

  // Calculated stride length in meters based on height and pace
  // Stride length ~ Height * 0.413 (walking) to Height * 0.65-0.75 (running)
  double get calculatedStrideLengthMeters {
    // Faster pace -> longer stride
    final paceFactor = (7.0 - _runnerPaceMinPerKm).clamp(0.0, 3.0) * 0.05;
    final baseRatio = 0.65 + paceFactor;
    return ((_runnerHeightCm / 100.0) * baseRatio);
  }

  // Recommended cadence based on height and pace
  int get recommendedCadence {
    // Taller runners often naturally have slightly lower cadence around 174-178, shorter runners 180-186
    if (_runnerHeightCm > 185) {
      return 174;
    } else if (_runnerHeightCm < 165) {
      return 184;
    } else {
      return 180;
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _targetBpm = prefs.getInt(_keyBpm) ?? 180;
      _runnerHeightCm = prefs.getDouble(_keyHeight) ?? 175.0;
      _runnerPaceMinPerKm = prefs.getDouble(_keyPace) ?? 5.5;

      final rawList = prefs.getStringList(_keySessions);
      if (rawList != null && rawList.isNotEmpty) {
        _sessions = rawList
            .map((item) =>
                RunCadenceSession.fromJson(jsonDecode(item) as Map<String, dynamic>))
            .toList();
      } else {
        // Populate default starter sessions for rich initial experience
        _sessions = [
          RunCadenceSession(
            id: 'init-1',
            timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
            durationSeconds: 1200,
            targetBpm: 180,
            totalSteps: 3600,
            note: 'Steady interval pacing, kept rhythm easily',
          ),
          RunCadenceSession(
            id: 'init-2',
            timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
            durationSeconds: 900,
            targetBpm: 176,
            totalSteps: 2640,
            note: 'Warmup cadence drill before 5k parkrun',
          ),
        ];
      }
    } catch (e) {
      debugPrint('Error loading cadence prefs: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setTargetBpm(int bpm) async {
    _targetBpm = bpm.clamp(140, 220);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBpm, _targetBpm);

    if (_isPlaying) {
      _restartBeatTimer();
    }
  }

  Future<void> setRunnerHeight(double cm) async {
    _runnerHeightCm = cm.clamp(130.0, 220.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyHeight, _runnerHeightCm);
  }

  Future<void> setRunnerPace(double pace) async {
    _runnerPaceMinPerKm = pace.clamp(3.0, 9.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyPace, _runnerPaceMinPerKm);
  }

  void togglePacing() {
    if (_isPlaying) {
      stopPacing();
    } else {
      startPacing();
    }
  }

  void startPacing() {
    _isPlaying = true;
    _currentBeat = 0;
    _activeSeconds = 0;
    _activeSteps = 0;
    notifyListeners();

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _activeSeconds++;
      notifyListeners();
    });

    _restartBeatTimer();
  }

  void _restartBeatTimer() {
    _beatTimer?.cancel();
    final intervalMs = (60000 / _targetBpm).round();
    _beatTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      _currentBeat = (_currentBeat + 1) % 4;
      _activeSteps++;
      notifyListeners();
    });
  }

  void stopPacing({bool autoSave = true}) {
    _isPlaying = false;
    _sessionTimer?.cancel();
    _beatTimer?.cancel();

    if (autoSave && _activeSeconds >= 10) {
      final newSession = RunCadenceSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        durationSeconds: _activeSeconds,
        targetBpm: _targetBpm,
        totalSteps: _activeSteps,
        note: 'Cadence training at $_targetBpm SPM',
      );
      _sessions.insert(0, newSession);
      _persistSessions();
    }
    notifyListeners();
  }

  Future<void> addCustomSession(RunCadenceSession session) async {
    _sessions.insert(0, session);
    notifyListeners();
    await _persistSessions();
  }

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((item) => item.id == id);
    notifyListeners();
    await _persistSessions();
  }

  Future<void> _persistSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _sessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_keySessions, encoded);
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _beatTimer?.cancel();
    super.dispose();
  }
}
