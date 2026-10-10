class TimerItem {
  final String id;
  final String name;
  final int totalDurationSeconds;
  final int endTimestamp; // ms since epoch
  final bool isRunning;
  final bool isPaused;
  final int remainingSecondsWhenPaused;
  final bool isStopwatch;
  final List<int> laps; // lap timestamps or elapsed seconds

  TimerItem({
    required this.id,
    required this.name,
    required this.totalDurationSeconds,
    required this.endTimestamp,
    this.isRunning = false,
    this.isPaused = false,
    this.remainingSecondsWhenPaused = 0,
    this.isStopwatch = false,
    List<int>? laps,
  }) : laps = laps ?? [];

  int get remainingSeconds {
    if (isStopwatch) {
      if (isPaused) return remainingSecondsWhenPaused;
      if (!isRunning) return 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final elapsedMs = now - (endTimestamp - (totalDurationSeconds * 1000));
      return (elapsedMs / 1000).floor();
    } else {
      if (isPaused) return remainingSecondsWhenPaused;
      if (!isRunning) return totalDurationSeconds;
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = ((endTimestamp - now) / 1000).ceil();
      return diff > 0 ? diff : 0;
    }
  }

  TimerItem copyWith({
    String? id,
    String? name,
    int? totalDurationSeconds,
    int? endTimestamp,
    bool? isRunning,
    bool? isPaused,
    int? remainingSecondsWhenPaused,
    bool? isStopwatch,
    List<int>? laps,
  }) {
    return TimerItem(
      id: id ?? this.id,
      name: name ?? this.name,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      remainingSecondsWhenPaused:
          remainingSecondsWhenPaused ?? this.remainingSecondsWhenPaused,
      isStopwatch: isStopwatch ?? this.isStopwatch,
      laps: laps ?? List.from(this.laps),
    );
  }
}

class SessionState {
  final String mode; // 'gaming', 'reading', 'studying'
  final String phase; // 'idle', 'focus', 'rest'
  final int cycle;
  final int totalCycles; // 0 = unlimited, 1..8
  final bool autoStart;
  final int focusSec;
  final int restSec;
  final int endTimestamp;
  final bool isRunning;
  final bool isPaused;
  final int remainingSecondsWhenPaused;

  SessionState({
    required this.mode,
    this.phase = 'idle',
    this.cycle = 1,
    this.totalCycles = 1,
    this.autoStart = true,
    required this.focusSec,
    required this.restSec,
    this.endTimestamp = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.remainingSecondsWhenPaused = 0,
  });

  int get currentPhaseDurationSec => phase == 'rest' ? restSec : focusSec;

  int get remainingSeconds {
    if (isPaused) return remainingSecondsWhenPaused;
    if (!isRunning || phase == 'idle') return currentPhaseDurationSec;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = ((endTimestamp - now) / 1000).ceil();
    return diff > 0 ? diff : 0;
  }

  SessionState copyWith({
    String? mode,
    String? phase,
    int? cycle,
    int? totalCycles,
    bool? autoStart,
    int? focusSec,
    int? restSec,
    int? endTimestamp,
    bool? isRunning,
    bool? isPaused,
    int? remainingSecondsWhenPaused,
  }) {
    return SessionState(
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      cycle: cycle ?? this.cycle,
      totalCycles: totalCycles ?? this.totalCycles,
      autoStart: autoStart ?? this.autoStart,
      focusSec: focusSec ?? this.focusSec,
      restSec: restSec ?? this.restSec,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      remainingSecondsWhenPaused:
          remainingSecondsWhenPaused ?? this.remainingSecondsWhenPaused,
    );
  }
}

class EyeRestState {
  final bool enabled;
  final int startHour; // default 8
  final int endHour; // default 22
  final int unrespondedCount; // 0..3
  final bool isAutoPaused;
  final bool isResting20s;
  final int restEndTimestamp;

  EyeRestState({
    this.enabled = false,
    this.startHour = 8,
    this.endHour = 22,
    this.unrespondedCount = 0,
    this.isAutoPaused = false,
    this.isResting20s = false,
    this.restEndTimestamp = 0,
  });

  bool get isInActiveHours {
    final hour = DateTime.now().hour;
    if (startHour <= endHour) {
      return hour >= startHour && hour < endHour;
    } else {
      return hour >= startHour || hour < endHour;
    }
  }

  EyeRestState copyWith({
    bool? enabled,
    int? startHour,
    int? endHour,
    int? unrespondedCount,
    bool? isAutoPaused,
    bool? isResting20s,
    int? restEndTimestamp,
  }) {
    return EyeRestState(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      unrespondedCount: unrespondedCount ?? this.unrespondedCount,
      isAutoPaused: isAutoPaused ?? this.isAutoPaused,
      isResting20s: isResting20s ?? this.isResting20s,
      restEndTimestamp: restEndTimestamp ?? this.restEndTimestamp,
    );
  }
}
