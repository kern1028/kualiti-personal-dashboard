import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/services/timer_foreground_service.dart';
import '../models/timer_model.dart';

class TimerProvider extends ChangeNotifier {
  List<TimerItem> _timers = [];
  SessionState? _activeSession;
  EyeRestState _eyeRestState = EyeRestState();

  Timer? _ticker;

  List<TimerItem> get timers => _timers;
  SessionState? get activeSession => _activeSession;
  EyeRestState get eyeRestState => _eyeRestState;

  int get activeTimersCount =>
      _timers.where((t) => t.isRunning || t.isPaused).length;

  bool get hasActiveRunning =>
      _timers.any((t) => t.isRunning) ||
      (_activeSession != null && _activeSession!.isRunning);

  TimerProvider() {
    _initTicker();
  }

  void _initTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _onTick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onTick() {
    bool stateChanged = false;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Process Timers & Stopwatches
    for (var i = 0; i < _timers.length; i++) {
      final t = _timers[i];
      if (t.isRunning && !t.isStopwatch) {
        if (now >= t.endTimestamp) {
          _onTimerFinished(t);
          stateChanged = true;
        } else {
          stateChanged = true;
        }
      } else if (t.isRunning && t.isStopwatch) {
        stateChanged = true;
      }
    }

    // 2. Process Session (Gaming, Reading, Studying)
    if (_activeSession != null && _activeSession!.isRunning) {
      if (now >= _activeSession!.endTimestamp) {
        _onSessionPhaseFinished();
        stateChanged = true;
      } else {
        stateChanged = true;
      }
    }

    // 3. Process 20-20-20 20-second rest state
    if (_eyeRestState.isResting20s) {
      if (now >= _eyeRestState.restEndTimestamp) {
        _eyeRestState = _eyeRestState.copyWith(isResting20s: false);
        stateChanged = true;
      } else {
        stateChanged = true;
      }
    }

    if (stateChanged) {
      _syncForegroundService();
      notifyListeners();
    }
  }

  // --- TIMER ACTIONS ---

  bool addTimer(String name, int durationSeconds) {
    if (activeTimersCount >= 5) return false;

    final newTimer = TimerItem(
      id: 'timer_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      totalDurationSeconds: durationSeconds,
      endTimestamp: DateTime.now().millisecondsSinceEpoch + (durationSeconds * 1000),
      isRunning: true,
    );

    _timers.add(newTimer);
    _syncForegroundService();
    notifyListeners();
    return true;
  }

  bool addStopwatch(String name) {
    if (activeTimersCount >= 5) return false;

    final newStopwatch = TimerItem(
      id: 'sw_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      totalDurationSeconds: 0,
      endTimestamp: DateTime.now().millisecondsSinceEpoch,
      isRunning: true,
      isStopwatch: true,
    );

    _timers.add(newStopwatch);
    _syncForegroundService();
    notifyListeners();
    return true;
  }

  void togglePauseTimer(String id) {
    final index = _timers.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final t = _timers[index];
    if (t.isRunning) {
      // Pause
      _timers[index] = t.copyWith(
        isRunning: false,
        isPaused: true,
        remainingSecondsWhenPaused: t.remainingSeconds,
      );
    } else if (t.isPaused) {
      // Resume
      final remaining = t.remainingSecondsWhenPaused;
      final now = DateTime.now().millisecondsSinceEpoch;
      _timers[index] = t.copyWith(
        isRunning: true,
        isPaused: false,
        endTimestamp: now + (remaining * 1000),
      );
    }

    _syncForegroundService();
    notifyListeners();
  }

  void addLap(String id) {
    final index = _timers.indexWhere((t) => t.id == id);
    if (index == -1 || !_timers[index].isStopwatch) return;

    final t = _timers[index];
    final currentLaps = List<int>.from(t.laps);
    currentLaps.add(t.remainingSeconds);
    _timers[index] = t.copyWith(laps: currentLaps);
    notifyListeners();
  }

  void deleteTimer(String id) {
    _timers.removeWhere((t) => t.id == id);
    _syncForegroundService();
    notifyListeners();
  }

  void _onTimerFinished(TimerItem t) async {
    final index = _timers.indexWhere((item) => item.id == t.id);
    if (index != -1) {
      _timers.removeAt(index);
    }

    final prefs = await SharedPreferences.getInstance();
    final useSound = prefs.getBool('sound_enabled') ?? true;

    await NotificationService.instance.scheduleTaskReminder(
      taskId: t.id.hashCode,
      title: 'Waktu Habis: ${t.name}',
      body: 'Timer ${t.name} telah selesai!',
      reminderDateTime: DateTime.now(),
      useSound: useSound,
    );

    _syncForegroundService();
  }

  // --- SESSION ACTIONS ---

