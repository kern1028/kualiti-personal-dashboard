import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_tokens.dart';
import '../models/timer_model.dart';
import '../providers/timer_provider.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: tokens.bg,
      appBar: AppBar(
        title: Text(l10n.navTimer),
        backgroundColor: tokens.bg,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: tokens.accent,
          unselectedLabelColor: tokens.inkMuted,
          indicatorColor: tokens.accent,
          tabs: [
            Tab(text: l10n.tabTimer),
            Tab(text: l10n.tabStopwatch),
            Tab(text: l10n.tabGaming),
            Tab(text: l10n.tabReading),
            Tab(text: l10n.tabStudying),
            Tab(text: l10n.tabEyeRest),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNormalTimerTab(tokens, l10n),
          _buildStopwatchTab(tokens, l10n),
          _buildSessionTab('gaming', tokens, l10n),
          _buildSessionTab('reading', tokens, l10n),
          _buildSessionTab('studying', tokens, l10n),
          _buildEyeRestTab(tokens, l10n),
        ],
      ),
    );
  }

  // --- TAB 1: NORMAL TIMER ---
  Widget _buildNormalTimerTab(ThemeTokens tokens, AppLocalizations l10n) {
    final provider = Provider.of<TimerProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Quick Presets
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [1, 5, 10, 15].map((min) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: tokens.ink,
                side: BorderSide(color: tokens.line),
              ),
              onPressed: () {
                final success = provider.addTimer('Timer $min mnt', min * 60);
                if (!success) _showMaxLimitWarning(tokens);
              },
              child: Text('+ $min ${l10n.minutes}'),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Active Timers List
        ...provider.timers.where((t) => !t.isStopwatch).map((t) {
          return _buildTimerCard(t, provider, tokens);
        }),

        if (provider.timers.where((t) => !t.isStopwatch).isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                l10n.emptyState,
                style: TextStyle(color: tokens.inkMuted),
              ),
            ),
          ),

        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.accent,
            foregroundColor: tokens.onAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius),
            ),
          ),
          icon: const Icon(Icons.add),
          label: Text(
            '${l10n.add} ${l10n.tabTimer}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => _showAddTimerDialog(tokens),
        ),
      ],
    );
  }

  Widget _buildTimerCard(TimerItem t, TimerProvider provider, ThemeTokens tokens) {
    final remaining = t.remainingSeconds;
    final m = (remaining / 60).floor().toString().padLeft(2, '0');
    final s = (remaining % 60).toString().padLeft(2, '0');
    final progress = t.totalDurationSeconds > 0
        ? remaining / t.totalDurationSeconds
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius),
        border: Border.all(color: tokens.line, width: tokens.borderWidth),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: progress,
                  color: tokens.accent,
                  backgroundColor: tokens.line,
                  strokeWidth: 4,
                ),
              ),
              Icon(
                t.isRunning ? Icons.timer_outlined : Icons.pause,
                color: tokens.accent,
                size: 20,
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                ),
                Text(
                  '$m:$s',
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(t.isRunning ? Icons.pause_circle : Icons.play_circle),
            color: tokens.accent,
            iconSize: 32,
            onPressed: () => provider.togglePauseTimer(t.id),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: tokens.inkMuted),
            onPressed: () => provider.deleteTimer(t.id),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: STOPWATCH ---
  Widget _buildStopwatchTab(ThemeTokens tokens, AppLocalizations l10n) {
    final provider = Provider.of<TimerProvider>(context);
    final stopwatches = provider.timers.where((t) => t.isStopwatch).toList();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (stopwatches.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(l10n.emptyState, style: TextStyle(color: tokens.inkMuted)),
            ),
          )
        else
          ...stopwatches.map((sw) {
            final sec = sw.remainingSeconds;
            final m = (sec / 60).floor().toString().padLeft(2, '0');
            final s = (sec % 60).toString().padLeft(2, '0');

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.surface,
                borderRadius: BorderRadius.circular(tokens.radius),
                border: Border.all(color: tokens.line, width: tokens.borderWidth),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sw.name,
                        style: TextStyle(
                          fontFamily: tokens.fontTitle,
                          fontWeight: FontWeight.bold,
                          color: tokens.ink,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: tokens.inkMuted),
                        onPressed: () => provider.deleteTimer(sw.id),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      '$m:$s',
                      style: TextStyle(
                        fontFamily: tokens.fontTitle,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: tokens.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: tokens.onAccent,
                        ),
                        onPressed: () => provider.togglePauseTimer(sw.id),
                        child: Text(sw.isRunning ? l10n.pause : l10n.start),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.ink,
                          side: BorderSide(color: tokens.line),
                        ),
                        onPressed: () => provider.addLap(sw.id),
                        child: Text(l10n.lap),
                      ),
                    ],
                  ),
                  if (sw.laps.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Divider(),
                    ...List.generate(sw.laps.length, (idx) {
                      final lapSec = sw.laps[idx];
                      final lm = (lapSec / 60).floor().toString().padLeft(2, '0');
                      final ls = (lapSec % 60).toString().padLeft(2, '0');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Lap ${idx + 1}', style: TextStyle(color: tokens.inkMuted)),
                            Text('$lm:$ls', style: TextStyle(color: tokens.ink, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          }),

        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: tokens.accent,
            foregroundColor: tokens.onAccent,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius)),
          ),
          icon: const Icon(Icons.timer),
          label: Text('+ ${l10n.tabStopwatch}', style: const TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            final success = provider.addStopwatch('Stopwatch ${stopwatches.length + 1}');
            if (!success) _showMaxLimitWarning(tokens);
          },
        ),
      ],
    );
  }

  // --- TABS 3, 4, 5: SESSIONS (GAMING, READING, STUDYING) ---
  Widget _buildSessionTab(String mode, ThemeTokens tokens, AppLocalizations l10n) {
    final provider = Provider.of<TimerProvider>(context);
    final activeSession = provider.activeSession;

    int defaultFocusSec = 7200; // 2 hrs Gaming
    int defaultRestSec = 1200; // 20 mins

    if (mode == 'reading') {
      defaultFocusSec = 2700; // 45 mins
      defaultRestSec = 600; // 10 mins
    } else if (mode == 'studying') {
      defaultFocusSec = 3000; // 50 mins
      defaultRestSec = 600; // 10 mins
    }

    final isThisModeActive = activeSession != null && activeSession.mode == mode;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (isThisModeActive) ...[
          // Active Session Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.accent, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  activeSession.phase == 'focus' ? l10n.focus : l10n.rest,
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: tokens.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.cycle} ${activeSession.cycle} ${l10n.cycleOf} ${activeSession.totalCycles > 0 ? activeSession.totalCycles : l10n.unlimited}',
                  style: TextStyle(color: tokens.inkMuted, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Text(
                  _formatSeconds(activeSession.remainingSeconds),
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.accent,
                        foregroundColor: tokens.onAccent,
                      ),
                      onPressed: () => provider.togglePauseSession(),
                      child: Text(activeSession.isRunning ? l10n.pause : l10n.start),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.priorityHigh,
                        side: BorderSide(color: tokens.priorityHigh),
                      ),
                      onPressed: () => provider.resetSession(),
                      child: Text(l10n.reset),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // Session Configuration & Start Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius),
              border: Border.all(color: tokens.line, width: tokens.borderWidth),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesi ${mode.toUpperCase()} (${l10n.recommended})',
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fokus: ${(defaultFocusSec / 60).round()} ${l10n.minutes} | Istirahat: ${(defaultRestSec / 60).round()} ${l10n.minutes}',
                  style: TextStyle(color: tokens.inkMuted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radius)),
                  ),
                  onPressed: () {
                    provider.startSession(
                      mode: mode,
                      focusSec: defaultFocusSec,
                      restSec: defaultRestSec,
                      totalCycles: 1,
                      autoStart: true,
                    );
                  },
                  child: Text(l10n.start, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 6: 20-20-20 EYE REST ---
  Widget _buildEyeRestTab(ThemeTokens tokens, AppLocalizations l10n) {
    final provider = Provider.of<TimerProvider>(context);
    final state = provider.eyeRestState;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(tokens.radius),
            border: Border.all(color: tokens.line, width: tokens.borderWidth),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  l10n.eyeRestEnableReminders,
                  style: TextStyle(
                    fontFamily: tokens.fontTitle,
                    fontWeight: FontWeight.bold,
                    color: tokens.ink,
                  ),
                ),
                subtitle: Text(
                  l10n.eyeRestActiveHoursHint,
                  style: TextStyle(color: tokens.inkMuted, fontSize: 12),
                ),
                activeColor: tokens.accent,
                value: state.enabled,
                onChanged: (val) => provider.toggleEyeRest(val),
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l10n.eyeRestNotificationText,
                style: TextStyle(
                  fontFamily: tokens.fontBody,
                  fontSize: 14,
                  color: tokens.ink,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              if (state.isResting20s) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tokens.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye, color: tokens.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Menatap jauh 20 detik...',
                        style: TextStyle(
                          fontFamily: tokens.fontTitle,
                          fontWeight: FontWeight.bold,
                          color: tokens.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.accent,
                        foregroundColor: tokens.onAccent,
                      ),
                      onPressed: () => provider.startEyeRest20s(),
                      child: Text(l10n.eyeRestStartAction, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: tokens.ink),
                      onPressed: () => provider.snoozeEyeRest5m(),
                      child: Text(l10n.eyeRestSnoozeAction),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: tokens.inkMuted),
                      onPressed: () => provider.skipEyeRest(),
                      child: Text(l10n.eyeRestSkipAction),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Warning per PRD Section 5.2
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.inkMuted.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: tokens.inkMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.eyeRestKilledWarning,
                        style: TextStyle(
                          fontFamily: tokens.fontBody,
                          fontSize: 11,
                          color: tokens.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSeconds(int totalSec) {
    final m = (totalSec / 60).floor().toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showMaxLimitWarning(ThemeTokens tokens) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Maksimal 5 timer/stopwatch aktif sekaligus.'),
        backgroundColor: tokens.priorityHigh,
      ),
    );
  }

  void _showAddTimerDialog(ThemeTokens tokens) {
    final nameController = TextEditingController(text: 'Timer Baru');
    int selectedMin = 5;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.surface,
        title: Text('Tambah Timer', style: TextStyle(color: tokens.ink)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Timer'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Durasi (menit): '),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedMin,
                    items: [1, 3, 5, 10, 15, 20, 30, 45, 60]
                        .map((m) => DropdownMenuItem(value: m, child: Text('$m menit')))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) selectedMin = val;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.accent,
              foregroundColor: tokens.onAccent,
            ),
            onPressed: () {
              final provider = Provider.of<TimerProvider>(context, listen: false);
              final success = provider.addTimer(nameController.text.trim(), selectedMin * 60);
              Navigator.pop(ctx);
              if (!success) _showMaxLimitWarning(tokens);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
