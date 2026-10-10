import 'package:flutter_test/flutter_test.dart';
import 'package:kualiti/features/timer/models/timer_model.dart';

void main() {
  group('TimerModel & SessionState Test', () {
    test('Timer remaining seconds calculation', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final timer = TimerItem(
        id: '1',
        name: 'Test',
        totalDurationSeconds: 300,
        endTimestamp: now + 300000,
        isRunning: true,
      );

      expect(timer.remainingSeconds <= 300, true);
      expect(timer.remainingSeconds >= 298, true);
    });

    test('SessionState focus and rest duration', () {
      final session = SessionState(
        mode: 'gaming',
        phase: 'focus',
        focusSec: 7200,
        restSec: 1200,
      );

      expect(session.currentPhaseDurationSec, 7200);

      final restSession = session.copyWith(phase: 'rest');
      expect(restSession.currentPhaseDurationSec, 1200);
    });
  });
}