  void startSession({
    required String mode, // 'gaming', 'reading', 'studying'
    required int focusSec,
    required int restSec,
    required int totalCycles,
    required bool autoStart,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _activeSession = SessionState(
      mode: mode,
      phase: 'focus',
      cycle: 1,
      totalCycles: totalCycles,
      autoStart: autoStart,
      focusSec: focusSec,
      restSec: restSec,
      endTimestamp: now + (focusSec * 1000),
      isRunning: true,
    );

    _syncForegroundService();
    notifyListeners();
  }

  void togglePauseSession() {
    if (_activeSession == null) return;
    if (_activeSession!.isRunning) {
      _activeSession = _activeSession!.copyWith(
        isRunning: false,
        isPaused: true,
        remainingSecondsWhenPaused: _activeSession!.remainingSeconds,
      );
    } else if (_activeSession!.isPaused) {
      final remaining = _activeSession!.remainingSecondsWhenPaused;
      final now = DateTime.now().millisecondsSinceEpoch;
      _activeSession = _activeSession!.copyWith(
        isRunning: true,
        isPaused: false,
        endTimestamp: now + (remaining * 1000),
      );
    }

    _syncForegroundService();
    notifyListeners();
  }

  void resetSession() {
    _activeSession = null;
    _syncForegroundService();
    notifyListeners();
  }

  void _onSessionPhaseFinished() async {
    if (_activeSession == null) return;
    final s = _activeSession!;

    final prefs = await SharedPreferences.getInstance();
    final useSound = prefs.getBool('sound_enabled') ?? true;

    if (s.phase == 'focus') {
      // Focus finished -> Move to Rest
      await NotificationService.instance.scheduleTaskReminder(
        taskId: 99901,
        title: 'Fase Fokus Selesai',
        body: 'Saatnya istirahat sejenak!',
        reminderDateTime: DateTime.now(),
        useSound: useSound,
      );

      final now = DateTime.now().millisecondsSinceEpoch;
      _activeSession = s.copyWith(
        phase: 'rest',
        endTimestamp: now + (s.restSec * 1000),
        isRunning: s.autoStart,
        isPaused: !s.autoStart,
        remainingSecondsWhenPaused: s.restSec,
      );
    } else if (s.phase == 'rest') {
      // Rest finished -> Next cycle focus or complete
      final nextCycle = s.cycle + 1;
      final isComplete = s.totalCycles > 0 && nextCycle > s.totalCycles;

      if (isComplete) {
        await NotificationService.instance.scheduleTaskReminder(
          taskId: 99902,
          title: 'Sesi Selesai',
          body: 'Seluruh siklus sesi telah selesai. Kerja bagus!',
          reminderDateTime: DateTime.now(),
          useSound: useSound,
        );
        _activeSession = null;
      } else {
        await NotificationService.instance.scheduleTaskReminder(
          taskId: 99903,
          title: 'Fase Istirahat Selesai',
          body: 'Mulai siklus $nextCycle dari ${s.totalCycles > 0 ? s.totalCycles : "∞"}',
          reminderDateTime: DateTime.now(),
          useSound: useSound,
        );

        final now = DateTime.now().millisecondsSinceEpoch;
        _activeSession = s.copyWith(
          phase: 'focus',
          cycle: nextCycle,
          endTimestamp: now + (s.focusSec * 1000),
          isRunning: s.autoStart,
          isPaused: !s.autoStart,
          remainingSecondsWhenPaused: s.focusSec,
        );
      }
    }

    _syncForegroundService();
  }

  // --- 20-20-20 EYE REST ACTIONS ---

  void toggleEyeRest(bool enabled) {
    _eyeRestState = _eyeRestState.copyWith(
      enabled: enabled,
      isAutoPaused: false,
      unrespondedCount: 0,
    );
    notifyListeners();
  }

  void startEyeRest20s() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _eyeRestState = _eyeRestState.copyWith(
      isResting20s: true,
      restEndTimestamp: now + (20 * 1000),
      unrespondedCount: 0,
    );
    notifyListeners();
  }

  void snoozeEyeRest5m() {
    _eyeRestState = _eyeRestState.copyWith(unrespondedCount: 0);
    notifyListeners();
  }

  void skipEyeRest() {
    _eyeRestState = _eyeRestState.copyWith(unrespondedCount: 0);
    notifyListeners();
  }

  // --- FOREGROUND SERVICE SYNC ---

  void _syncForegroundService() {
    if (!hasActiveRunning) {
      TimerForegroundService.instance.stopService();
      return;
    }

    final activeItems = <String>[];
    for (final t in _timers) {
      if (t.isRunning) {
        final sec = t.remainingSeconds;
        final m = (sec / 60).floor().toString().padLeft(2, '0');
        final s = (sec % 60).toString().padLeft(2, '0');
        activeItems.add('${t.name}: $m:$s');
      }
    }

    if (_activeSession != null && _activeSession!.isRunning) {
      final s = _activeSession!;
      final sec = s.remainingSeconds;
      final m = (sec / 60).floor().toString().padLeft(2, '0');
      final sz = (sec % 60).toString().padLeft(2, '0');
      final modeName = s.mode.toUpperCase();
      final phaseName = s.phase == 'focus' ? 'Fokus' : 'Istirahat';
      activeItems.add('$modeName ($phaseName): $m:$sz');
    }

    if (activeItems.isNotEmpty) {
      final title = 'Kualiti - Timer Aktif';
      final body = activeItems.join(' | ');
      TimerForegroundService.instance.startService(title, body);
    } else {
      TimerForegroundService.instance.stopService();
    }
  }
}
